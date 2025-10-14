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
    let timeSlot: ExerciseTimeSlot // Which time slot this completion was for
    
    init(id: UUID = UUID(), exerciseId: UUID, completedAt: Date = Date(), durationSeconds: Int, timeSlot: ExerciseTimeSlot) {
        self.id = id
        self.exerciseId = exerciseId
        self.completedAt = completedAt
        self.durationSeconds = durationSeconds
        self.timeSlot = timeSlot
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case exerciseId
        case completedAt
        case durationSeconds
        case timeSlot
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        exerciseId = try container.decode(UUID.self, forKey: .exerciseId)
        completedAt = try container.decode(Date.self, forKey: .completedAt)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        timeSlot = try container.decodeIfPresent(ExerciseTimeSlot.self, forKey: .timeSlot) ?? .morning
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(exerciseId, forKey: .exerciseId)
        try container.encode(completedAt, forKey: .completedAt)
        try container.encode(durationSeconds, forKey: .durationSeconds)
        try container.encode(timeSlot, forKey: .timeSlot)
    }
}
