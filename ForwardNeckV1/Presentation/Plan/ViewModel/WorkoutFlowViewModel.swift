//
//  WorkoutFlowViewModel.swift
//  ForwardNeckV1
//
//  Manages workout flow timing and state.
//

import Foundation
import Combine

@MainActor
final class WorkoutFlowViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentExerciseIndex: Int = 0
    @Published var timeRemaining: Int = 30
    @Published var isBreak: Bool = false
    @Published var isCompleted: Bool = false
    @Published var isTimerRunning: Bool = false // Track if timer is actively running
    
    // MARK: - Constants
    
    private let breakDuration: Int = 5 // seconds
    
    // MARK: - Properties
    
    let exercises: [Exercise]
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var currentExercise: Exercise? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    var nextExercise: Exercise? {
        let nextIndex = currentExerciseIndex + 1
        guard nextIndex < exercises.count else { return nil }
        return exercises[nextIndex]
    }
    
    var progress: CGFloat {
        let totalExercises = exercises.count
        guard totalExercises > 0 else { return 0 }
        
        // Calculate progress including current exercise
        let completedExercises = currentExerciseIndex
        let currentExerciseDuration = currentExercise?.durationSeconds ?? 30
        let currentProgress = isBreak ? 1.0 : (Double(currentExerciseDuration - timeRemaining) / Double(currentExerciseDuration))
        
        return CGFloat((Double(completedExercises) + currentProgress) / Double(totalExercises))
    }
    
    // MARK: - Initialization
    
    init(exercises: [Exercise]) {
        self.exercises = exercises
        // Initialize with first exercise ready but timer not started
        if let firstExercise = exercises.first {
            timeRemaining = firstExercise.durationSeconds
        }
        Log.info("WorkoutFlowViewModel initialized with \(exercises.count) exercises")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    /// Start the workout flow - prepares first exercise but doesn't start timer
    func start() {
        Log.info("Starting workout flow - ready for first exercise")
        prepareExercise()
    }
    
    /// Manually start the timer for current exercise
    func startExerciseTimer() {
        guard !isTimerRunning else { return }
        guard currentExerciseIndex < exercises.count else {
            completeWorkout()
            return
        }
        
        isTimerRunning = true
        Log.debug("Starting timer for exercise \(currentExerciseIndex + 1): \(currentExercise?.title ?? "")")
        startTimer()
    }
    
    // MARK: - Private Methods
    
    private func prepareExercise() {
        guard currentExerciseIndex < exercises.count else {
            completeWorkout()
            return
        }
        
        isBreak = false
        isTimerRunning = false
        if let exercise = currentExercise {
            timeRemaining = exercise.durationSeconds
        }
        
        Log.debug("Prepared exercise \(currentExerciseIndex + 1): \(currentExercise?.title ?? "")")
    }
    
    private func startBreak() {
        guard currentExerciseIndex < exercises.count - 1 else {
            // No break after last exercise
            completeWorkout()
            return
        }
        
        isBreak = true
        isTimerRunning = true
        timeRemaining = breakDuration
        
        Log.debug("Starting break after exercise \(currentExerciseIndex + 1)")
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func tick() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            timer?.invalidate()
            isTimerRunning = false
            
            if isBreak {
                // Break finished, move to next exercise
                currentExerciseIndex += 1
                prepareExercise() // Prepare next exercise but don't start timer
            } else {
                // Exercise finished, prepare for next exercise
                if currentExerciseIndex < exercises.count - 1 {
                    // There's another exercise, prepare it
                    currentExerciseIndex += 1
                    prepareExercise()
                } else {
                    // Last exercise completed
                    completeWorkout()
                }
            }
        }
    }
    
    private func completeWorkout() {
        timer?.invalidate()
        isTimerRunning = false
        isCompleted = true
        Log.info("Workout flow completed - all \(exercises.count) exercises finished")
    }
}

