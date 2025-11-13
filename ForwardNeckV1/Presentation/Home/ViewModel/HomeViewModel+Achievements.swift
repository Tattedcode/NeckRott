//
//  HomeViewModel+Achievements.swift
//  ForwardNeckV1
//
//  Achievement tracking and persistence helpers.
//

import Foundation
import SwiftUI

extension HomeViewModel {
    func updateMonthlyAchievements(skipCelebration: Bool) {
        var updated = monthlyAchievements
        guard !updated.isEmpty else { return }

        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now

        let completions = exerciseStore.completions.filter { $0.completedAt <= now }
        let completionsThisMonth = completions.filter { completion in
            completion.completedAt >= startOfMonth && completion.completedAt < startOfNextMonth
        }
        let completionsToday = completions.filter { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: now)
        }
        let completionsTodayCount = completionsToday.count
        let currentPostureStreak = streakStore.currentStreak(for: .postureChecks)
        let totalCompletions = completions.count
        let monthlyCompletionCount = completionsThisMonth.count
        let dailyGoal = userStore.dailyGoal

        // Collect ALL newly unlocked achievements (not just the first one)
        var newlyUnlockedAchievements: [MonthlyAchievement] = []

        for index in updated.indices {
            let kind = updated[index].kind
            let wasUnlocked = updated[index].isUnlocked || unlockedAchievementKinds.contains(kind)

            let isUnlocked: Bool = {
                switch kind {
                case .firstExercise:
                    return monthlyCompletionCount >= 1
                case .dailyStreakStarted:
                    // Unlock as soon as a streak is started (1 day)
                    return currentPostureStreak >= 1
                case .fifteenDayStreak:
                    return currentPostureStreak >= 15
                case .fullMonthStreak:
                    return currentPostureStreak >= 30
                case .weeklyStreak:
                    return currentPostureStreak >= 7
                case .tenCompleted:
                    return totalCompletions >= 10
                case .twentyCompleted:
                    return totalCompletions >= 20
                }
            }()

            if isUnlocked { unlockedAchievementKinds.insert(kind) }
            updated[index].isUnlocked = unlockedAchievementKinds.contains(kind)

            if isUnlocked && skipCelebration && !shownAchievementKinds.contains(kind) {
                shownAchievementKinds.insert(kind)
            }

            // Collect all newly unlocked achievements (not just the first one)
            if !skipCelebration,
               isUnlocked,
               !wasUnlocked,
               !shownAchievementKinds.contains(kind) {
                newlyUnlockedAchievements.append(updated[index])
            }
        }

        monthlyAchievements = updated
        
        // Add all newly unlocked achievements to the queue
        // They will be shown one at a time when the user dismisses each sheet
        if !newlyUnlockedAchievements.isEmpty {
            Log.info("Found \(newlyUnlockedAchievements.count) newly unlocked achievement(s)")
            for achievement in newlyUnlockedAchievements {
                enqueueAchievement(achievement)
            }
        }
    }
    
    // MARK: - Testing Helper
    
    /// Unlock the next locked achievement for testing purposes
    func unlockNextAchievement() {
        // Find the first locked achievement
        if let nextAchievement = monthlyAchievements.first(where: { !$0.isUnlocked }) {
            unlockedAchievementKinds.insert(nextAchievement.kind)
            updateMonthlyAchievements(skipCelebration: true)
            Log.info("Test: Unlocked achievement \(nextAchievement.kind.title)")
        } else {
            Log.info("Test: All achievements are already unlocked")
        }
    }

    static func loadShownAchievementsForCurrentMonth(key: String, monthKey: String) -> Set<MonthlyAchievementKind> {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        let storedMonth = UserDefaults.standard.integer(forKey: monthKey + ".shown.month")
        let storedYear = UserDefaults.standard.integer(forKey: monthKey + ".shown.year")
        guard storedMonth == currentMonth, storedYear == currentYear,
              let data = UserDefaults.standard.data(forKey: key),
              let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(rawValues.compactMap { MonthlyAchievementKind(rawValue: $0) })
    }

    static func loadUnlockedAchievementsForCurrentMonth(key: String, monthKey: String) -> Set<MonthlyAchievementKind> {
        let calendar = Calendar.current
        let now = Date()
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        let storedMonth = UserDefaults.standard.integer(forKey: monthKey + ".unlocked.month")
        let storedYear = UserDefaults.standard.integer(forKey: monthKey + ".unlocked.year")
        guard storedMonth == currentMonth, storedYear == currentYear,
              let data = UserDefaults.standard.data(forKey: key),
              let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(rawValues.compactMap { MonthlyAchievementKind(rawValue: $0) })
    }

    func saveShownAchievements() {
        let calendar = Calendar.current
        let now = Date()
        UserDefaults.standard.set(calendar.component(.month, from: now), forKey: achievementsMonthKey + ".shown.month")
        UserDefaults.standard.set(calendar.component(.year, from: now), forKey: achievementsMonthKey + ".shown.year")
        let rawValues = shownAchievementKinds.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(rawValues) {
            UserDefaults.standard.set(data, forKey: achievementsShownKey)
        }
    }

    func saveUnlockedAchievements() {
        let calendar = Calendar.current
        let now = Date()
        UserDefaults.standard.set(calendar.component(.month, from: now), forKey: achievementsMonthKey + ".unlocked.month")
        UserDefaults.standard.set(calendar.component(.year, from: now), forKey: achievementsMonthKey + ".unlocked.year")
        let rawValues = unlockedAchievementKinds.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(rawValues) {
            UserDefaults.standard.set(data, forKey: achievementsUnlockedKey)
        }
    }

    func handleAppDataReset() {
        celebrationsEnabled = false
        shownAchievementKinds = []
        unlockedAchievementKinds = []
        recentlyUnlockedAchievement = nil
        // Clear achievement queue when resetting app data
        clearAchievementQueue()
        UserDefaults.standard.removeObject(forKey: achievementsShownKey)
        UserDefaults.standard.removeObject(forKey: achievementsUnlockedKey)
        UserDefaults.standard.removeObject(forKey: achievementsMonthKey + ".shown.month")
        UserDefaults.standard.removeObject(forKey: achievementsMonthKey + ".shown.year")
        UserDefaults.standard.removeObject(forKey: achievementsMonthKey + ".unlocked.month")
        UserDefaults.standard.removeObject(forKey: achievementsMonthKey + ".unlocked.year")
        userStore.loadUserData()
        levelProgressManager.resetTracking()
        updateStreaks()
        updateNextExercise()
        selectedNeckFixDate = Calendar.current.startOfDay(for: Date())
        updateNeckFixes(for: selectedNeckFixDate)
        celebrationsEnabled = true
    }
}
