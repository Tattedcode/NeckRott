//
//  HomeViewModel.swift
//  ForwardNeckV1
//
//  Simplified MVVM ViewModel for Home screen metrics.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var healthScore: Int = 100
    @Published private(set) var screenTimeDisplay: String = "0m"
    @Published private(set) var isLoadingScreenTime = false
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var recordStreak: Int = 0
    @Published private(set) var nextExercise: Exercise?
    
    private let screenTimeService: ScreenTimeService
    private let streakStore: StreakStore
    private let exerciseStore: ExerciseStore
    private var cancellables = Set<AnyCancellable>()
    private var lastExerciseId: UUID?
    
    init(
        screenTimeService: ScreenTimeService? = nil,
        streakStore: StreakStore? = nil,
        exerciseStore: ExerciseStore? = nil
    ) {
        self.screenTimeService = screenTimeService ?? ScreenTimeService()
        self.streakStore = streakStore ?? StreakStore.shared
        self.exerciseStore = exerciseStore ?? ExerciseStore.shared

        bindStreakStore()
        bindExerciseStore()
        updateStreaks()
        updateNextExercise()
    }
    
    func onAppear() async {
        updateStreaks()
        updateNextExercise()
        await refreshScreenTime()
    }
    
    func refreshScreenTime() async {
        isLoadingScreenTime = true
        await screenTimeService.fetchScreenTime()
        screenTimeDisplay = screenTimeService.formatScreenTime(screenTimeService.totalScreenTime)
        isLoadingScreenTime = false
    }
    
    private func bindStreakStore() {
        streakStore.$streaks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStreaks()
            }
            .store(in: &cancellables)
    }
    
    private func bindExerciseStore() {
        exerciseStore.$exercises
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateNextExercise()
            }
            .store(in: &cancellables)
    }
    
    private func updateStreaks() {
        recordStreak = streakStore.longestStreak(for: .postureChecks)
        currentStreak = streakStore.currentStreak(for: .postureChecks)
    }

    private func updateNextExercise() {
        let exercises = exerciseStore.allExercises()
        guard !exercises.isEmpty else {
            nextExercise = nil
            lastExerciseId = nil
            return
        }
        let filtered = exercises.filter { $0.id != lastExerciseId }
        let selectionPool = filtered.isEmpty ? exercises : filtered
        guard let selection = selectionPool.randomElement() else {
            nextExercise = nil
            lastExerciseId = nil
            return
        }
        lastExerciseId = selection.id
        nextExercise = selection
    }

    func completeCurrentExercise() async {
        guard let exercise = nextExercise else { return }
        await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: exercise.durationSeconds)
        updateNextExercise()
    }
}
