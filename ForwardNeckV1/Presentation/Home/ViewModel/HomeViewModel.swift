//
//  HomeViewModel.swift
//  ForwardNeckV1
//
//  Central view model for the home dashboard.
//

import Combine
import FamilyControls
import Foundation
import SwiftUI
#if canImport(DeviceActivity)
import DeviceActivity
#endif

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published State

    @Published var currentStreak: Int = 0
    @Published var recordStreak: Int = 0
    @Published var nextExercise: Exercise?
    @Published var neckFixesCompleted: Int = 0
    @Published var neckFixesTarget: Int = 0
    @Published var healthPercentage: Int = 100
    @Published var selectedNeckFixDate: Date = Date()
    @Published var activitySelection: FamilyActivitySelection = .init() {
        didSet {
            appMonitoringStore.updateSelection(activitySelection)
            refreshTrackedAppUsage()
            scheduleMonitoring(for: activitySelection)
        }
    }
    @Published var trackedUsageMinutes: Int = 0
    @Published var monthlyAchievements: [MonthlyAchievement] = MonthlyAchievementKind.allCases.map { MonthlyAchievement(kind: $0) }
    @Published var recentlyUnlockedAchievement: MonthlyAchievement?
    @Published var neckFixHistory: [NeckFixDaySummary] = []
    @Published var previousDayCards: [PreviousDaySummary] = []

    var heroMascotName: String {
        let baseName = mascotAssetName(for: healthPercentage)
        let themedName = MascotAssetProvider.resolvedMascotName(for: baseName)
        Log.info("HomeViewModel hero mascot base=\(baseName) themed=\(themedName)")
        return themedName
    }

    // MARK: - Dependencies

    let streakStore: StreakStore
    let exerciseStore: ExerciseStore
    let userStore: UserStore
    let appMonitoringStore = AppMonitoringStore()
    let levelProgressManager = LevelProgressManager.shared

    // MARK: - Persistence

    var cancellables = Set<AnyCancellable>()
    var lastExerciseId: UUID?
    let historyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    let achievementsShownKey = "home.achievements.shown"
    let achievementsUnlockedKey = "home.achievements.unlocked"
    let achievementsMonthKey = "home.achievements.month"

    var shownAchievementKinds: Set<MonthlyAchievementKind> {
        didSet { saveShownAchievements() }
    }

    var unlockedAchievementKinds: Set<MonthlyAchievementKind> {
        didSet { saveUnlockedAchievements() }
    }

    var celebrationsEnabled = false

    // MARK: - Init

    init(
        streakStore: StreakStore? = nil,
        exerciseStore: ExerciseStore? = nil,
        userStore: UserStore? = nil
    ) {
        self.streakStore = streakStore ?? StreakStore.shared
        self.exerciseStore = exerciseStore ?? ExerciseStore.shared
        self.userStore = userStore ?? UserStore()
        self.shownAchievementKinds = Self.loadShownAchievementsForCurrentMonth(key: achievementsShownKey, monthKey: achievementsMonthKey)
        self.unlockedAchievementKinds = Self.loadUnlockedAchievementsForCurrentMonth(key: achievementsUnlockedKey, monthKey: achievementsMonthKey)

        NotificationCenter.default.publisher(for: .appDataDidReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleAppDataReset()
            }
            .store(in: &cancellables)

        bindStreakStore()
        bindExerciseStore()
        bindUserStore()
        updateStreaks()
        updateNextExercise()
        selectedNeckFixDate = Calendar.current.startOfDay(for: Date())
        updateNeckFixes(for: selectedNeckFixDate)
        activitySelection = appMonitoringStore.activitySelection
    }

    // MARK: - Lifecycle

    func onAppear() async {
        updateStreaks()
        updateNextExercise()
        updateNeckFixes(for: selectedNeckFixDate)
        refreshTrackedAppUsage()
        celebrationsEnabled = true
    }

    // MARK: - Public API

    func completeCurrentExercise() async {
        guard let exercise = nextExercise else { return }
        await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: exercise.durationSeconds)
        updateNextExercise()
        updateNeckFixes(for: selectedNeckFixDate)
    }

    func selectNeckFixDate(_ date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        selectedNeckFixDate = normalizedDate
        updateNeckFixes(for: normalizedDate)
    }

    func markAchievementCelebrated(_ achievement: MonthlyAchievement) {
        guard achievement.isUnlocked else { return }
        if !shownAchievementKinds.contains(achievement.kind) {
            shownAchievementKinds.insert(achievement.kind)
        }
    }

    func clearRecentlyUnlockedAchievement() {
        recentlyUnlockedAchievement = nil
    }
}
