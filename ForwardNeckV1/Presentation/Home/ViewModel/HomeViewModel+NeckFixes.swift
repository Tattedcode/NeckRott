//
//  HomeViewModel+NeckFixes.swift
//  ForwardNeckV1
//
//  Neck-fix history, progress cards, and mascot helpers.
//

import Foundation

extension HomeViewModel {
    func updateNeckFixes(for date: Date) {
        // Daily goal is always 3 (one per time slot)
        neckFixesTarget = 3

        // Count completed time slots for today
        let completedSlots = exerciseStore.completedTimeSlots(for: date)
        neckFixesCompleted = completedSlots.count

        // Health percentage based on slots completed: 0%, 33%, 66%, 100%
        let progress = Double(neckFixesCompleted) / 3.0
        healthPercentage = Int((min(1.0, max(0.0, progress))) * 100)

        let referenceDate = max(date, Date())
        neckFixHistory = buildNeckFixHistory(endingOn: referenceDate, days: 7)
        updatePreviousDayCards(goal: neckFixesTarget)
        updateMonthlyAchievements(skipCelebration: !celebrationsEnabled)
        updateDailyStreakIfNeeded(for: date, goal: neckFixesTarget)

        if Calendar.current.isDateInToday(date) {
            levelProgressManager.processDailyProgress(
                date: date,
                dailyGoal: neckFixesTarget,
                completions: neckFixesCompleted,
                currentStreak: currentStreak
            )
        }

        if #available(iOS 14.0, *) {
            let mascot = WidgetSyncManager.mascot(for: healthPercentage)
            WidgetSyncManager.updateWidget(percentage: healthPercentage, mascot: mascot)
        }
    }

    func buildNeckFixHistory(endingOn referenceDate: Date, days: Int) -> [NeckFixDaySummary] {
        let calendar = Calendar.current
        let normalizedReference = calendar.startOfDay(for: referenceDate)
        let range = (0..<max(days, 1))

        let summaries = range.compactMap { offset -> NeckFixDaySummary? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: normalizedReference) else { return nil }
            let count = exerciseStore.completions.filter { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: date)
            }.count
            let label = historyFormatter.string(from: date)
            return NeckFixDaySummary(date: date, label: label, count: count)
        }

        return summaries.sorted { $0.date < $1.date }
    }

    func updatePreviousDayCards(goal: Int) {
        let calendar = Calendar.current
        let normalizedGoal = max(goal, 1)
        let filteredDays = neckFixHistory.filter { !calendar.isDateInToday($0.date) }
        let recentDays = Array(filteredDays.sorted { $0.date > $1.date }.prefix(7))

        let cards = recentDays.map { summary -> PreviousDaySummary in
            let percentage = calculatePercentage(for: summary.count, goal: normalizedGoal)
            let baseMascot = mascotAssetName(for: percentage)
            let resolvedMascot = MascotAssetProvider.resolvedMascotName(for: baseMascot)
            Log.info("HomeViewModel previous card mascot base=\(baseMascot) resolved=\(resolvedMascot)")
            return PreviousDaySummary(
                date: summary.date,
                label: summary.label,
                completionCount: summary.count,
                goal: normalizedGoal,
                percentage: percentage,
                mascotAssetName: resolvedMascot
            )
        }

        previousDayCards = cards
        Log.info("HomeViewModel updated previous day cards: count=\(previousDayCards.count)")
    }

    func calculatePercentage(for completions: Int, goal: Int) -> Int {
        guard goal > 0 else { return completions > 0 ? 100 : 0 }
        let ratio = min(1.0, max(0.0, Double(completions) / Double(goal)))
        return Int((ratio * 100).rounded())
    }

    func mascotAssetName(for percentage: Int) -> String {
        switch percentage {
        case ..<25:
            return "mascot1"
        case 25..<50:
            return "mascot2"
        case 50..<75:
            return "mascot3"
        default:
            return "mascot4"
        }
    }
}
