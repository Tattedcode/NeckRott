//
//  Streak.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Model representing a daily streak record
/// Part of D-004: Daily streak count
struct Streak: Codable, Identifiable, Equatable {
    /// Unique identifier for the streak record
    let id: UUID
    
    /// The date this streak record represents
    let date: Date
    
    /// Whether the user completed their daily goal on this date
    let completed: Bool
    
    /// The type of streak (posture checks, exercises, or combined)
    let type: StreakType
    
    /// Initialize a new streak record
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - date: The date this streak represents
    ///   - completed: Whether the goal was met on this date
    ///   - type: The type of streak being tracked
    init(id: UUID = UUID(), date: Date, completed: Bool, type: StreakType) {
        self.id = id
        self.date = date
        self.completed = completed
        self.type = type
    }
}

/// Types of streaks that can be tracked
/// Part of F-004: Streaks & Progress feature
enum StreakType: String, Codable, CaseIterable {
    /// Streak based on posture check-ins
    case postureChecks = "posture_checks"
    
    /// Streak based on exercise completions
    case exercises = "exercises"
    
    /// Combined streak (both posture checks and exercises)
    case combined = "combined"
    
    /// Human-readable display name for the streak type
    var displayName: String {
        switch self {
        case .postureChecks:
            return "Posture Checks"
        case .exercises:
            return "Exercises"
        case .combined:
            return "Combined"
        }
    }
}

/// Statistics about streaks and progress
/// Part of F-004: Streaks & Progress feature
struct StreakStats: Codable {
    /// Current active streak count
    let currentStreak: Int
    
    /// Longest streak ever achieved
    let longestStreak: Int
    
    /// Total number of days with completed goals
    let totalCompletedDays: Int
    
    /// Total number of posture checks completed
    let totalPostureChecks: Int
    
    /// Total number of exercises completed
    let totalExercises: Int
    
    /// The streak type these stats represent
    let type: StreakType
    
    /// Initialize streak statistics
    /// - Parameters:
    ///   - currentStreak: Current active streak count
    ///   - longestStreak: Longest streak ever achieved
    ///   - totalCompletedDays: Total days with completed goals
    ///   - totalPostureChecks: Total posture checks completed
    ///   - totalExercises: Total exercises completed
    ///   - type: The streak type these stats represent
    init(currentStreak: Int = 0, longestStreak: Int = 0, totalCompletedDays: Int = 0, 
         totalPostureChecks: Int = 0, totalExercises: Int = 0, type: StreakType) {
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalCompletedDays = totalCompletedDays
        self.totalPostureChecks = totalPostureChecks
        self.totalExercises = totalExercises
        self.type = type
    }
}
