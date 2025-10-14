//
//  ExerciseDetailViewModel.swift
//  ForwardNeckV1
//
//  ViewModel for ExerciseDetailView following MVVM pattern
//

import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class ExerciseDetailViewModel {
    // MARK: - Published Properties
    private(set) var timeRemaining: Int = 0
    private(set) var isRunning: Bool = false
    private(set) var isCompleted: Bool = false
    private(set) var isExerciseCompleted: Bool = false
    private(set) var showingCompletion: Bool = false
    
    // MARK: - Private Properties
    private var totalDuration: Int = 0
    private var timer: Timer?
    private let exercise: Exercise
    private let exerciseStore = ExerciseStore.shared
    private let goalsStore = GoalsStore.shared
    private let checkInStore = CheckInStore.shared
    private let streakStore = StreakStore.shared
    
    // MARK: - Computed Properties
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    var timeRemainingString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var elapsedSeconds: Int {
        totalDuration - timeRemaining
    }
    
    var difficultyColor: Color {
        switch exercise.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    // MARK: - Initialization
    init(exercise: Exercise) {
        self.exercise = exercise
        Log.debug("ExerciseDetailViewModel initialized for: \(exercise.title)")
    }
    
    // MARK: - Public Methods
    func setupTimer() {
        totalDuration = exercise.durationSeconds
        timeRemaining = exercise.durationSeconds
        isCompleted = false
        isRunning = false
        Log.debug("Timer setup for \(exercise.title) - duration: \(totalDuration) seconds")
    }
    
    func startTimer() {
        guard !isCompleted else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.complete()
                }
            }
        }
        Log.debug("Timer started for \(exercise.title)")
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        Log.debug("Timer paused for \(exercise.title)")
    }
    
    func resetTimer() {
        pauseTimer()
        timeRemaining = totalDuration
        isCompleted = false
        Log.debug("Timer reset for \(exercise.title)")
    }
    
    func completeExercise() async {
        let slot = ExerciseTimeSlot.currentTimeSlot() ?? .morning
        await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: elapsedSeconds, timeSlot: slot)
        
        // Update streaks after exercise completion
        await updateStreaks()
        
        // Update custom goals progress so everything stays in sync
        goalsStore.updateAllGoalProgress()
        
        isExerciseCompleted = true
        showingCompletion = true
        Log.info("Exercise completed: \(exercise.title)")
    }
    
    // MARK: - Private Methods
    private func complete() {
        pauseTimer()
        isCompleted = true
        Log.debug("Timer completed for \(exercise.title)")
    }
    
    /// Update streak data after exercise completion
    private func updateStreaks() async {
        let allCheckIns = checkInStore.all()
        let allExercises = exerciseStore.completions
        
        let checkInDates = allCheckIns.map { $0.timestamp }
        let exerciseDates = allExercises.map { $0.completedAt }
        
        streakStore.updateDailyStreaks(checkIns: checkInDates, exerciseCompletions: exerciseDates)
        Log.debug("Streaks updated after exercise completion")
    }
}
