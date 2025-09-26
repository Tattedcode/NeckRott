//
//  Gamification.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation
import SwiftUI

/// Model representing a user's gamification progress
/// Part of D-005: XP points and level
struct UserProgress: Codable, Identifiable {
    /// Unique identifier for the user progress record
    let id: UUID
    
    /// Current experience points
    var xp: Int
    
    /// Current level
    var level: Int
    
    /// Total XP earned (for statistics)
    var totalXpEarned: Int
    
    /// Date when progress was last updated
    var lastUpdated: Date
    
    /// Initialize user progress with default values
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - xp: Current experience points (defaults to 0)
    ///   - level: Current level (defaults to 1)
    ///   - totalXpEarned: Total XP earned (defaults to 0)
    ///   - lastUpdated: Last update date (defaults to now)
    init(id: UUID = UUID(), xp: Int = 0, level: Int = 1,
         totalXpEarned: Int = 0, lastUpdated: Date = Date()) {
        self.id = id
        self.xp = xp
        self.level = level
        self.totalXpEarned = totalXpEarned
        self.lastUpdated = lastUpdated
    }
}

/// Model representing a level in the gamification system
/// Part of F-005: Gamification feature
struct Level: Codable, Identifiable {
    /// Unique identifier for the level
    let id: Int
    
    /// Level number (1, 2, 3, etc.)
    let number: Int
    
    /// XP required to reach this level
    let xpRequired: Int
    
    /// Title/name of the level
    let title: String
    
    /// Description of the level achievement
    let description: String
    
    /// Icon system name for the level
    let iconSystemName: String
    
    /// Color for the level (as hex string)
    let colorHex: String
    
    /// Initialize a level
    /// - Parameters:
    ///   - id: Unique identifier for the level
    ///   - number: Level number
    ///   - xpRequired: XP required to reach this level
    ///   - title: Title of the level
    ///   - description: Description of the level
    ///   - iconSystemName: Icon system name
    ///   - colorHex: Color as hex string
    init(id: Int, number: Int, xpRequired: Int, title: String,
         description: String, iconSystemName: String, colorHex: String) {
        self.id = id
        self.number = number
        self.xpRequired = xpRequired
        self.title = title
        self.description = description
        self.iconSystemName = iconSystemName
        self.colorHex = colorHex
    }
    
    /// Get the color from hex string
    var color: Color {
        return Color(hex: colorHex) ?? .blue
    }
}

/// Model representing an achievement that can be unlocked
/// Part of F-005: Gamification feature
struct Achievement: Codable, Identifiable {
    /// Unique identifier for the achievement
    let id: UUID
    
    /// Title of the achievement
    let title: String
    
    /// Description of what needs to be done
    let description: String
    
    /// XP reward for unlocking this achievement
    let xpReward: Int
    
    /// Icon system name for the achievement
    let iconSystemName: String
    
    /// Color for the achievement (as hex string)
    let colorHex: String
    
    /// Whether this achievement has been unlocked
    var isUnlocked: Bool
    
    /// Date when achievement was unlocked (nil if not unlocked)
    var unlockedAt: Date?
    
    /// Initialize an achievement
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - title: Title of the achievement
    ///   - description: Description of the achievement
    ///   - xpReward: XP reward for unlocking
    ///   - iconSystemName: Icon system name
    ///   - colorHex: Color as hex string
    ///   - isUnlocked: Whether achievement is unlocked (defaults to false)
    ///   - unlockedAt: Date when unlocked (defaults to nil)
    init(id: UUID = UUID(), title: String, description: String, xpReward: Int,
         iconSystemName: String, colorHex: String,
         isUnlocked: Bool = false, unlockedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.xpReward = xpReward
        self.iconSystemName = iconSystemName
        self.colorHex = colorHex
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
    
    /// Get the color from hex string
    var color: Color {
        return Color(hex: colorHex) ?? .blue
    }
}

/// Model representing a reward unlocked via levels
/// Part of F-005: Gamification feature
struct Reward: Codable, Identifiable {
    /// Unique identifier for the reward
    let id: UUID

    /// Title of the reward
    let title: String

    /// Description of the reward
    let description: String

    /// Icon system name for the reward
    let iconSystemName: String

    /// Color for the reward (as hex string)
    let colorHex: String

    /// Whether this reward has been unlocked
    var isUnlocked: Bool

    /// Date when reward was unlocked (nil if locked)
    var unlockedAt: Date?

    /// Initialize a reward
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - title: Title of the reward
    ///   - description: Description of the reward
    ///   - iconSystemName: Icon system name
    ///   - colorHex: Color as hex string
    ///   - isUnlocked: Whether reward is unlocked (defaults to false)
    ///   - unlockedAt: Date when unlocked (defaults to nil)
    init(id: UUID = UUID(), title: String, description: String,
         iconSystemName: String, colorHex: String, isUnlocked: Bool = false,
         unlockedAt: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.iconSystemName = iconSystemName
        self.colorHex = colorHex
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
    }
}

/// Extension to create Color from hex string
/// Part of F-005: Gamification feature
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
