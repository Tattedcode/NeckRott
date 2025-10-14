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
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        let loadedExercises = exerciseStore.allExercises()
        
        await MainActor.run {
            exercises = loadedExercises
            isLoading = false
            Log.info("Loaded \(exercises.count) exercises")
        }
    }
    
    func refreshExercises() async {
        await loadExercises()
    }
    
}
