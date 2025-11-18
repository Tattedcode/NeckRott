//
//  HomeViewModel.swift
//  NeckRotV1
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
    
    var currentLevel: Int {
        GamificationStore.shared.userProgress.level
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

    // MARK: - Init

    init(
        streakStore: StreakStore? = nil,
        exerciseStore: ExerciseStore? = nil,
        userStore: UserStore? = nil
    ) {
        self.streakStore = streakStore ?? StreakStore.shared
        self.exerciseStore = exerciseStore ?? ExerciseStore.shared
        self.userStore = userStore ?? UserStore()

        NotificationCenter.default.publisher(for: .appDataDidReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleAppDataReset()
            }
            .store(in: &cancellables)
        
        // Listen for exercise completions from anywhere in the app to update widget
        NotificationCenter.default.publisher(for: .exerciseCompleted)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                // Refresh stats and widget immediately when any exercise is completed (includes Connect 4)
                self.updateStreaks()
                self.updateNextExercise()
                self.updateNeckFixes(for: self.selectedNeckFixDate)
                self.updateTimeSlotStatuses()
                self.updateWidgetWithTodayData()
                Log.info("HomeViewModel: Stats and widget updated via exerciseCompleted notification")
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
    }

    func handleAppDataReset() {
        userStore.loadUserData()
        levelProgressManager.resetTracking()
        updateStreaks()
        updateNextExercise()
        selectedNeckFixDate = Calendar.current.startOfDay(for: Date())
        updateNeckFixes(for: selectedNeckFixDate)
        updateTimeSlotStatuses()
    }

    // MARK: - Public API

    func completeCurrentExercise() async {
        guard let exercise = nextExercise ?? dailyUnrotExercise else { return }
        
        // Determine which time slot this exercise is for
        let timeSlot = currentTimeSlot ?? ExerciseTimeSlot.currentTimeSlot() ?? .morning
        
        await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: exercise.durationSeconds, timeSlot: timeSlot)
        
        // Cancel Full Daily Workout notifications if this was a Full Daily Workout completion
        if timeSlot == .afternoon {
            await NotificationManager.shared.cancelFullDailyWorkoutNotifications()
            Log.info("Cancelled Full Daily Workout notifications after completion")
        }
        
        // Update lastExerciseId to prevent same exercise next time
        lastExerciseId = exercise.id
        
        // Get a new random exercise for next time
        updateNextExercise()
        updateNeckFixes(for: selectedNeckFixDate)
        updateTimeSlotStatuses()
        
        // Explicitly update widget immediately after completion to ensure it refreshes
        // (The binding should also trigger, but this ensures it happens right away)
        updateWidgetWithTodayData()
        Log.info("HomeViewModel: Explicitly updated widget after exercise completion")
    }

    func selectNeckFixDate(_ date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        selectedNeckFixDate = normalizedDate
        updateNeckFixes(for: normalizedDate)
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
        // Ignore Connect 4 completions when evaluating time-slot locks
        let excludedExerciseIds: Set<UUID> = {
            if let id = exerciseStore.connect4ExerciseId() {
                return [id]
            }
            return []
        }()
        
        // Special handling for Quick Workout cooldown
        if slot == .morning {
            let cooldownCheck = exerciseStore.canStartSlot(.morning, cooldownMinutes: 30, on: date, excluding: excludedExerciseIds)
            Log.info("Quick Workout cooldown check: canStart=\(cooldownCheck.canStart), timeRemaining=\(cooldownCheck.timeRemaining ?? 0)")
            if !cooldownCheck.canStart {
                Log.info("Quick Workout is in cooldown, returning .locked")
                return .locked // Show as locked during cooldown
            }
            // If cooldown passed but there was a completion today, show as available (not completed)
            if exerciseStore.isTimeSlotCompleted(slot, for: date, excluding: excludedExerciseIds) {
                Log.info("Quick Workout cooldown passed, returning .available")
                return .available
            }
        }
        
        // Special handling for Full Daily Workout - lock until 6am next day after completion
        if slot == .afternoon {
            if exerciseStore.isTimeSlotCompleted(slot, for: date, excluding: excludedExerciseIds) {
                let calendar = Calendar.current
                let now = date
                let hour = calendar.component(.hour, from: now)
                let lastCompletion = exerciseStore.lastCompletionTime(for: slot, on: date, excluding: excludedExerciseIds)
                
                if let lastCompletion = lastCompletion {
                    let completionDay = calendar.startOfDay(for: lastCompletion)
                    let today = calendar.startOfDay(for: date)
                    
                    if completionDay == today {
                        // Completed today - lock until 6am tomorrow
                        Log.info("Full Daily Workout completed today, locked until 6am tomorrow")
                        return .locked
                    } else {
                        // Completed yesterday or earlier
                        if hour >= 6 {
                            // It's after 6am today, so it's been unlocked
                            Log.info("Full Daily Workout completed yesterday, available now (after 6am)")
                            return .available
                        } else {
                            // It's before 6am today, still locked until 6am
                            Log.info("Full Daily Workout completed yesterday, locked until 6am today")
                            return .locked
                        }
                    }
                }
            }
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
