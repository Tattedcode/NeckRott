//
//  ChartsStore+Streak.swift
//  ForwardNeckV1
//
//  Streak history generation.
//

import Foundation

extension ChartsStore {
    func generateStreakOverTime() async {
        let calendar = Calendar.current
        let now = Date()
        var streakData: [ChartDataPoint] = []

        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) ?? now
            let dayLabel = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let streak = calculateStreakForDate(date)

            streakData.append(
                ChartDataPoint(
                    date: date,
                    value: Double(streak),
                    label: dayLabel
                )
            )
        }

        let maxStreak = streakData.map { Int($0.value) }.max() ?? 0
        let currentStreak = streakStore.currentStreak(for: .postureChecks)
        let averageStreak = streakData.map { $0.value }.reduce(0, +) / Double(streakData.count)

        streakOverTime = StreakOverTime(
            streakData: streakData.reversed(),
            maxStreak: maxStreak,
            currentStreak: currentStreak,
            averageStreak: averageStreak
        )

        Log.info("Generated streak over time data for \(streakData.count) days")
    }

    func calculateStreakForDate(_ date: Date) -> Int {
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
}
