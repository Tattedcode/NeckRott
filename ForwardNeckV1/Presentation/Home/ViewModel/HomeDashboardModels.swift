//
//  HomeDashboardModels.swift
//  ForwardNeckV1
//
//  Shared data models used by the home dashboard.
//

import Foundation

struct MonthlyAchievement: Identifiable, Equatable {
    let kind: MonthlyAchievementKind
    var isUnlocked: Bool = false
    var id: MonthlyAchievementKind { kind }
    var title: String { kind.title }
}

struct NeckFixDaySummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let label: String
    let count: Int
}

struct PreviousDaySummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let label: String
    let completionCount: Int
    let goal: Int
    let percentage: Int
    let mascotAssetName: String

    var percentageText: String { "\(percentage)%" }
}

enum MonthlyAchievementKind: String, CaseIterable, Hashable, Codable {
    case firstExercise
    case tenCompleted
    case twentyCompleted
    case dailyStreakStarted
    case fifteenDayStreak
    case fullMonthStreak
    case weeklyStreak
}

extension MonthlyAchievementKind {
    var title: String {
        switch self {
        case .firstExercise: return "First Exercise This Month"
        case .tenCompleted: return "10 Exercises Completed"
        case .twentyCompleted: return "20 Exercises Completed"
        case .dailyStreakStarted: return "Daily Streak Started"
        case .fifteenDayStreak: return "15 Day Streak"
        case .fullMonthStreak: return "Full Month Streak"
        case .weeklyStreak: return "Weekly Streak"
        }
    }

    private var baseAssetName: String {
        switch self {
        case .dailyStreakStarted:
            return "dailystreakstarted"
        case .fifteenDayStreak:
            return "fifteendaystreak"
        case .firstExercise:
            return "firstexcersise"
        case .fullMonthStreak:
            return "fullmonthstreak"
        case .tenCompleted:
            return "tencompleted"
        case .twentyCompleted:
            return "twentycompleted"
        case .weeklyStreak:
            return "weeklystreak"
        }
    }

    var lockedImageName: String {
        MascotAssetProvider.resolvedMascotName(for: baseAssetName)
    }

    var unlockedImageName: String {
        MascotAssetProvider.resolvedMascotName(for: baseAssetName)
    }

    var usesSystemImage: Bool { false }
}
