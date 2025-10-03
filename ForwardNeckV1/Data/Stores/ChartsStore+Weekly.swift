//
//  ChartsStore+Weekly.swift
//  ForwardNeckV1
//
//  Weekly analytics generation.
//

import Foundation

extension ChartsStore {
    func generateWeeklyAnalytics() async {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [WeeklyAnalytics] = []

        for weekOffset in 0..<4 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: now) ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? now
            let weekAnalytics = await calculateWeeklyAnalytics(weekStart: weekStart, weekEnd: weekEnd)
            weeklyData.append(weekAnalytics)
        }

        weeklyAnalytics = weeklyData.reversed()
        Log.info("Generated \(weeklyData.count) weeks of analytics data")
    }

    func calculateWeeklyAnalytics(weekStart: Date, weekEnd: Date) async -> WeeklyAnalytics {
        let calendar = Calendar.current
        let allCheckIns = await checkInStore.all()
        let allExercises = await exerciseStore.completions

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

        var dailyBreakdown: [DailyBreakdown] = []
        for dayOffset in 0..<7 {
            let dayDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
            let dayOfWeek = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: dayDate) - 1]

            let dayCheckIns = weekCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: dayDate) }
            let dayExercises = weekExercises.filter { calendar.isDate($0.completedAt, inSameDayAs: dayDate) }
            let hadActivity = !dayCheckIns.isEmpty || !dayExercises.isEmpty

            dailyBreakdown.append(
                DailyBreakdown(
                    date: dayDate,
                    dayOfWeek: dayOfWeek,
                    postureChecks: dayCheckIns.count,
                    exercisesCompleted: dayExercises.count,
                    hadActivity: hadActivity
                )
            )
        }

        let dailyPostureGoal = 5
        let dailyExerciseGoal = 2
        let daysInWeek = 7

        let postureMisses = max(0, dailyPostureGoal * daysInWeek - weekCheckIns.count)
        let exerciseMisses = max(0, dailyExerciseGoal * daysInWeek - weekExercises.count)
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
}
