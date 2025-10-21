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
    @Published var nextExercise: Exercise? // Legacy - keeping for compatibility
    @Published var dailyUnrotExercise: Exercise? // First exercise for Daily Unrot card
    @Published var dailyPostureFixExercise: Exercise? // Second exercise for Daily Posture Fix card
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
    
    // MARK: - Time Slot State
    
    @Published var morningSlotStatus: SlotStatus = .locked
    @Published var afternoonSlotStatus: SlotStatus = .locked
    @Published var showTimeSlotLockedAlert = false
    @Published var lockedAlertMessage = ""
    @Published var currentTimeSlot: ExerciseTimeSlot?

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
        updateTimeSlotStatuses()
        refreshTrackedAppUsage()
        celebrationsEnabled = true
    }

    // MARK: - Public API

    func completeCurrentExercise() async {
        guard let exercise = nextExercise else { return }
        
        // Determine which time slot this exercise is for
        let timeSlot = currentTimeSlot ?? ExerciseTimeSlot.currentTimeSlot() ?? .morning
        
        await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: exercise.durationSeconds, timeSlot: timeSlot)
        updateNextExercise()
        updateNeckFixes(for: selectedNeckFixDate)
        updateTimeSlotStatuses()
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
    
    // MARK: - Time Slot Methods
    
    /// Update all time slot statuses based on current time and completions
    func updateTimeSlotStatuses() {
        let now = Date()
        let statuses: [(ExerciseTimeSlot, SlotStatus)] = [
            (.morning, resolveStatus(for: .morning, at: now)),
            (.afternoon, resolveStatus(for: .afternoon, at: now))
        ]

        morningSlotStatus = statuses[0].1
        afternoonSlotStatus = statuses[1].1

        // Determine current slot preference: use actual current slot if available, otherwise first available slot
        if let activeSlot = ExerciseTimeSlot.currentTimeSlot(at: now), statusForSlot(activeSlot) == .available {
            currentTimeSlot = activeSlot
        } else if let availableSlot = statuses.first(where: { $0.1 == .available })?.0 {
            currentTimeSlot = availableSlot
        } else {
            currentTimeSlot = nil
        }

        Log.info("Updated time slots - Quick Workout: \(morningSlotStatus), Full Daily Workout: \(afternoonSlotStatus)")
    }
    
    /// Check if user can start an exercise for a given time slot
    /// Returns true if allowed, false if locked (and shows alert)
    func checkCanStartExercise(for slot: ExerciseTimeSlot) -> Bool {
        let status = statusForSlot(slot)
        
        if status == .completed {
            lockedAlertMessage = "You've already completed the \(slot.rawValue.lowercased()) exercise today! ✅"
            showTimeSlotLockedAlert = true
            return false
        }
        
        if status == .locked {
            if let timeUntil = slot.timeUntilAvailable() {
                let countdown = ExerciseTimeSlot.formatTimeInterval(timeUntil)
                lockedAlertMessage = "This exercise will be available in \(countdown)\n\n\(slot.timeRangeString)"
            } else {
                lockedAlertMessage = "This exercise is not available yet.\n\n\(slot.timeRangeString)"
            }
            showTimeSlotLockedAlert = true
            return false
        }
        
        return true
    }
    
    /// Helper to get status for a specific slot
    private func statusForSlot(_ slot: ExerciseTimeSlot) -> SlotStatus {
        switch slot {
        case .morning:
            return morningSlotStatus
        case .afternoon:
            return afternoonSlotStatus
        }
    }

    private func resolveStatus(for slot: ExerciseTimeSlot, at date: Date) -> SlotStatus {
        if exerciseStore.isTimeSlotCompleted(slot, for: date) {
            return .completed
        }

        if exerciseStore.isTimeSlotAvailable(slot, for: date) {
            return .available
        }

        // If the slot time has already passed today and we didn't complete it, don't lock—leave as available
        if slot.timeSlotHasPassed(on: date) {
            return .available
        }

        return .locked
    }
}

// MARK: - Slot Status Enum

enum SlotStatus {
    case locked      // Time slot not yet available
    case available   // Time slot active and can be completed
    case completed   // Time slot already completed today
}
