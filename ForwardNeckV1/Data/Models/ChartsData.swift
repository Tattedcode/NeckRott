//
//  ChartsData.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Model representing chart data for analytics
/// Part of D-007: Stats and charts data (weekly/monthly)
struct ChartDataPoint: Codable, Identifiable {
    /// Unique identifier for the data point
    let id: UUID
    
    /// Date for this data point
    let date: Date
    
    /// Value for this data point
    let value: Double
    
    /// Label for this data point (e.g., "Mon", "Week 1")
    let label: String
    
    /// Initialize a chart data point
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - date: Date for this data point
    ///   - value: Value for this data point
    ///   - label: Label for this data point
    init(id: UUID = UUID(), date: Date, value: Double, label: String) {
        self.id = id
        self.date = date
        self.value = value
        self.label = label
    }
}

/// Model representing weekly analytics data
/// Part of F-007: Charts & Analytics feature
struct WeeklyAnalytics: Codable {
    /// Start date of the week
    let weekStart: Date
    
    /// End date of the week
    let weekEnd: Date
    
    /// Number of posture checks completed this week
    let postureChecks: Int
    
    /// Number of posture checks missed this week (based on daily goal)
    let postureMisses: Int
    
    /// Number of exercises completed this week
    let exercisesCompleted: Int
    
    /// Number of exercises missed this week (based on daily goal)
    let exercisesMissed: Int
    
    /// Current streak at the end of this week
    let currentStreak: Int
    
    /// Daily breakdown for the week
    let dailyBreakdown: [DailyBreakdown]
    
    /// Initialize weekly analytics
    /// - Parameters:
    ///   - weekStart: Start date of the week
    ///   - weekEnd: End date of the week
    ///   - postureChecks: Number of posture checks completed
    ///   - postureMisses: Number of posture checks missed
    ///   - exercisesCompleted: Number of exercises completed
    ///   - exercisesMissed: Number of exercises missed
    ///   - currentStreak: Current streak at the end of the week
    ///   - dailyBreakdown: Daily breakdown for the week
    init(weekStart: Date, weekEnd: Date, postureChecks: Int, postureMisses: Int, 
         exercisesCompleted: Int, exercisesMissed: Int, currentStreak: Int, 
         dailyBreakdown: [DailyBreakdown]) {
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.postureChecks = postureChecks
        self.postureMisses = postureMisses
        self.exercisesCompleted = exercisesCompleted
        self.exercisesMissed = exercisesMissed
        self.currentStreak = currentStreak
        self.dailyBreakdown = dailyBreakdown
    }
}

/// Model representing daily breakdown within a week
/// Part of F-007: Charts & Analytics feature
struct DailyBreakdown: Codable, Identifiable {
    /// Unique identifier for the day
    let id: UUID
    
    /// Date for this day
    let date: Date
    
    /// Day of week (e.g., "Mon", "Tue")
    let dayOfWeek: String
    
    /// Number of posture checks completed this day
    let postureChecks: Int
    
    /// Number of exercises completed this day
    let exercisesCompleted: Int
    
    /// Whether this day had any activity
    let hadActivity: Bool
    
    /// Initialize daily breakdown
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID)
    ///   - date: Date for this day
    ///   - dayOfWeek: Day of week
    ///   - postureChecks: Number of posture checks completed
    ///   - exercisesCompleted: Number of exercises completed
    ///   - hadActivity: Whether this day had any activity
    init(id: UUID = UUID(), date: Date, dayOfWeek: String, postureChecks: Int, 
         exercisesCompleted: Int, hadActivity: Bool) {
        self.id = id
        self.date = date
        self.dayOfWeek = dayOfWeek
        self.postureChecks = postureChecks
        self.exercisesCompleted = exercisesCompleted
        self.hadActivity = hadActivity
    }
}

/// Model representing streak over time data
/// Part of F-007: Charts & Analytics feature
struct StreakOverTime: Codable {
    /// Array of streak data points over time
    let streakData: [ChartDataPoint]
    
    /// Maximum streak value in the dataset
    let maxStreak: Int
    
    /// Current streak value
    let currentStreak: Int
    
    /// Average streak value
    let averageStreak: Double
    
    /// Initialize streak over time data
    /// - Parameters:
    ///   - streakData: Array of streak data points
    ///   - maxStreak: Maximum streak value
    ///   - currentStreak: Current streak value
    ///   - averageStreak: Average streak value
    init(streakData: [ChartDataPoint], maxStreak: Int, currentStreak: Int, averageStreak: Double) {
        self.streakData = streakData
        self.maxStreak = maxStreak
        self.currentStreak = currentStreak
        self.averageStreak = averageStreak
    }
}

/// Model representing monthly analytics data
/// Part of D-007: Stats and charts data (weekly/monthly)
struct MonthlyAnalytics: Codable {
    /// Month and year for this analytics data
    let month: Int
    let year: Int
    
    /// Total posture checks for the month
    let totalPostureChecks: Int
    
    /// Total exercises completed for the month
    let totalExercises: Int
    
    /// Average daily posture checks
    let averageDailyPostureChecks: Double
    
    /// Average daily exercises
    let averageDailyExercises: Double
    
    /// Longest streak in the month
    let longestStreak: Int
    
    /// Number of active days (days with at least one activity)
    let activeDays: Int
    
    /// Weekly breakdown for the month
    let weeklyBreakdown: [WeeklyAnalytics]
    
    /// Initialize monthly analytics
    /// - Parameters:
    ///   - month: Month number (1-12)
    ///   - year: Year
    ///   - totalPostureChecks: Total posture checks for the month
    ///   - totalExercises: Total exercises for the month
    ///   - averageDailyPostureChecks: Average daily posture checks
    ///   - averageDailyExercises: Average daily exercises
    ///   - longestStreak: Longest streak in the month
    ///   - activeDays: Number of active days
    ///   - weeklyBreakdown: Weekly breakdown for the month
    init(month: Int, year: Int, totalPostureChecks: Int, totalExercises: Int, 
         averageDailyPostureChecks: Double, averageDailyExercises: Double, 
         longestStreak: Int, activeDays: Int, weeklyBreakdown: [WeeklyAnalytics]) {
        self.month = month
        self.year = year
        self.totalPostureChecks = totalPostureChecks
        self.totalExercises = totalExercises
        self.averageDailyPostureChecks = averageDailyPostureChecks
        self.averageDailyExercises = averageDailyExercises
        self.longestStreak = longestStreak
        self.activeDays = activeDays
        self.weeklyBreakdown = weeklyBreakdown
    }
}

/// Chart type enumeration
/// Part of F-007: Charts & Analytics feature
enum ChartType: String, CaseIterable, Identifiable {
    case weeklyBar = "Weekly Bar Chart"
    case streakLine = "Streak Line Chart"
    case monthlyBar = "Monthly Bar Chart"
    
    var id: String { rawValue }
    
    /// Icon system name for the chart type
    var iconSystemName: String {
        switch self {
        case .weeklyBar, .monthlyBar:
            return "chart.bar"
        case .streakLine:
            return "chart.line.uptrend.xyaxis"
        }
    }
    
    /// Description of the chart type
    var description: String {
        switch self {
        case .weeklyBar:
            return "Posture checks vs misses this week"
        case .streakLine:
            return "Streak progression over time"
        case .monthlyBar:
            return "Monthly activity summary"
        }
    }
}

/// Time range for analytics
/// Part of F-007: Charts & Analytics feature
enum AnalyticsTimeRange: String, CaseIterable, Identifiable {
    case week = "1 Week"
    case month = "1 Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case year = "1 Year"
    
    var id: String { rawValue }
    
    /// Number of days for this time range
    var days: Int {
        switch self {
        case .week:
            return 7
        case .month:
            return 30
        case .threeMonths:
            return 90
        case .sixMonths:
            return 180
        case .year:
            return 365
        }
    }
}
