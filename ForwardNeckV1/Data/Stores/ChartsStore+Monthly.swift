//
//  ChartsStore+Monthly.swift
//  ForwardNeckV1
//
//  Monthly analytics generation.
//

import Foundation

extension ChartsStore {
    func generateMonthlyAnalytics() async {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [MonthlyAnalytics] = []

        for monthOffset in 0..<6 {
            let monthStart = calendar.date(byAdding: .month, value: -monthOffset, to: now) ?? now
            let monthEnd = calendar.date(byAdding: .day, value: -1, to: calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now) ?? now
            let monthAnalytics = await calculateMonthlyAnalytics(monthStart: monthStart, monthEnd: monthEnd)
            monthlyData.append(monthAnalytics)
        }

        monthlyAnalytics = monthlyData.reversed()
        Log.info("Generated \(monthlyData.count) months of analytics data")
    }

    func calculateMonthlyAnalytics(monthStart: Date, monthEnd: Date) async -> MonthlyAnalytics {
        let calendar = Calendar.current
        let allCheckIns = checkInStore.all()
        let allExercises = exerciseStore.completions

        let monthCheckIns = allCheckIns.filter { checkIn in
            checkIn.timestamp >= monthStart && checkIn.timestamp <= monthEnd
        }

        let monthExercises = allExercises.filter { exercise in
            exercise.completedAt >= monthStart && exercise.completedAt <= monthEnd
        }

        let daysInMonth = calendar.dateComponents([.day], from: monthStart, to: monthEnd).day ?? 30
        let averageDailyPostureChecks = Double(monthCheckIns.count) / Double(daysInMonth)
        let averageDailyExercises = Double(monthExercises.count) / Double(daysInMonth)
        let activeDays = Set(monthCheckIns.map { calendar.startOfDay(for: $0.timestamp) }).count
        let longestStreak = streakStore.longestStreak(for: .postureChecks)
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

    func generateWeeklyBreakdownForMonth(monthStart: Date, monthEnd: Date) async -> [WeeklyAnalytics] {
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
}
