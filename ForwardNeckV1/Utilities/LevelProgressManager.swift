import Foundation

@MainActor
final class LevelProgressManager {
    static let shared = LevelProgressManager()

    private let defaults = UserDefaults.standard
    private let calendar = Calendar.current
    private let gamificationStore = GamificationStore.shared

    private struct Keys {
        static let lastGoalAwardDate = "xp.lastGoalAwardDate"
        static let lastExtraAwardDate = "xp.lastExtraAwardDate"
        static let extraAwardCount = "xp.extraAwardCount"
        static let highestStreakAwarded = "xp.highestStreakAwarded"
    }

    private init() {}

    func processDailyProgress(date: Date, dailyGoal: Int, completions: Int, currentStreak: Int) {
        guard calendar.isDateInToday(date) else { return }

        if dailyGoal > 0 {
            handleDailyGoal(date: date, dailyGoal: dailyGoal, completions: completions)
            handleExtraExercises(date: date, dailyGoal: dailyGoal, completions: completions)
        }

        handleStreakProgress(currentStreak: currentStreak)
    }

    func resetTracking() {
        defaults.removeObject(forKey: Keys.lastGoalAwardDate)
        defaults.removeObject(forKey: Keys.lastExtraAwardDate)
        defaults.removeObject(forKey: Keys.extraAwardCount)
        defaults.removeObject(forKey: Keys.highestStreakAwarded)
    }

    // MARK: - Private Helpers

    private func handleDailyGoal(date: Date, dailyGoal: Int, completions: Int) {
        let todayKey = dayKey(for: date)
        let lastAward = defaults.string(forKey: Keys.lastGoalAwardDate)

        guard completions >= dailyGoal, lastAward != todayKey else { return }

        gamificationStore.addXP(25, source: "Daily goal completed")
        defaults.set(todayKey, forKey: Keys.lastGoalAwardDate)
    }

    private func handleExtraExercises(date: Date, dailyGoal: Int, completions: Int) {
        guard completions > dailyGoal else { return }

        let todayKey = dayKey(for: date)
        let lastExtraDate = defaults.string(forKey: Keys.lastExtraAwardDate)
        var extrasAwarded = defaults.integer(forKey: Keys.extraAwardCount)

        if lastExtraDate != todayKey {
            extrasAwarded = 0
        }

        let extrasCompleted = completions - dailyGoal
        let newExtras = extrasCompleted - extrasAwarded
        guard newExtras > 0 else { return }

        let xpToAward = newExtras * 5
        gamificationStore.addXP(xpToAward, source: "Extra exercises")

        defaults.set(todayKey, forKey: Keys.lastExtraAwardDate)
        defaults.set(extrasCompleted, forKey: Keys.extraAwardCount)
    }

    private func handleStreakProgress(currentStreak: Int) {
        let thresholds: [(value: Int, xp: Int)] = [
            (3, 40),
            (7, 60),
            (14, 90),
            (30, 140),
            (60, 200),
            (90, 260)
        ]

        var highestAwarded = defaults.integer(forKey: Keys.highestStreakAwarded)

        for threshold in thresholds where currentStreak >= threshold.value && highestAwarded < threshold.value {
            gamificationStore.addXP(threshold.xp, source: "Streak milestone \(threshold.value)")
            highestAwarded = threshold.value
            defaults.set(highestAwarded, forKey: Keys.highestStreakAwarded)
        }
    }

    private func dayKey(for date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
    }
}
