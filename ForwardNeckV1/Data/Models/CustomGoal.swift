//
//  CustomGoal.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Model representing a custom goal set by the user
/// Part of D-006: Custom goals set by user
struct CustomGoal: Codable, Identifiable {
    /// Unique identifier for the goal
    let id: UUID
    
    /// Type of goal (e.g., daily checks, exercises, streaks)
    let type: GoalType
    
    /// Target value for the goal (e.g., 5 for "5 posture checks per day")
    let targetValue: Int
    
    /// Time period for the goal (e.g., daily, weekly, monthly)
    let timePeriod: GoalTimePeriod
    
    /// Title of the goal (e.g., "Daily Posture Checks")
    let title: String
    
    /// Description of the goal
    let description: String
    
    /// Whether the goal is currently active
    var isActive: Bool
    
    /// Date when the goal was created
    let createdAt: Date
    
    /// Date when the goal was last updated
    var updatedAt: Date
    
    /// Current progress towards the goal (0 to targetValue)
    var currentProgress: Int
    
    /// Whether the goal has been completed
    var isCompleted: Bool {
        return currentProgress >= targetValue
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0.0 }
        return min(1.0, Double(currentProgress) / Double(targetValue))
    }
    
    /// Initialize a custom goal
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - type: Type of goal
    ///   - targetValue: Target value for the goal
    ///   - timePeriod: Time period for the goal
    ///   - title: Title of the goal
    ///   - description: Description of the goal
    ///   - isActive: Whether the goal is active (defaults to true)
    ///   - createdAt: Date when created (defaults to now)
    ///   - updatedAt: Date when last updated (defaults to now)
    ///   - currentProgress: Current progress (defaults to 0)
    init(id: UUID = UUID(), type: GoalType, targetValue: Int, timePeriod: GoalTimePeriod, 
         title: String, description: String, isActive: Bool = true, createdAt: Date = Date(), 
         updatedAt: Date = Date(), currentProgress: Int = 0) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.timePeriod = timePeriod
        self.title = title
        self.description = description
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.currentProgress = currentProgress
    }
}

/// Types of goals that can be set
/// Part of F-006: Custom Goals feature
enum GoalType: String, Codable, CaseIterable, Identifiable {
    case dailyPostureChecks = "Daily Posture Checks"
    case dailyExercises = "Daily Exercises"
    case weeklyPostureChecks = "Weekly Posture Checks"
    case weeklyExercises = "Weekly Exercises"
    case streakDays = "Streak Days"
    case totalPostureChecks = "Total Posture Checks"
    case totalExercises = "Total Exercises"
    
    var id: String { rawValue }
    
    /// Icon system name for the goal type
    var iconSystemName: String {
        switch self {
        case .dailyPostureChecks, .weeklyPostureChecks, .totalPostureChecks:
            return "figure.walk"
        case .dailyExercises, .weeklyExercises, .totalExercises:
            return "dumbbell.fill"
        case .streakDays:
            return "flame.fill"
        }
    }
    
    /// Color for the goal type
    var color: String {
        switch self {
        case .dailyPostureChecks, .weeklyPostureChecks, .totalPostureChecks:
            return "#FF9500" // Orange
        case .dailyExercises, .weeklyExercises, .totalExercises:
            return "#34C759" // Green
        case .streakDays:
            return "#FF2D92" // Pink
        }
    }
    
    /// Default target value for the goal type
    var defaultTarget: Int {
        switch self {
        case .dailyPostureChecks:
            return 5
        case .dailyExercises:
            return 2
        case .weeklyPostureChecks:
            return 25
        case .weeklyExercises:
            return 10
        case .streakDays:
            return 7
        case .totalPostureChecks:
            return 100
        case .totalExercises:
            return 50
        }
    }
    
    /// Suggested time period for the goal type
    var suggestedTimePeriod: GoalTimePeriod {
        switch self {
        case .dailyPostureChecks, .dailyExercises:
            return .daily
        case .weeklyPostureChecks, .weeklyExercises:
            return .weekly
        case .streakDays:
            return .daily
        case .totalPostureChecks, .totalExercises:
            return .monthly
        }
    }
}

/// Time periods for goals
/// Part of F-006: Custom Goals feature
enum GoalTimePeriod: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
    
    /// Description of the time period
    var description: String {
        switch self {
        case .daily:
            return "Reset every day"
        case .weekly:
            return "Reset every week"
        case .monthly:
            return "Reset every month"
        case .yearly:
            return "Reset every year"
        }
    }
}

/// Default goals that are created when the user first uses the app
/// Part of F-006: Custom Goals feature
struct DefaultGoals {
    /// Create default goals for new users
    /// - Returns: Array of default custom goals
    static func create() -> [CustomGoal] {
        return [
            CustomGoal(
                type: .dailyPostureChecks,
                targetValue: GoalType.dailyPostureChecks.defaultTarget,
                timePeriod: GoalType.dailyPostureChecks.suggestedTimePeriod,
                title: "Daily Posture Checks",
                description: "Check your posture throughout the day"
            ),
            CustomGoal(
                type: .dailyExercises,
                targetValue: GoalType.dailyExercises.defaultTarget,
                timePeriod: GoalType.dailyExercises.suggestedTimePeriod,
                title: "Daily Exercises",
                description: "Complete posture exercises daily"
            ),
            CustomGoal(
                type: .streakDays,
                targetValue: GoalType.streakDays.defaultTarget,
                timePeriod: GoalType.streakDays.suggestedTimePeriod,
                title: "Streak Goal",
                description: "Maintain a daily streak"
            )
        ]
    }
}
