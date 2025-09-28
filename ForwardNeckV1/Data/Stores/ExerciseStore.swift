//
//  ExerciseStore.swift
//  ForwardNeckV1
//
//  Manages exercise data and completion tracking with local persistence.
//

import Foundation

@MainActor
final class ExerciseStore: ObservableObject {
    static let shared = ExerciseStore()
    
    private let fileURL: URL
    @Published private(set) var exercises: [Exercise] = []
    @Published private(set) var completions: [ExerciseCompletion] = []
    
    private init() {
        let fm = FileManager.default
        let base = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.fileURL = (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("exercises.json")
        Task { await load() }
    }
    
    // MARK: - Public API
    
    func allExercises() -> [Exercise] { exercises }
    
    func exercise(by id: UUID) -> Exercise? {
        exercises.first { $0.id == id }
    }
    
    func allCompletions() -> [ExerciseCompletion] { completions }
    
    func completions(for exerciseId: UUID) -> [ExerciseCompletion] {
        completions.filter { $0.exerciseId == exerciseId }
    }
    
    func weeklyCompletions() -> [ExerciseCompletion] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        return completions.filter { completion in
            completion.completedAt >= weekInterval.start && completion.completedAt < weekInterval.end
        }
    }
    
    func recordCompletion(exerciseId: UUID, durationSeconds: Int) async {
        let completion = ExerciseCompletion(exerciseId: exerciseId, durationSeconds: durationSeconds)
        completions.append(completion)
        Log.info("Recorded completion for exercise \(exerciseId) - \(durationSeconds)s")
        await save()
    }
    
    func completionCount(on date: Date) -> Int {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
    }
    
    // MARK: - Private
    
    private func load() async {
        do {
            let data = try Data(contentsOf: fileURL)
            let container = try JSONDecoder().decode(ExerciseDataContainer.self, from: data)

            let normalizedExercises = normalizeExercises(container.exercises)
            exercises = normalizedExercises
            completions = container.completions
            Log.info("Loaded \(exercises.count) exercises and \(completions.count) completions")

            if normalizedExercises != container.exercises {
                await save()
            }
        } catch {
            // First run - seed with default exercises
            await seedDefaultExercises()
            Log.info("Seeded default exercises on first run")
        }
    }
    
    private func save() async {
        do {
            let container = ExerciseDataContainer(exercises: exercises, completions: completions)
            let data = try JSONEncoder().encode(container)
            try data.write(to: fileURL, options: .atomic)
            Log.info("Saved \(exercises.count) exercises and \(completions.count) completions")
        } catch {
            Log.error("Failed to save exercises: \(error.localizedDescription)")
        }
    }
    
    private func seedDefaultExercises() async {
        exercises = [
            Exercise(
                title: "Neck Tilt Stretch",
                description: "Gentle neck stretch to relieve tension",
                instructions: [
                    "Sit or stand with shoulders relaxed",
                    "Slowly tilt your head to the right",
                    "Hold for 15 seconds",
                    "Return to center and repeat on left side"
                ],
                durationSeconds: 10,
                iconSystemName: "person.fill.viewfinder",
                difficulty: .easy
            ),
            Exercise(
                title: "Chin Tucks",
                description: "Strengthen deep neck flexors",
                instructions: [
                    "Sit with back straight",
                    "Gently pull chin back without tilting head",
                    "Hold for 5 seconds",
                    "Release and repeat 10 times"
                ],
                durationSeconds: 10,
                iconSystemName: "face.smiling",
                difficulty: .easy
            ),
            Exercise(
                title: "Shoulder Rolls",
                description: "Release shoulder tension",
                instructions: [
                    "Stand with arms at sides",
                    "Roll shoulders backward in circular motion",
                    "Complete 10 full circles",
                    "Reverse direction for 10 more"
                ],
                durationSeconds: 10,
                iconSystemName: "figure.strengthtraining.traditional",
                difficulty: .easy
            ),
            Exercise(
                title: "Wall Angel",
                description: "Improve posture and shoulder mobility",
                instructions: [
                    "Stand with back against wall",
                    "Place arms in 'W' position against wall",
                    "Slowly slide arms up to 'Y' position",
                    "Return to 'W' and repeat 10 times"
                ],
                durationSeconds: 10,
                iconSystemName: "figure.walk",
                difficulty: .medium
            )
        ]
        completions = []
        await save()
    }

    private func normalizeExercises(_ exercises: [Exercise]) -> [Exercise] {
        exercises.map { exercise in
            guard exercise.durationSeconds != 10 else { return exercise }
            return Exercise(
                id: exercise.id,
                title: exercise.title,
                description: exercise.description,
                instructions: exercise.instructions,
                durationSeconds: 10,
                iconSystemName: exercise.iconSystemName,
                difficulty: exercise.difficulty
            )
        }
    }
    
    /// Reset all exercise data (completions only, keeps exercise definitions)
    /// Useful for testing and fresh start
    func resetAll() {
        completions = []
        Task {
            await save()
            Log.info("Reset all exercise completions data")
        }
    }
}

// Helper struct for JSON encoding/decoding
private struct ExerciseDataContainer: Codable {
    let exercises: [Exercise]
    let completions: [ExerciseCompletion]
}
