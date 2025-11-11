//
//  UserProfile.swift
//  ForwardNeckV1
//
//  Local user profile for leaderboard participation
//

import Foundation

/// Local user profile stored on device
struct UserProfile: Codable, Equatable {
    var deviceId: String
    var username: String?
    var countryCode: String?
    var optedIntoLeaderboard: Bool
    var lastSyncedMonth: String? // Track last synced month for monthly reset
    
    init(deviceId: String, username: String? = nil, countryCode: String? = nil, optedIntoLeaderboard: Bool = false, lastSyncedMonth: String? = nil) {
        self.deviceId = deviceId
        self.username = username
        self.countryCode = countryCode
        self.optedIntoLeaderboard = optedIntoLeaderboard
        self.lastSyncedMonth = lastSyncedMonth
    }
    
    /// Check if user has set up their profile for leaderboard
    var hasCompletedSetup: Bool {
        username != nil && !username!.isEmpty
    }
    
    /// Get current month-year string for comparison
    static var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
    
    /// Check if we're in a new month (for reset logic)
    var isNewMonth: Bool {
        guard let lastMonth = lastSyncedMonth else { return true }
        return lastMonth != Self.currentMonthYear
    }
}











