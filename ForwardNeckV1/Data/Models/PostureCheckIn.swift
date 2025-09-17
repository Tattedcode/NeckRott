//
//  PostureCheckIn.swift
//  ForwardNeckV1
//
//  Data model for a single posture check-in.
//

import Foundation

/// Represents one posture check-in event stored on device
struct PostureCheckIn: Codable, Identifiable {
    let id: UUID
    let timestamp: Date

    init(id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
    }
}


