//
//  ProgressTrackingViewModel.swift
//  ForwardNeckV1
//
//  ViewModel for progress tracking screen with real streak data
//  Part of B-004: Add F-004 Streaks & Progress on S-004 Progress Screen
//

import Foundation

struct DayBar: Identifiable {
    let id = UUID()
    let label: String // e.g., Mon, Tue
    let value: Int
}

enum ProgressRange: String, CaseIterable, Identifiable {
    case last7 = "7 Days"
    case last14 = "2 Weeks"
    case last30 = "1 Month"
    var id: String { rawValue }
}

@MainActor
final class ProgressTrackingViewModel: ObservableObject {
    // Store dependencies for real data
    private let checkInStore: CheckInStore = CheckInStore.shared
    private let exerciseStore: ExerciseStore = ExerciseStore.shared
    private let streakStore: StreakStore = StreakStore.shared
    private let chartsStore: ChartsStore = ChartsStore.shared
    
    // Daily goal stats shown in the ring
    @Published var completedToday: Int = 0
    @Published var dailyGoal: Int = 5
    
    // Streak statistics
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalPostureChecks: Int = 0
    @Published var totalExercises: Int = 0
    
    // Charts & Analytics data
    @Published var weeklyAnalytics: [WeeklyAnalytics] = []
    @Published var streakOverTime: StreakOverTime = StreakOverTime(streakData: [], maxStreak: 0, currentStreak: 0, averageStreak: 0.0)

    // Past posture check-ins for multiple ranges
    @Published var last7Days: [DayBar] = []
    @Published var last14Days: [DayBar] = []
    @Published var last30Days: [DayBar] = []

    // Selected range
    @Published var selectedRange: ProgressRange = .last7

    init() {
        loadData()
    }

    /// Load real data from stores and calculate statistics
    /// Part of F-004: Streaks & Progress feature
    func loadData() {
        Task {
            await loadStreakData()
            await loadChartData()
            await loadChartsData()
        }
    }
    
    /// Load streak statistics from stores
    /// Calculates current streak, longest streak, and totals
    private func loadStreakData() async {
        // Get all check-ins and exercise completions
        let allCheckIns = checkInStore.all()
        let allExercises = exerciseStore.completions
        
        // Update daily streaks based on real data
        let checkInDates = allCheckIns.map { $0.timestamp }
        let exerciseDates = allExercises.map { $0.completedAt }
        streakStore.updateDailyStreaks(checkIns: checkInDates, exerciseCompletions: exerciseDates)
        
        // Get combined streak statistics
        let stats = streakStore.getStats(for: .combined)
        currentStreak = stats.currentStreak
        longestStreak = stats.longestStreak
        totalPostureChecks = allCheckIns.count
        totalExercises = allExercises.count
        
        // Calculate today's progress
        await calculateTodaysProgress()
    }
    
    /// Calculate today's progress for the daily goal ring
    /// Counts check-ins and exercises completed today
    private func calculateTodaysProgress() async {
        let calendar = Calendar.current
        let today = Date()
        
        // Count today's check-ins
        let allCheckIns = checkInStore.all()
        let todaysCheckIns = allCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count
        
        // Count today's exercises
        let allExercises = exerciseStore.completions
        let _ = allExercises.filter { calendar.isDate($0.completedAt, inSameDayAs: today) }.count
        
        // For now, use check-ins as the primary metric for daily goal
        // In a real app, this could be configurable or combined
        completedToday = todaysCheckIns
    }
    
    /// Load chart data for different time ranges
    /// Creates DayBar data for 7, 14, and 30 day charts
    private func loadChartData() async {
        let calendar = Calendar.current
        let today = Date()
        
        // Load 7-day data
        last7Days = await createChartData(days: 7, from: today, calendar: calendar)
        
        // Load 14-day data
        last14Days = await createChartData(days: 14, from: today, calendar: calendar)
        
        // Load 30-day data
        last30Days = await createChartData(days: 30, from: today, calendar: calendar)
    }
    
    /// Create chart data for a specific number of days
    /// - Parameters:
    ///   - days: Number of days to include in the chart
    ///   - from: Starting date (usually today)
    ///   - calendar: Calendar instance for date calculations
    /// - Returns: Array of DayBar objects for the chart
    private func createChartData(days: Int, from: Date, calendar: Calendar) async -> [DayBar] {
        var chartData: [DayBar] = []
        
        for i in 0..<days {
            let date = calendar.date(byAdding: .day, value: -i, to: from) ?? from
            let dayLabel = formatDayLabel(for: date, index: i, totalDays: days)
            
            // Count check-ins for this day
            let allCheckIns = checkInStore.all()
            let dayCheckIns = allCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }.count
            
            chartData.append(DayBar(label: dayLabel, value: dayCheckIns))
        }
        
        // Reverse to show oldest to newest
        return chartData.reversed()
    }
    
    /// Format day label for chart display
    /// - Parameters:
    ///   - date: The date to format
    ///   - index: Index in the chart (0 = most recent)
    ///   - totalDays: Total number of days in the chart
    /// - Returns: Formatted day label
    private func formatDayLabel(for date: Date, index: Int, totalDays: Int) -> String {
        let formatter = DateFormatter()
        
        if totalDays <= 7 {
            // For 7 days, show day names (Mon, Tue, etc.)
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        } else if totalDays <= 14 {
            // For 14 days, show day numbers
            return "D\(totalDays - index)"
        } else {
            // For 30 days, show day numbers
            return "D\(totalDays - index)"
        }
    }

    var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(1, Double(completedToday) / Double(dailyGoal))
    }
    
    /// Load charts and analytics data
    /// Part of F-007: Charts & Analytics feature
    private func loadChartsData() async {
        // Load analytics data from ChartsStore
        chartsStore.loadAnalyticsData()
        
        // Update published properties
        weeklyAnalytics = chartsStore.weeklyAnalytics
        streakOverTime = chartsStore.streakOverTime
        
        Log.info("Loaded charts data: \(weeklyAnalytics.count) weeks, \(streakOverTime.streakData.count) streak points")
    }
}


