//
//  PlanViewModel.swift
//  ForwardNeckV1
//
//  View model for the daily neck workout circuit plan.
//  Manages exercise data and workout state.
//

import Foundation

/// View model managing the daily workout circuit plan
@MainActor
final class PlanViewModel: ObservableObject {
    // MARK: - Properties
    
    /// All exercises in the daily circuit
    @Published private(set) var exercises: [Exercise] = []
    
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
    
    /// Check if Full Daily Workout has been completed today
    var isWorkoutCompletedToday: Bool {
        exerciseStore.isTimeSlotCompleted(.afternoon, for: Date())
    }
    
    // MARK: - Dependencies
    
    private let exerciseStore: ExerciseStore
    
    // MARK: - Initialization
    
    init() {
        self.exerciseStore = ExerciseStore.shared
        Log.debug("PlanViewModel initialized")
    }
    
    // For testing
    init(exerciseStore: ExerciseStore) {
        self.exerciseStore = exerciseStore
        Log.debug("PlanViewModel initialized with custom store")
    }
    
    // MARK: - Public Methods
    
    /// Load exercises when view appears
    func onAppear() async {
        Log.info("PlanViewModel.onAppear - Loading workout circuit")
        loadExercises()
        refreshCompletionStatus()
    }
    
    /// Refresh completion status (call after workout completes)
    func refreshCompletionStatus() {
        // Trigger view update by accessing the computed property
        objectWillChange.send()
        Log.debug("PlanViewModel completion status refreshed: completed=\(isWorkoutCompletedToday)")
    }
    
    /// Get the day of week for a given date (0 = Sunday, 6 = Saturday)
    func dayOfWeek(for date: Date) -> Int {
        Calendar.current.component(.weekday, from: date) - 1
    }
    
    /// Check if a given day index matches today
    func isToday(_ dayIndex: Int) -> Bool {
        dayOfWeek(for: Date()) == dayIndex
    }
    
    /// Get the date for the current week (Mon-first) at the provided day index [0..6]
    func dateForDayIndex(_ dayIndex: Int, reference: Date = Date()) -> Date {
        let calendar = Calendar.current
        // Find Monday of the current week
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: reference)
        let startOfWeek = calendar.date(from: components) ?? reference
        // In many locales, the above returns the start based on locale (often Sunday). Shift to Monday.
        let weekday = calendar.component(.weekday, from: startOfWeek)
        let sundayIndex = 1 // Sunday = 1
        let daysToMonday = (weekday == sundayIndex) ? 1 : 0
        let adjustedStart = calendar.date(byAdding: .day, value: daysToMonday, to: startOfWeek) ?? startOfWeek
        return calendar.date(byAdding: .day, value: dayIndex, to: calendar.startOfDay(for: adjustedStart)) ?? reference
    }

    /// Whether the full daily workout (afternoon slot) was completed on a given date
    func fullWorkoutCompleted(on date: Date) -> Bool {
        exerciseStore.isTimeSlotCompleted(.afternoon, for: date)
    }

    // MARK: - Private Methods
    
    /// Load all exercises from the store
    private func loadExercises() {
        exercises = exerciseStore.allExercises()
        Log.info("Loaded \(exercises.count) exercises for workout circuit")
    }
}


