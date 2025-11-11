//
//  LeaderboardUser.swift
//  ForwardNeckV1
//
//  Represents a user on the global monthly leaderboard
//

import Foundation

/// Represents a user entry on the leaderboard
struct LeaderboardUser: Codable, Identifiable, Equatable {
    let id: String // device_id from Supabase
    let username: String?
    let countryCode: String?
    let totalSessions: Int
    let monthYear: String // Format: "2025-10"
    let lastUpdated: Date
    var rank: Int? // Calculated from query position, not stored in DB
    
    // Coding keys to match Supabase column names
    private enum CodingKeys: String, CodingKey {
        case id = "device_id"
        case username
        case countryCode = "country_code"
        case totalSessions = "total_sessions"
        case monthYear = "month_year"
        case lastUpdated = "last_updated"
    }
    
    init(id: String, username: String?, countryCode: String?, totalSessions: Int, monthYear: String, lastUpdated: Date, rank: Int? = nil) {
        self.id = id
        self.username = username
        self.countryCode = countryCode
        self.totalSessions = totalSessions
        self.monthYear = monthYear
        self.lastUpdated = lastUpdated
        self.rank = rank
    }
    
    /// Display name for the leaderboard (username or "Anonymous")
    var displayName: String {
        username ?? "Anonymous"
    }
    
    /// Country flag emoji based on country code
    var flagEmoji: String {
        guard let countryCode = countryCode else { return "🌍" }
        return countryCode.unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
    
    /// Medal emoji for top 3 positions
    var medalEmoji: String? {
        guard let rank = rank else { return nil }
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return nil
        }
    }
}











