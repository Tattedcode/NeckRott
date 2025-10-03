//
//  ExerciseListViewModel.swift
//  ForwardNeckV1
//
//  ViewModel for ExerciseListView following MVVM pattern
//

import Foundation
import Observation

@MainActor
@Observable
final class ExerciseListViewModel {
    // MARK: - Published Properties
    private(set) var exercises: [Exercise] = []
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?
    
    // MARK: - Private Properties
    private let exerciseStore = ExerciseStore.shared
    
    // MARK: - Initialization
    init() {
        Log.debug("ExerciseListViewModel initialized")
    }
    
    // MARK: - Public Methods
    func loadExercises() async {
        isLoading = true
        errorMessage = nil
        
        do {
            exercises = exerciseStore.allExercises()
            isLoading = false
            Log.info("Loaded \(exercises.count) exercises")
        } catch {
            errorMessage = "Failed to load exercises"
            isLoading = false
            Log.error("Failed to load exercises: \(error)")
        }
    }
    
    func refreshExercises() async {
        await loadExercises()
    }
    
}
