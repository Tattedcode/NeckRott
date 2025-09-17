//
//  ChartsStore.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Store for managing charts and analytics data processing
/// Part of D-007: Stats and charts data (weekly/monthly)
/// Implements MVVM pattern for data management
@MainActor
final class ChartsStore: ObservableObject {
    /// Shared instance for singleton pattern
    static let shared = ChartsStore()
    
    /// Published properties for charts data - triggers UI updates when changed
    @Published private(set) var weeklyAnalytics: [WeeklyAnalytics] = []
    @Published private(set) var monthlyAnalytics: [MonthlyAnalytics] = []
    @Published private(set) var streakOverTime: StreakOverTime = StreakOverTime(streakData: [], maxStreak: 0, currentStreak: 0, averageStreak: 0.0)
    
    /// Store dependencies for data processing
    private let checkInStore: CheckInStore = CheckInStore.shared
    private let exerciseStore: ExerciseStore = ExerciseStore.shared
    private let streakStore: StreakStore = StreakStore.shared
    
    /// Initialize the charts store
    private init() {
        // Load initial data
        loadAnalyticsData()
    }
    
    /// Load all analytics data
    /// Part of F-007: Charts & Analytics feature
    func loadAnalyticsData() {
        Task {
            await generateWeeklyAnalytics()
            await generateMonthlyAnalytics()
            await generateStreakOverTime()
            Log.info("Loaded analytics data")
        }
    }
    
    /// Generate weekly analytics data
    /// - Parameter weeks: Number of weeks to generate (default: 4)
    private func generateWeeklyAnalytics() async {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [WeeklyAnalytics] = []
        
        // Generate data for the last 4 weeks
        for weekOffset in 0..<4 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? now
            
            let weekAnalytics = await calculateWeeklyAnalytics(weekStart: weekStart, weekEnd: weekEnd)
            weeklyData.append(weekAnalytics)
        }
        
        weeklyAnalytics = weeklyData.reversed() // Show oldest to newest
        Log.info("Generated \(weeklyData.count) weeks of analytics data")
    }
    
    /// Calculate analytics for a specific week
    /// - Parameters:
    ///   - weekStart: Start date of the week
    ///   - weekEnd: End date of the week
    /// - Returns: WeeklyAnalytics for the specified week
    private func calculateWeeklyAnalytics(weekStart: Date, weekEnd: Date) async -> WeeklyAnalytics {
        let calendar = Calendar.current
        let allCheckIns = await checkInStore.all()
        let allExercises = await exerciseStore.completions
        
        // Filter data for this week
        let weekCheckIns = allCheckIns.filter { checkIn in
            calendar.isDate(checkIn.timestamp, inSameDayAs: weekStart) || 
            calendar.isDate(checkIn.timestamp, inSameDayAs: weekEnd) ||
            (checkIn.timestamp > weekStart && checkIn.timestamp < weekEnd)
        }
        
        let weekExercises = allExercises.filter { exercise in
            calendar.isDate(exercise.completedAt, inSameDayAs: weekStart) || 
            calendar.isDate(exercise.completedAt, inSameDayAs: weekEnd) ||
            (exercise.completedAt > weekStart && exercise.completedAt < weekEnd)
        }
        
        // Calculate daily breakdown
        var dailyBreakdown: [DailyBreakdown] = []
        for dayOffset in 0..<7 {
            let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
            let dayOfWeek = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: dayDate) - 1]
            
            let dayCheckIns = weekCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: dayDate) }
            let dayExercises = weekExercises.filter { calendar.isDate($0.completedAt, inSameDayAs: dayDate) }
            
            let hadActivity = !dayCheckIns.isEmpty || !dayExercises.isEmpty
            
            dailyBreakdown.append(DailyBreakdown(
                date: dayDate,
                dayOfWeek: dayOfWeek,
                postureChecks: dayCheckIns.count,
                exercisesCompleted: dayExercises.count,
                hadActivity: hadActivity
            ))
        }
        
        // Calculate misses (assuming daily goal of 5 posture checks and 2 exercises)
        let dailyPostureGoal = 5
        let dailyExerciseGoal = 2
        let daysInWeek = 7
        
        let totalPostureGoal = dailyPostureGoal * daysInWeek
        let totalExerciseGoal = dailyExerciseGoal * daysInWeek
        
        let postureMisses = max(0, totalPostureGoal - weekCheckIns.count)
        let exerciseMisses = max(0, totalExerciseGoal - weekExercises.count)
        
        // Get current streak at the end of the week
        let currentStreak = streakStore.currentStreak(for: .postureChecks)
        
        return WeeklyAnalytics(
            weekStart: weekStart,
            weekEnd: weekEnd,
            postureChecks: weekCheckIns.count,
            postureMisses: postureMisses,
            exercisesCompleted: weekExercises.count,
            exercisesMissed: exerciseMisses,
            currentStreak: currentStreak,
            dailyBreakdown: dailyBreakdown
        )
    }
    
    /// Generate monthly analytics data
    /// - Parameter months: Number of months to generate (default: 6)
    private func generateMonthlyAnalytics() async {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [MonthlyAnalytics] = []
        
        // Generate data for the last 6 months
        for monthOffset in 0..<6 {
            let monthStart = calendar.date(byAdding: .month, value: -monthOffset, to: now) ?? now
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now) ?? now
            
            let monthAnalytics = await calculateMonthlyAnalytics(monthStart: monthStart, monthEnd: monthEnd)
            monthlyData.append(monthAnalytics)
        }
        
        monthlyAnalytics = monthlyData.reversed() // Show oldest to newest
        Log.info("Generated \(monthlyData.count) months of analytics data")
    }
    
    /// Calculate analytics for a specific month
    /// - Parameters:
    ///   - monthStart: Start date of the month
    ///   - monthEnd: End date of the month
    /// - Returns: MonthlyAnalytics for the specified month
    private func calculateMonthlyAnalytics(monthStart: Date, monthEnd: Date) async -> MonthlyAnalytics {
        let calendar = Calendar.current
        let allCheckIns = await checkInStore.all()
        let allExercises = await exerciseStore.completions
        
        // Filter data for this month
        let monthCheckIns = allCheckIns.filter { checkIn in
            checkIn.timestamp >= monthStart && checkIn.timestamp <= monthEnd
        }
        
        let monthExercises = allExercises.filter { exercise in
            exercise.completedAt >= monthStart && exercise.completedAt <= monthEnd
        }
        
        // Calculate averages
        let daysInMonth = calendar.dateComponents([.day], from: monthStart, to: monthEnd).day ?? 30
        let averageDailyPostureChecks = Double(monthCheckIns.count) / Double(daysInMonth)
        let averageDailyExercises = Double(monthExercises.count) / Double(daysInMonth)
        
        // Calculate active days
        let activeDays = Set(monthCheckIns.map { calendar.startOfDay(for: $0.timestamp) }).count
        
        // Get longest streak in the month
        let longestStreak = streakStore.longestStreak(for: .postureChecks)
        
        // Generate weekly breakdown for the month
        let weeklyBreakdown = await generateWeeklyBreakdownForMonth(monthStart: monthStart, monthEnd: monthEnd)
        
        let month = calendar.component(.month, from: monthStart)
        let year = calendar.component(.year, from: monthStart)
        
        return MonthlyAnalytics(
            month: month,
            year: year,
            totalPostureChecks: monthCheckIns.count,
            totalExercises: monthExercises.count,
            averageDailyPostureChecks: averageDailyPostureChecks,
            averageDailyExercises: averageDailyExercises,
            longestStreak: longestStreak,
            activeDays: activeDays,
            weeklyBreakdown: weeklyBreakdown
        )
    }
    
    /// Generate weekly breakdown for a month
    /// - Parameters:
    ///   - monthStart: Start date of the month
    ///   - monthEnd: End date of the month
    /// - Returns: Array of WeeklyAnalytics for the month
    private func generateWeeklyBreakdownForMonth(monthStart: Date, monthEnd: Date) async -> [WeeklyAnalytics] {
        let calendar = Calendar.current
        var weeklyBreakdown: [WeeklyAnalytics] = []
        
        var currentWeekStart = monthStart
        while currentWeekStart <= monthEnd {
            let currentWeekEnd = calendar.date(byAdding: .day, value: 6, to: currentWeekStart) ?? currentWeekStart
            let weekEnd = min(currentWeekEnd, monthEnd)
            
            let weekAnalytics = await calculateWeeklyAnalytics(weekStart: currentWeekStart, weekEnd: weekEnd)
            weeklyBreakdown.append(weekAnalytics)
            
            currentWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) ?? currentWeekStart
        }
        
        return weeklyBreakdown
    }
    
    /// Generate streak over time data
    /// - Parameter days: Number of days to generate (default: 30)
    private func generateStreakOverTime() async {
        let calendar = Calendar.current
        let now = Date()
        var streakData: [ChartDataPoint] = []
        
        // Generate data for the last 30 days
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) ?? now
            let dayLabel = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            // Calculate streak for this day
            let streak = calculateStreakForDate(date)
            
            streakData.append(ChartDataPoint(
                date: date,
                value: Double(streak),
                label: dayLabel
            ))
        }
        
        // Calculate statistics
        let maxStreak = streakData.map { Int($0.value) }.max() ?? 0
        let currentStreak = streakStore.currentStreak(for: .postureChecks)
        let averageStreak = streakData.map { $0.value }.reduce(0, +) / Double(streakData.count)
        
        streakOverTime = StreakOverTime(
            streakData: streakData.reversed(), // Show oldest to newest
            maxStreak: maxStreak,
            currentStreak: currentStreak,
            averageStreak: averageStreak
        )
        
        Log.info("Generated streak over time data for \(streakData.count) days")
    }
    
    /// Calculate streak for a specific date
    /// - Parameter date: Date to calculate streak for
    /// - Returns: Streak value for the date
    private func calculateStreakForDate(_ date: Date) -> Int {
        // This is a simplified calculation
        // In a real app, you'd want more sophisticated streak calculation
        let calendar = Calendar.current
        let allCheckIns = checkInStore.all()
        
        var streak = 0
        var currentDate = date
        
        while true {
            let dayCheckIns = allCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: currentDate) }
            if dayCheckIns.isEmpty {
                break
            }
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
    
    /// Get chart data for a specific chart type and time range
    /// - Parameters:
    ///   - chartType: Type of chart
    ///   - timeRange: Time range for the chart
    /// - Returns: Array of ChartDataPoint for the chart
    func getChartData(for chartType: ChartType, timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        switch chartType {
        case .weeklyBar:
            return getWeeklyBarChartData(timeRange: timeRange)
        case .streakLine:
            return getStreakLineChartData(timeRange: timeRange)
        case .monthlyBar:
            return getMonthlyBarChartData(timeRange: timeRange)
        }
    }
    
    /// Get weekly bar chart data
    /// - Parameter timeRange: Time range for the chart
    /// - Returns: Array of ChartDataPoint for weekly bar chart
    private func getWeeklyBarChartData(timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        let weeksToShow = min(timeRange.days / 7, weeklyAnalytics.count)
        let recentWeeks = Array(weeklyAnalytics.suffix(weeksToShow))
        
        return recentWeeks.enumerated().map { index, week in
            ChartDataPoint(
                date: week.weekStart,
                value: Double(week.postureChecks),
                label: "W\(index + 1)"
            )
        }
    }
    
    /// Get streak line chart data
    /// - Parameter timeRange: Time range for the chart
    /// - Returns: Array of ChartDataPoint for streak line chart
    private func getStreakLineChartData(timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        let daysToShow = min(timeRange.days, streakOverTime.streakData.count)
        return Array(streakOverTime.streakData.suffix(daysToShow))
    }
    
    /// Get monthly bar chart data
    /// - Parameter timeRange: Time range for the chart
    /// - Returns: Array of ChartDataPoint for monthly bar chart
    private func getMonthlyBarChartData(timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        let monthsToShow = min(timeRange.days / 30, monthlyAnalytics.count)
        let recentMonths = Array(monthlyAnalytics.suffix(monthsToShow))
        
        return recentMonths.enumerated().map { index, month in
            ChartDataPoint(
                date: Calendar.current.date(from: DateComponents(year: month.year, month: month.month)) ?? Date(),
                value: Double(month.totalPostureChecks),
                label: "M\(index + 1)"
            )
        }
    }
    
    /// Check if there's any data available for charts
    /// - Returns: True if there's data available, false otherwise
    func hasData() -> Bool {
        return !weeklyAnalytics.isEmpty || !monthlyAnalytics.isEmpty || !streakOverTime.streakData.isEmpty
    }
    
    /// Get empty state message for charts
    /// - Parameter chartType: Type of chart
    /// - Returns: Empty state message
    func getEmptyStateMessage(for chartType: ChartType) -> String {
        switch chartType {
        case .weeklyBar:
            return "No weekly data available. Start checking your posture to see your progress!"
        case .streakLine:
            return "No streak data available. Build a streak by checking your posture daily!"
        case .monthlyBar:
            return "No monthly data available. Keep using the app to see your monthly progress!"
        }
    }
}
