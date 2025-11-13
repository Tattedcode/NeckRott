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

        // XP is now awarded per exercise completion (2 XP each)
        // Only handle streak milestones here
        handleStreakProgress(currentStreak: currentStreak)
    }

    func resetTracking() {
        defaults.removeObject(forKey: Keys.lastGoalAwardDate)
    }

    // MARK: - Private Helpers

    // Daily goal and extra exercises XP removed - now 2 XP per exercise completion

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
