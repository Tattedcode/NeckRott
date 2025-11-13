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
    /// IMPORTANT: Always use Gregorian calendar to ensure consistent month_year format across all devices
    /// This prevents issues when devices use different calendar systems (e.g., Buddhist Era vs Gregorian)
    static var currentMonthYear: String {
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.locale = Locale(identifier: "en_US_POSIX") // Use POSIX locale for consistent formatting
        
        let formatter = DateFormatter()
        formatter.calendar = gregorianCalendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM"
        
        let result = formatter.string(from: Date())
        Log.info("Generated month_year: \(result) (using Gregorian calendar)")
        return result
    }
    
    /// Check if we're in a new month (for reset logic)
    var isNewMonth: Bool {
        guard let lastMonth = lastSyncedMonth else { return true }
        return lastMonth != Self.currentMonthYear
    }
}











