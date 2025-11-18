//
//  Connect4Move.swift
//  NeckRotV1
//
//  Data model for Connect 4 game moves.
//

import Foundation

/// Represents a single move in a Connect 4 game
struct Connect4Move: Codable, Identifiable {
    let id: UUID
    let matchId: UUID
    let playerDeviceId: String
    let columnIndex: Int
    let rowIndex: Int
    let moveNumber: Int
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        matchId: UUID,
        playerDeviceId: String,
        columnIndex: Int,
        rowIndex: Int,
        moveNumber: Int,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.matchId = matchId
        self.playerDeviceId = playerDeviceId
        self.columnIndex = columnIndex
        self.rowIndex = rowIndex
        self.moveNumber = moveNumber
        self.createdAt = createdAt
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id
        case matchId = "match_id"
        case playerDeviceId = "player_device_id"
        case columnIndex = "column_index"
        case rowIndex = "row_index"
        case moveNumber = "move_number"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        matchId = try container.decode(UUID.self, forKey: .matchId)
        playerDeviceId = try container.decode(String.self, forKey: .playerDeviceId)
        columnIndex = try container.decode(Int.self, forKey: .columnIndex)
        rowIndex = try container.decode(Int.self, forKey: .rowIndex)
        moveNumber = try container.decode(Int.self, forKey: .moveNumber)
        
        // Handle date decoding
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdAt = formatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(matchId, forKey: .matchId)
        try container.encode(playerDeviceId, forKey: .playerDeviceId)
        try container.encode(columnIndex, forKey: .columnIndex)
        try container.encode(rowIndex, forKey: .rowIndex)
        try container.encode(moveNumber, forKey: .moveNumber)
        
        // Encode date as ISO8601 string
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
    }
}

