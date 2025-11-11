//
//  LeaderboardStore.swift
//  ForwardNeckV1
//
//  Manages leaderboard data persistence and synchronization
//

import Foundation
import Combine

/// Store for managing leaderboard data and user profile
/// Handles local persistence and Supabase synchronization
@MainActor
final class LeaderboardStore: ObservableObject {
    // Singleton instance
    static let shared = LeaderboardStore()
    
    // Published properties for UI updates
    @Published private(set) var leaderboardUsers: [LeaderboardUser] = []
    @Published private(set) var currentUserRank: Int?
    @Published private(set) var userProfile: UserProfile
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var lastRefreshDate: Date?
    @Published private(set) var errorMessage: String?
    
    // File URLs for persistence
    private let profileFileURL: URL
    private let cacheFileURL: URL
    
    // Services
    private let supabaseService = SupabaseService.shared
    private let exerciseStore = ExerciseStore.shared
    
    // Refresh interval (5 minutes)
    private let refreshInterval: TimeInterval = 300
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Set up file URLs
        let fm = FileManager.default
        let base = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.profileFileURL = (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("user_profile.json")
        self.cacheFileURL = (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("leaderboard_cache.json")
        
        // Load or create user profile
        self.userProfile = Self.loadProfile(from: profileFileURL)
        
        // Load cached leaderboard
        loadCachedLeaderboard()
        
        // Listen for exercise completion notifications
        NotificationCenter.default.publisher(for: .exerciseCompleted)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.handleExerciseCompletion()
                }
            }
            .store(in: &cancellables)
        
        Log.info("LeaderboardStore initialized with device ID: \(userProfile.deviceId)")
    }
    
    // MARK: - Profile Management
    
    /// Load user profile from disk, or create new one if doesn't exist
    private static func loadProfile(from url: URL) -> UserProfile {
        do {
            let data = try Data(contentsOf: url)
            let profile = try JSONDecoder().decode(UserProfile.self, from: data)
            Log.info("Loaded existing user profile")
            return profile
        } catch {
            // Create new profile with unique device ID
            let deviceId = UUID().uuidString
            let countryCode = Locale.current.region?.identifier
            let profile = UserProfile(deviceId: deviceId, countryCode: countryCode)
            
            // Save immediately
            saveProfile(profile, to: url)
            
            Log.info("Created new user profile with device ID: \(deviceId), country: \(countryCode ?? "unknown")")
            return profile
        }
    }
    
    /// Save user profile to disk
    private static func saveProfile(_ profile: UserProfile, to url: URL) {
        do {
            let data = try JSONEncoder().encode(profile)
            try data.write(to: url, options: .atomic)
            Log.info("Saved user profile")
        } catch {
            Log.error("Failed to save user profile: \(error.localizedDescription)")
        }
    }
    
    /// Update user profile locally and sync to Supabase
    func updateProfile(username: String? = nil, countryCode: String? = nil, optedIn: Bool? = nil) async {
        // Update local profile
        if let username = username {
            userProfile.username = username
        }
        if let countryCode = countryCode {
            userProfile.countryCode = countryCode
        }
        if let optedIn = optedIn {
            userProfile.optedIntoLeaderboard = optedIn
        }
        
        // Save to disk
        Self.saveProfile(userProfile, to: profileFileURL)
        
        // Sync to Supabase if opted in
        if userProfile.optedIntoLeaderboard {
            await syncToSupabase()
        }
    }
    
    // MARK: - Leaderboard Data
    
    /// Load cached leaderboard from disk
    private func loadCachedLeaderboard() {
        do {
            let data = try Data(contentsOf: cacheFileURL)
            let cache = try JSONDecoder().decode([LeaderboardUser].self, from: data)
            leaderboardUsers = cache
            Log.info("Loaded \(cache.count) users from cache")
        } catch {
            Log.info("No cached leaderboard found or failed to load")
        }
    }
    
    /// Save leaderboard to cache
    private func saveCachedLeaderboard() {
        do {
            let data = try JSONEncoder().encode(leaderboardUsers)
            try data.write(to: cacheFileURL, options: .atomic)
            Log.info("Saved \(leaderboardUsers.count) users to cache")
        } catch {
            Log.error("Failed to save leaderboard cache: \(error.localizedDescription)")
        }
    }
    
    /// Refresh leaderboard from Supabase
    func refreshLeaderboard(force: Bool = false) async {
        // Check if refresh is needed
        if !force, let lastRefresh = lastRefreshDate {
            let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
            if timeSinceRefresh < refreshInterval {
                Log.info("Skipping refresh, last refresh was \(Int(timeSinceRefresh))s ago")
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let monthYear = UserProfile.currentMonthYear
            
            // Fetch leaderboard
            let users = try await supabaseService.fetchLeaderboard(limit: 100, monthYear: monthYear)
            leaderboardUsers = users
            lastRefreshDate = Date()
            
            // Save to cache
            saveCachedLeaderboard()
            
            // Fetch user's rank if opted in
            if userProfile.optedIntoLeaderboard {
                if let rankData = try await supabaseService.fetchUserRank(deviceId: userProfile.deviceId, monthYear: monthYear) {
                    currentUserRank = rankData.rank
                }
            }
            
            Log.info("Refreshed leaderboard: \(users.count) users")
        } catch {
            errorMessage = "Failed to load leaderboard: \(error.localizedDescription)"
            Log.error("Failed to refresh leaderboard: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Synchronization
    
    /// Sync user's stats to Supabase
    func syncToSupabase() async {
        guard userProfile.optedIntoLeaderboard else {
            Log.info("User not opted in, skipping sync")
            return
        }
        
        let monthYear = UserProfile.currentMonthYear
        
        // Check if new month - reset counter if needed
        if userProfile.isNewMonth {
            Log.info("New month detected, resetting session counter")
            userProfile.lastSyncedMonth = monthYear
            Self.saveProfile(userProfile, to: profileFileURL)
        }
        
        // Calculate this month's sessions
        let thisMonthSessions = calculateCurrentMonthSessions()
        
        do {
            try await supabaseService.syncUserStats(
                deviceId: userProfile.deviceId,
                username: userProfile.username,
                countryCode: userProfile.countryCode,
                totalSessions: thisMonthSessions,
                monthYear: monthYear
            )
            
            Log.info("Synced \(thisMonthSessions) sessions to Supabase")
            
            // Update last synced month
            userProfile.lastSyncedMonth = monthYear
            Self.saveProfile(userProfile, to: profileFileURL)
        } catch {
            Log.error("Failed to sync to Supabase: \(error.localizedDescription)")
            errorMessage = "Sync failed: \(error.localizedDescription)"
        }
    }
    
    /// Handle exercise completion notification
    private func handleExerciseCompletion() async {
        Log.info("Exercise completed, triggering sync")
        await syncToSupabase()
        
        // Refresh leaderboard to see updated rankings
        await refreshLeaderboard(force: true)
    }
    
    /// Calculate total sessions completed in the current month
    private func calculateCurrentMonthSessions() -> Int {
        let calendar = Calendar.current
        let now = Date()
        
        // Get start of current month
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }
        
        // Count completions in current month
        let thisMonthCompletions = exerciseStore.completions.filter { completion in
            completion.completedAt >= monthStart && completion.completedAt <= now
        }
        
        Log.info("Current month sessions: \(thisMonthCompletions.count)")
        return thisMonthCompletions.count
    }
    
    // MARK: - Public Helpers
    
    /// Check if user has joined the leaderboard
    var hasJoinedLeaderboard: Bool {
        userProfile.optedIntoLeaderboard && userProfile.hasCompletedSetup
    }
    
    /// Get user's current position in loaded leaderboard
    var userPositionInLeaderboard: Int? {
        guard hasJoinedLeaderboard else { return nil }
        return leaderboardUsers.firstIndex(where: { $0.id == userProfile.deviceId }).map { $0 + 1 }
    }
    
    /// Reset entire leaderboard in Supabase (TESTING ONLY)
    func resetLeaderboard() async {
        Log.info("⚠️ RESETTING ENTIRE LEADERBOARD - THIS WILL DELETE ALL DATA")
        
        do {
            // Clear local cache first
            leaderboardUsers = []
            saveCachedLeaderboard()
            
            // Delete ALL records across all months (nuclear option for testing)
            try await supabaseService.deleteAllLeaderboardEntries()
            
            Log.info("Successfully reset entire leaderboard")
            
            // Reset local profile so user can join again
            resetLocalProfileData()
            
        } catch {
            Log.error("Failed to reset leaderboard: \(error.localizedDescription)")
            errorMessage = "Failed to reset leaderboard"
        }
    }
    
    /// Reset only local profile (no network needed)
    func resetLocalProfile() async {
        Log.info("Resetting local profile only")
        resetLocalProfileData()
    }
    
    private func resetLocalProfileData() {
        userProfile.optedIntoLeaderboard = false
        userProfile.username = nil
        userProfile.countryCode = nil  // Reset country too
        userProfile.lastSyncedMonth = nil  // Reset sync tracking
        Self.saveProfile(userProfile, to: profileFileURL)
        
        leaderboardUsers = []
        saveCachedLeaderboard()
        
        Log.info("Reset local profile - user can join again")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    /// Posted when an exercise is completed
    static let exerciseCompleted = Notification.Name("exerciseCompleted")
}

