//
//  LeaderboardViewModel.swift
//  ForwardNeckV1
//
//  ViewModel for managing leaderboard UI state and actions
//

import Foundation
import SwiftUI

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
    
    // Computed properties from store
    var leaderboardUsers: [LeaderboardUser] {
        leaderboardStore.leaderboardUsers
    }
    
    var userProfile: UserProfile {
        leaderboardStore.userProfile
    }
    
    var currentUserRank: Int? {
        leaderboardStore.currentUserRank
    }
    
    var isLoading: Bool {
        leaderboardStore.isLoading
    }
    
    var errorMessage: String? {
        leaderboardStore.errorMessage
    }
    
    var hasJoinedLeaderboard: Bool {
        leaderboardStore.hasJoinedLeaderboard
    }
    
    var lastRefreshDate: Date? {
        leaderboardStore.lastRefreshDate
    }
    
    // MARK: - Initialization
    
    init() {
        Log.info("LeaderboardViewModel initialized")
    }
    
    // MARK: - Actions
    
    /// Called when view appears
    func onAppear() async {
        Log.info("LeaderboardView appeared")
        await refreshLeaderboard()
    }
    
    /// Refresh leaderboard data
    func refreshLeaderboard() async {
        await leaderboardStore.refreshLeaderboard()
        
        if let error = errorMessage {
            showingError = true
            Log.error("Error refreshing leaderboard: \(error)")
        }
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
}

