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
    
    // MARK: - Constants
    
    private let exerciseDuration: Int = 30 // seconds
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
        let currentProgress = isBreak ? 1.0 : (Double(exerciseDuration - timeRemaining) / Double(exerciseDuration))
        
        return CGFloat((Double(completedExercises) + currentProgress) / Double(totalExercises))
    }
    
    // MARK: - Initialization
    
    init(exercises: [Exercise]) {
        self.exercises = exercises
        Log.info("WorkoutFlowViewModel initialized with \(exercises.count) exercises")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func start() {
        Log.info("Starting workout flow")
        startExercise()
    }
    
    // MARK: - Private Methods
    
    private func startExercise() {
        guard currentExerciseIndex < exercises.count else {
            completeWorkout()
            return
        }
        
        isBreak = false
        timeRemaining = exerciseDuration
        
        Log.debug("Starting exercise \(currentExerciseIndex + 1): \(currentExercise?.title ?? "")")
        startTimer()
    }
    
    private func startBreak() {
        guard currentExerciseIndex < exercises.count - 1 else {
            // No break after last exercise
            completeWorkout()
            return
        }
        
        isBreak = true
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
            
            if isBreak {
                // Break finished, move to next exercise
                currentExerciseIndex += 1
                startExercise()
            } else {
                // Exercise finished, start break (or complete if last exercise)
                startBreak()
            }
        }
    }
    
    private func completeWorkout() {
        timer?.invalidate()
        isCompleted = true
        Log.info("Workout flow completed - all \(exercises.count) exercises finished")
    }
}

