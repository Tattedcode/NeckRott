//
//  LeaderboardViewModel.swift
//  ForwardNeckV1
//
//  ViewModel for managing leaderboard UI state and actions
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for the leaderboard view
/// Handles data fetching, user profile updates, and UI state
@MainActor
@Observable
final class LeaderboardViewModel {
    // Dependencies
    private let leaderboardStore = LeaderboardStore.shared
    
    // UI State
    var showingUsernameSheet: Bool = false
    var showingError: Bool = false
    var showingResetAlert: Bool = false
    var resetStatusMessage: String = ""
    
    // Local state that mirrors store properties (for @Observable reactivity)
    // These will be updated when the store changes
    private var _leaderboardUsers: [LeaderboardUser] = []
    private var _userProfile: UserProfile
    private var _currentUserRank: Int?
    private var _isLoading: Bool = false
    private var _errorMessage: String?
    private var _lastRefreshDate: Date?
    
    // Computed properties that return local state (which updates when store changes)
    var leaderboardUsers: [LeaderboardUser] {
        _leaderboardUsers
    }
    
    var userProfile: UserProfile {
        _userProfile
    }
    
    var currentUserRank: Int? {
        _currentUserRank
    }
    
    var isLoading: Bool {
        _isLoading
    }
    
    var errorMessage: String? {
        _errorMessage
    }
    
    var hasJoinedLeaderboard: Bool {
        leaderboardStore.hasJoinedLeaderboard
    }
    
    var lastRefreshDate: Date? {
        _lastRefreshDate
    }
    
    // Combine subscriptions to observe store changes
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        // Initialize local state from store
        _leaderboardUsers = leaderboardStore.leaderboardUsers
        _userProfile = leaderboardStore.userProfile
        _currentUserRank = leaderboardStore.currentUserRank
        _isLoading = leaderboardStore.isLoading
        _errorMessage = leaderboardStore.errorMessage
        _lastRefreshDate = leaderboardStore.lastRefreshDate
        
        // Observe store changes and update local state
        // This ensures @Observable triggers UI updates when store changes
        observeStoreChanges()
        
        Log.info("LeaderboardViewModel initialized")
    }
    
    /// Set up Combine subscriptions to observe store changes
    /// This ensures the ViewModel updates when the store changes
    private func observeStoreChanges() {
        // Observe leaderboardUsers changes
        leaderboardStore.$leaderboardUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                self?._leaderboardUsers = users
                Log.info("LeaderboardViewModel: Updated leaderboardUsers (\(users.count) users)")
            }
            .store(in: &cancellables)
        
        // Observe userProfile changes (this is the key fix!)
        leaderboardStore.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?._userProfile = profile
                Log.info("LeaderboardViewModel: Updated userProfile (username: \(profile.username ?? "nil"))")
            }
            .store(in: &cancellables)
        
        // Observe currentUserRank changes
        leaderboardStore.$currentUserRank
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rank in
                self?._currentUserRank = rank
            }
            .store(in: &cancellables)
        
        // Observe isLoading changes
        leaderboardStore.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?._isLoading = loading
            }
            .store(in: &cancellables)
        
        // Observe errorMessage changes
        leaderboardStore.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?._errorMessage = error
            }
            .store(in: &cancellables)
        
        // Observe lastRefreshDate changes
        leaderboardStore.$lastRefreshDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?._lastRefreshDate = date
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    /// Called when view appears
    func onAppear() async {
        Log.info("LeaderboardView appeared")
        await refreshLeaderboard()
    }
    
    /// Refresh leaderboard data
    func refreshLeaderboard() async {
        Log.info("🔄 Manual refresh triggered")
        await leaderboardStore.refreshLeaderboard(force: true)
        
        if let error = errorMessage {
            showingError = true
            Log.error("Error refreshing leaderboard: \(error)")
        } else {
            Log.info("✅ Refresh completed. Found \(leaderboardUsers.count) users")
        }
    }
    
    /// Manually sync current user's stats and refresh leaderboard
    func syncAndRefresh() async {
        Log.info("🔄 Manual sync and refresh triggered")
        await leaderboardStore.syncToSupabase()
        await refreshLeaderboard()
    }
    
    /// Show username setup sheet
    func showUsernameSheet() {
        showingUsernameSheet = true
    }
    
    /// Save username and opt into leaderboard
    func saveUsername(_ username: String, countryCode: String?) async {
        Log.info("Saving username: \(username)")
        
        await leaderboardStore.updateProfile(
            username: username,
            countryCode: countryCode,
            optedIn: true
        )
        
        showingUsernameSheet = false
        
        // Refresh leaderboard after joining
        await refreshLeaderboard()
    }
    
    // MARK: - Helpers
    
    /// Format last refresh time for display
    var lastRefreshText: String {
        guard let lastRefresh = lastRefreshDate else {
            return "Never updated"
        }
        
        let secondsAgo = Int(Date().timeIntervalSince(lastRefresh))
        
        if secondsAgo < 60 {
            return "Updated just now"
        } else if secondsAgo < 3600 {
            let minutes = secondsAgo / 60
            return "Updated \(minutes)m ago"
        } else {
            let hours = secondsAgo / 3600
            return "Updated \(hours)h ago"
        }
    }
    
    /// Get top 3 users for podium display
    var topThreeUsers: [LeaderboardUser] {
        Array(leaderboardUsers.prefix(3))
    }
    
    /// Get remaining users (after top 3)
    var remainingUsers: [LeaderboardUser] {
        Array(leaderboardUsers.dropFirst(3))
    }
    
    /// Check if a user is the current device user
    func isCurrentUser(_ user: LeaderboardUser) -> Bool {
        user.id == userProfile.deviceId
    }
    
    /// Reset entire leaderboard (TESTING ONLY)
    func resetLeaderboard() async {
        Log.info("🚨 RESETTING LEADERBOARD - TESTING MODE")
        resetStatusMessage = "Resetting leaderboard..."
        
        do {
            await leaderboardStore.resetLeaderboard()
            
            // Small delay to ensure deletion completes
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Refresh to show empty leaderboard
            await refreshLeaderboard()
            
            resetStatusMessage = "Leaderboard reset successfully!"
            showingResetAlert = true
            
            Log.info("✅ Reset complete")
        } catch {
            resetStatusMessage = "Error resetting leaderboard: \(error.localizedDescription)"
            showingResetAlert = true
            Log.error("❌ Reset failed: \(error.localizedDescription)")
        }
    }
    
    /// Reset LOCAL profile only (no network needed)
    func resetLocalProfile() {
        Log.info("🔄 Resetting local profile only")
        Task {
            await leaderboardStore.resetLocalProfile()
            resetStatusMessage = "Local profile reset! You can join again."
            showingResetAlert = true
        }
    }
    
    /// Delete a specific user from the leaderboard
    /// - Parameters:
    ///   - deviceId: Device ID of the user to delete
    ///   - monthYear: Optional month. If nil, deletes from all months
    func deleteUser(deviceId: String, monthYear: String? = nil) async {
        Log.info("Deleting user: \(deviceId)")
        do {
            try await leaderboardStore.deleteUser(deviceId: deviceId, monthYear: monthYear)
            resetStatusMessage = "User deleted successfully"
            showingResetAlert = true
        } catch {
            resetStatusMessage = "Failed to delete user: \(error.localizedDescription)"
            showingResetAlert = true
            Log.error("Failed to delete user: \(error)")
        }
    }
}

