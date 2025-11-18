//
//  UserProfile.swift
//  NeckRotV1
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
    
    enum CodingKeys: String, CodingKey {
        case deviceId
        case username
        case countryCode
        case optedIntoLeaderboard
        case lastSyncedMonth
    }
    
    /// Custom decoding to stay backwards-compatible with profiles saved
    /// before `optedIntoLeaderboard`/`lastSyncedMonth` existed. Those
    /// profiles only stored the username; treat that as an opt-in so
    /// existing users don't see the join prompt again.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deviceId = try container.decode(String.self, forKey: .deviceId)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        let storedOptedIn = try container.decodeIfPresent(Bool.self, forKey: .optedIntoLeaderboard)
        optedIntoLeaderboard = storedOptedIn ?? (username?.isEmpty == false)
        lastSyncedMonth = try container.decodeIfPresent(String.self, forKey: .lastSyncedMonth)
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










