//
//  PlanViewModel.swift
//  ForwardNeckV1
//
//  View model for the daily neck workout circuit plan.
//  Manages exercise data and workout state.
//

import Foundation

/// View model managing the daily workout circuit plan
@Observable
@MainActor
final class PlanViewModel {
    // MARK: - Properties
    
    /// All exercises in the daily circuit
    private(set) var exercises: [Exercise] = []
    
    /// Currently selected day (for future multi-day support)
    private(set) var selectedDate: Date = Date()
    
    /// Currently selected day index (0 = Monday, 6 = Sunday)
    var selectedDayIndex: Int {
        // Get current day of week (0 = Sunday, 6 = Saturday)
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        // Convert to Monday-first format (0 = Monday, 6 = Sunday)
        return (weekday + 5) % 7
    }
    
    /// Total duration of the workout circuit in seconds
    var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.durationSeconds }
    }
    
    /// Human-friendly total duration string
    var totalDurationLabel: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        if minutes > 0 {
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes) min"
        } else {
            return "\(seconds) sec"
        }
    }
    
    /// Number of exercises in the circuit
    var exerciseCount: Int {
        exercises.count
    }
    
    // MARK: - Dependencies
    
    private let exerciseStore: ExerciseStore
    
    // MARK: - Initialization
    
    init(exerciseStore: ExerciseStore = ExerciseStore.shared) {
        self.exerciseStore = exerciseStore
        Log.debug("PlanViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    /// Load exercises when view appears
    func onAppear() async {
        Log.info("PlanViewModel.onAppear - Loading workout circuit")
        loadExercises()
    }
    
    /// Get the day of week for a given date (0 = Sunday, 6 = Saturday)
    func dayOfWeek(for date: Date) -> Int {
        Calendar.current.component(.weekday, from: date) - 1
    }
    
    /// Check if a given day index matches today
    func isToday(_ dayIndex: Int) -> Bool {
        dayOfWeek(for: Date()) == dayIndex
    }
    
    // MARK: - Private Methods
    
    /// Load all exercises from the store
    private func loadExercises() {
        exercises = exerciseStore.allExercises()
        Log.info("Loaded \(exercises.count) exercises for workout circuit")
    }
}


