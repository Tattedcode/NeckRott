//
//  Exercise.swift
//  ForwardNeckV1
//
//  Data model for posture exercises with instructions and duration.
//

import Foundation

/// Represents a single posture exercise with instructions and timing
struct Exercise: Codable, Identifiable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let instructions: [String] // Step-by-step instructions
    let durationSeconds: Int
    let iconSystemName: String
    let difficulty: ExerciseDifficulty
    
    init(id: UUID = UUID(), title: String, description: String, instructions: [String], durationSeconds: Int, iconSystemName: String, difficulty: ExerciseDifficulty = .easy) {
        self.id = id
        self.title = title
        self.description = description
        self.instructions = instructions
        self.durationSeconds = durationSeconds
        self.iconSystemName = iconSystemName
        self.difficulty = difficulty
    }
    
    /// Human-friendly duration string (e.g., "2 min")
    var durationLabel: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        if minutes > 0 {
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes) min"
        } else {
            return "\(seconds) sec"
        }
    }
}

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
}

/// Represents a completed exercise session
struct ExerciseCompletion: Codable, Identifiable {
    let id: UUID
    let exerciseId: UUID
    let completedAt: Date
    let durationSeconds: Int // Actual time spent
    
    init(id: UUID = UUID(), exerciseId: UUID, completedAt: Date = Date(), durationSeconds: Int) {
        self.id = id
        self.exerciseId = exerciseId
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
    }
}
