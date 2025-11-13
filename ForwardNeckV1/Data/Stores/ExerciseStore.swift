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
    
    /// Update an exercise by title with new instructions and optional duration
    func updateExercise(title: String, instructions: [String], durationSeconds: Int? = nil) async {
        if let index = exercises.firstIndex(where: { $0.title == title }) {
            let existingExercise = exercises[index]
            exercises[index] = Exercise(
                id: existingExercise.id,
                title: existingExercise.title,
                description: existingExercise.description,
                instructions: instructions,
                durationSeconds: durationSeconds ?? existingExercise.durationSeconds,
                iconSystemName: existingExercise.iconSystemName,
                difficulty: existingExercise.difficulty
            )
            await save()
            Log.info("Updated exercise '\(title)' with new instructions and duration: \(durationSeconds ?? existingExercise.durationSeconds)s")
        }
    }
    
    /// Rename an exercise from old title to new title and update its properties
    func renameExercise(oldTitle: String, newTitle: String, description: String, instructions: [String]) async {
        if let index = exercises.firstIndex(where: { $0.title == oldTitle }) {
            let existingExercise = exercises[index]
            exercises[index] = Exercise(
                id: existingExercise.id,
                title: newTitle,
                description: description,
                instructions: instructions,
                durationSeconds: existingExercise.durationSeconds,
                iconSystemName: existingExercise.iconSystemName,
                difficulty: existingExercise.difficulty
            )
            await save()
            Log.info("Renamed exercise from '\(oldTitle)' to '\(newTitle)'")
        }
    }
    
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
    
    func recordCompletion(exerciseId: UUID, durationSeconds: Int, timeSlot: ExerciseTimeSlot) async {
        let completion = ExerciseCompletion(exerciseId: exerciseId, durationSeconds: durationSeconds, timeSlot: timeSlot)
        completions.append(completion)
        Log.info("Recorded completion for exercise \(exerciseId) - \(durationSeconds)s in \(timeSlot.rawValue) slot")
        await save()
        
        // Award 2 XP for completing any exercise
        let gamificationStore = GamificationStore.shared
        gamificationStore.addXP(2, source: "Exercise completed")
        
        // Notify leaderboard system of exercise completion
        NotificationCenter.default.post(name: .exerciseCompleted, object: nil)
    }
    
    func completionCount(on date: Date) -> Int {
        let calendar = Calendar.current
        return completions.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
    }
    
    // MARK: - Time Slot Methods
    
    /// Check if a specific time slot is currently available (within time range)
    func isTimeSlotAvailable(_ slot: ExerciseTimeSlot, for date: Date = Date()) -> Bool {
        // Check if current time is within the slot's time range
        return slot.isActive(at: date)
    }
    
    /// Check if a specific time slot has been completed today
    func isTimeSlotCompleted(_ slot: ExerciseTimeSlot, for date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        return completions.contains { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: date) && completion.timeSlot == slot
        }
    }
    
    /// Get the most recent completion time for a specific time slot today
    func lastCompletionTime(for slot: ExerciseTimeSlot, on date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        return completions
            .filter { calendar.isDate($0.completedAt, inSameDayAs: date) && $0.timeSlot == slot }
            .map { $0.completedAt }
            .max()
    }
    
    /// Check if enough time has passed since last completion (for cooldown periods)
    func canStartSlot(_ slot: ExerciseTimeSlot, cooldownMinutes: Int = 60, on date: Date = Date()) -> (canStart: Bool, timeRemaining: TimeInterval?) {
        guard let lastCompletion = lastCompletionTime(for: slot, on: date) else {
            // No completion yet today, can start
            Log.info("No completion found for \(slot.rawValue) today, can start")
            return (true, nil)
        }
        
        let cooldownSeconds = TimeInterval(cooldownMinutes * 60)
        let timeSinceLastCompletion = date.timeIntervalSince(lastCompletion)
        
        Log.info("\(slot.rawValue) cooldown check: lastCompletion=\(lastCompletion), timeSince=\(timeSinceLastCompletion), cooldownSeconds=\(cooldownSeconds)")
        
        if timeSinceLastCompletion >= cooldownSeconds {
            // Cooldown period has passed
            Log.info("Cooldown period has passed for \(slot.rawValue)")
            return (true, nil)
        } else {
            // Still in cooldown
            let timeRemaining = cooldownSeconds - timeSinceLastCompletion
            Log.info("Still in cooldown for \(slot.rawValue), timeRemaining=\(timeRemaining)")
            return (false, timeRemaining)
        }
    }
    
    /// Get all completed time slots for a specific date
    func completedTimeSlots(for date: Date = Date()) -> Set<ExerciseTimeSlot> {
        let calendar = Calendar.current
        let completedSlots = completions
            .filter { calendar.isDate($0.completedAt, inSameDayAs: date) }
            .map { $0.timeSlot }
        return Set(completedSlots)
    }
    
    /// Find the next available time slot that hasn't been completed
    func nextAvailableSlot(for date: Date = Date()) -> (slot: ExerciseTimeSlot, availableAt: Date)? {
        let completed = completedTimeSlots(for: date)
        let calendar = Calendar.current
        
        // Find first incomplete slot
        for slot in ExerciseTimeSlot.allCases {
            if !completed.contains(slot) {
                // Calculate when this slot becomes available
                if let interval = slot.timeUntilAvailable(from: date), interval >= 0 {
                    let availableDate = date.addingTimeInterval(interval)
                    return (slot, availableDate)
                }
            }
        }
        
        // All slots completed today, next is tomorrow morning
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.day! += 1
        components.hour = ExerciseTimeSlot.morning.timeRange.start
        components.minute = 0
        components.second = 0
        
        if let tomorrowMorning = calendar.date(from: components) {
            return (.morning, tomorrowMorning)
        }
        
        return nil
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
            
            // Update Chin Tucks exercise with new instructions and duration
            await updateExercise(
                title: "Chin Tucks",
                instructions: [
                    "Sit or stand with back straight, place 2 fingers on your chin.",
                    "Gently push chin back like you are making a double chin.",
                    "Hold 5 seconds.",
                    "Release and repeat"
                ],
                durationSeconds: 50
            )
            
            // Rename Neck Tilt Stretch to Neck Flexion and update instructions
            await renameExercise(
                oldTitle: "Neck Tilt Stretch",
                newTitle: "Neck Flexion",
                description: "Gentle neck stretch to relieve tension",
                instructions: [
                    "Begin by sitting comfortably in a chair or on the floor.",
                    "Tilt your head forward until you feel a gentle stretch at the back of your neck.",
                    "Hold this position for 15-30 seconds.",
                    "Repeat"
                ]
            )
            
            // Also update if it's already named Neck Flexion
            await updateExercise(
                title: "Neck Flexion",
                instructions: [
                    "Begin by sitting comfortably in a chair or on the floor.",
                    "Tilt your head forward until you feel a gentle stretch at the back of your neck.",
                    "Hold this position for 15-30 seconds.",
                    "Repeat"
                ],
                durationSeconds: 90
            )
            
            // Update Wall Angel exercise with new instructions and duration
            await updateExercise(
                title: "Wall Angel",
                instructions: [
                    "Stand with your back against the wall, with your arms in a \"W\" shape.",
                    "Slowly move your arms up to a \"Y\" shape and hold for 5 seconds",
                    "Slowly move back down to the W and hold for 5 seconds.",
                    "Repeat"
                ],
                durationSeconds: 50
            )
            
            // Rename Shoulder Rolls to Neck Tilts
            await renameExercise(
                oldTitle: "Shoulder Rolls",
                newTitle: "Neck Tilts",
                description: "Release shoulder tension",
                instructions: [
                    "Stand or sit straight with arms by your sides.",
                    "Lean head to one shoulder and hold for 10 seconds",
                    "Lean head to other shoulder and hold for 10 seconds",
                    "Repeat both sides"
                ]
            )
            
            // Also update if it's already named Neck Tilts (to ensure instructions are correct)
            await updateExercise(
                title: "Neck Tilts",
                instructions: [
                    "Stand or sit straight with arms by your sides.",
                    "Lean head to one shoulder and hold for 10 seconds",
                    "Lean head to other shoulder and hold for 10 seconds",
                    "Repeat both sides"
                ],
                durationSeconds: 70
            )
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
                title: "Neck Flexion",
                description: "Gentle neck stretch to relieve tension",
                instructions: [
                    "Begin by sitting comfortably in a chair or on the floor.",
                    "Tilt your head forward until you feel a gentle stretch at the back of your neck.",
                    "Hold this position for 15-30 seconds.",
                    "Repeat"
                ],
                durationSeconds: 90,
                iconSystemName: "person.fill.viewfinder",
                difficulty: .easy
            ),
            Exercise(
                title: "Chin Tucks",
                description: "Fully strengthen your neck",
                instructions: [
                    "Sit or stand with back straight, place 2 fingers on your chin.",
                    "Gently push chin back like you are making a double chin.",
                    "Hold 5 seconds.",
                    "Release and repeat"
                ],
                durationSeconds: 50,
                iconSystemName: "face.smiling",
                difficulty: .easy
            ),
            Exercise(
                title: "Neck Tilts",
                description: "Release shoulder tension",
                instructions: [
                    "Stand or sit straight with arms by your sides.",
                    "Lean head to one shoulder and hold for 10 seconds",
                    "Lean head to other shoulder and hold for 10 seconds",
                    "Repeat both sides"
                ],
                durationSeconds: 70,
                iconSystemName: "figure.strengthtraining.traditional",
                difficulty: .easy
            ),
            Exercise(
                title: "Wall Angel",
                description: "Improve posture and shoulder mobility",
                instructions: [
                    "Stand with your back against the wall, with your arms in a \"W\" shape.",
                    "Slowly move your arms up to a \"Y\" shape and hold for 5 seconds",
                    "Slowly move back down to the W and hold for 5 seconds.",
                    "Repeat"
                ],
                durationSeconds: 50,
                iconSystemName: "figure.walk",
                difficulty: .medium
            )
        ]
        completions = []
        await save()
    }

    private func normalizeExercises(_ exercises: [Exercise]) -> [Exercise] {
        // Map of exercise titles to their correct durations
        let exerciseDurations: [String: Int] = [
            "Wall Angel": 50,
            "Chin Tucks": 50,
            "Neck Flexion": 90,
            "Neck Tilts": 70
        ]
        
        return exercises.map { exercise in
            // If exercise has a defined duration, use it; otherwise keep existing duration
            if let correctDuration = exerciseDurations[exercise.title] {
                // Only update if duration is wrong (was 10 seconds from old code)
                if exercise.durationSeconds == 10 {
                    return Exercise(
                        id: exercise.id,
                        title: exercise.title,
                        description: exercise.description,
                        instructions: exercise.instructions,
                        durationSeconds: correctDuration,
                        iconSystemName: exercise.iconSystemName,
                        difficulty: exercise.difficulty
                    )
                }
            }
            // Keep exercise as-is if duration is already correct
            return exercise
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
