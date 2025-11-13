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

        // Filter out the last exercise to prevent same exercise twice in a row
        let filtered = exercises.filter { $0.id != lastExerciseId }
        let selectionPool = filtered.isEmpty ? exercises : filtered
        
        // Randomly select exercise for Quick Workout (dailyUnrotExercise)
        guard let randomSelection = selectionPool.randomElement() else {
            nextExercise = nil
            dailyUnrotExercise = nil
            dailyPostureFixExercise = nil
            lastExerciseId = nil
            return
        }

        // Update lastExerciseId to prevent same exercise next time
        lastExerciseId = randomSelection.id
        
        // Set both nextExercise and dailyUnrotExercise to the randomly selected exercise
        nextExercise = randomSelection
        dailyUnrotExercise = randomSelection
        
        // Second card: Daily Posture Fix - pick a different exercise if available
        let remainingExercises = exercises.filter { $0.id != randomSelection.id }
        if let secondExercise = remainingExercises.randomElement() {
            dailyPostureFixExercise = secondExercise
        } else {
            // If only one exercise exists, use the same one
            dailyPostureFixExercise = randomSelection
        }
        
        Log.debug("HomeViewModel updated exercises: Unrot=\(dailyUnrotExercise?.title ?? "nil") PostureFix=\(dailyPostureFixExercise?.title ?? "nil")")
    }

    func updateDailyStreakIfNeeded(for date: Date, goal: Int) {
        guard goal > 0 else { return }

        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let completions = exerciseStore.completionCount(on: normalizedDate)
        // Mark day as completed if ANY exercises were completed (not just if goal is met)
        let dayCompleted = completions > 0
        let streakType: StreakType = .postureChecks

        streakStore.addStreak(for: normalizedDate, completed: dayCompleted, type: streakType)
        currentStreak = streakStore.currentStreak(for: streakType)
        recordStreak = streakStore.longestStreak(for: streakType)

        Log.info("HomeViewModel streak check: date=\(normalizedDate) completions=\(completions) goal=\(goal) dayCompleted=\(dayCompleted) current=\(currentStreak) record=\(recordStreak)")
    }
}
