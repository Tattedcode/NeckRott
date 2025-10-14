//
//  HomeViewModel+Bindings.swift
//  ForwardNeckV1
//
//  Store bindings and core refresh helpers.
//

import Combine
import Foundation

extension HomeViewModel {
    func bindStreakStore() {
        streakStore.$streaks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStreaks()
            }
            .store(in: &cancellables)
    }

    func bindExerciseStore() {
        exerciseStore.$exercises
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateNextExercise()
            }
            .store(in: &cancellables)

        exerciseStore.$completions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateNeckFixes(for: self.selectedNeckFixDate)
                self.updateTimeSlotStatuses()
            }
            .store(in: &cancellables)
    }

    func bindUserStore() {
        userStore.$dailyGoal
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateNeckFixes(for: self.selectedNeckFixDate)
            }
            .store(in: &cancellables)
    }

    func updateStreaks() {
        recordStreak = streakStore.longestStreak(for: .postureChecks)
        currentStreak = streakStore.currentStreak(for: .postureChecks)
    }

    func updateNextExercise() {
        let exercises = exerciseStore.allExercises()
        guard !exercises.isEmpty else {
            nextExercise = nil
            dailyUnrotExercise = nil
            dailyPostureFixExercise = nil
            lastExerciseId = nil
            return
        }

        // Legacy single exercise logic
        let filtered = exercises.filter { $0.id != lastExerciseId }
        let selectionPool = filtered.isEmpty ? exercises : filtered
        guard let selection = selectionPool.randomElement() else {
            nextExercise = nil
            dailyUnrotExercise = nil
            dailyPostureFixExercise = nil
            lastExerciseId = nil
            return
        }

        lastExerciseId = selection.id
        nextExercise = selection
        
        // Assign two different exercises for the dual card layout
        // First card: Daily Unrot - pick first exercise
        dailyUnrotExercise = exercises.first
        
        // Second card: Daily Posture Fix - pick second exercise if available, otherwise same as first
        if exercises.count > 1 {
            dailyPostureFixExercise = exercises[1]
        } else {
            dailyPostureFixExercise = exercises.first
        }
        
        Log.debug("HomeViewModel updated exercises: Unrot=\(dailyUnrotExercise?.title ?? "nil") PostureFix=\(dailyPostureFixExercise?.title ?? "nil")")
    }

    func updateDailyStreakIfNeeded(for date: Date, goal: Int) {
        guard goal > 0 else { return }

        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let completions = exerciseStore.completionCount(on: normalizedDate)
        let goalMet = completions >= goal
        let streakType: StreakType = .postureChecks

        streakStore.addStreak(for: normalizedDate, completed: goalMet, type: streakType)
        currentStreak = streakStore.currentStreak(for: streakType)
        recordStreak = streakStore.longestStreak(for: streakType)

        Log.info("HomeViewModel streak check: date=\(normalizedDate) completions=\(completions) goal=\(goal) goalMet=\(goalMet) current=\(currentStreak) record=\(recordStreak)")
    }
}
