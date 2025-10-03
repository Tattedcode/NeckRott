//
//  ChartsStore.swift
//  ForwardNeckV1
//
//  Central store for analytics and chart data.
//

import Foundation

@MainActor
final class ChartsStore: ObservableObject {
    static let shared = ChartsStore()

    @Published var weeklyAnalytics: [WeeklyAnalytics] = []
    @Published var monthlyAnalytics: [MonthlyAnalytics] = []
    @Published var streakOverTime: StreakOverTime = .init(streakData: [], maxStreak: 0, currentStreak: 0, averageStreak: 0.0)

    let checkInStore = CheckInStore.shared
    let exerciseStore = ExerciseStore.shared
    let streakStore = StreakStore.shared

    private init() {
        loadAnalyticsData()
    }

    func loadAnalyticsData() {
        Task {
            await generateWeeklyAnalytics()
            await generateMonthlyAnalytics()
            await generateStreakOverTime()
            Log.info("Loaded analytics data")
        }
    }
}
