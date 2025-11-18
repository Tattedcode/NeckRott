//
//  Connect4Match.swift
//  NeckRotV1
//
//  Data model for Connect 4 match information.
//

import Foundation

/// Represents a Connect 4 match status
enum Connect4MatchStatus: String, Codable, Equatable {
    case waiting = "waiting"
    case inProgress = "in_progress"
    case completed = "completed"
    case abandoned = "abandoned"
}

/// Represents a Connect 4 match
struct Connect4Match: Codable, Identifiable, Equatable {
    let id: UUID
    let player1DeviceId: String
    var player2DeviceId: String?
    var status: Connect4MatchStatus
    var currentTurnDeviceId: String?
    var winnerDeviceId: String?
    let createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    
    init(
        id: UUID = UUID(),
        player1DeviceId: String,
        player2DeviceId: String? = nil,
        status: Connect4MatchStatus = .waiting,
        currentTurnDeviceId: String? = nil,
        winnerDeviceId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.player1DeviceId = player1DeviceId
        self.player2DeviceId = player2DeviceId
        self.status = status
        self.currentTurnDeviceId = currentTurnDeviceId
        self.winnerDeviceId = winnerDeviceId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }
    
    /// Check if match is ready to start (has both players)
    var isReady: Bool {
        return player2DeviceId != nil && status == .waiting
    }
    
    /// Check if match is active (in progress)
    var isActive: Bool {
        return status == .inProgress
    }
    
    /// Check if match is finished
    var isFinished: Bool {
        return status == .completed || status == .abandoned
    }
    
    /// Get opponent device ID for a given device ID
    func opponentDeviceId(for deviceId: String) -> String? {
        if deviceId == player1DeviceId {
            return player2DeviceId
        } else if deviceId == player2DeviceId {
            return player1DeviceId
        }
        return nil
    }
    
    /// Determine which player number (1 or 2) a device ID is
    func playerNumber(for deviceId: String) -> Int? {
        if deviceId == player1DeviceId {
            return 1
        } else if deviceId == player2DeviceId {
            return 2
        }
        return nil
    }
    
    /// Check if it's a specific device's turn
    func isMyTurn(deviceId: String) -> Bool {
        return currentTurnDeviceId == deviceId
    }
    
    // MARK: - Codable Implementation
    
    private enum CodingKeys: String, CodingKey {
        case id
        case player1DeviceId = "player1_device_id"
        case player2DeviceId = "player2_device_id"
        case status
        case currentTurnDeviceId = "current_turn_device_id"
        case winnerDeviceId = "winner_device_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        player1DeviceId = try container.decode(String.self, forKey: .player1DeviceId)
        player2DeviceId = try container.decodeIfPresent(String.self, forKey: .player2DeviceId)
        status = try container.decode(Connect4MatchStatus.self, forKey: .status)
        currentTurnDeviceId = try container.decodeIfPresent(String.self, forKey: .currentTurnDeviceId)
        winnerDeviceId = try container.decodeIfPresent(String.self, forKey: .winnerDeviceId)
        
        // Handle date decoding
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdAt = formatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            updatedAt = formatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
        
        if let completedAtString = try? container.decodeIfPresent(String.self, forKey: .completedAt) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            completedAt = formatter.date(from: completedAtString)
        } else {
            completedAt = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(player1DeviceId, forKey: .player1DeviceId)
        try container.encodeIfPresent(player2DeviceId, forKey: .player2DeviceId)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(currentTurnDeviceId, forKey: .currentTurnDeviceId)
        try container.encodeIfPresent(winnerDeviceId, forKey: .winnerDeviceId)
        
        // Encode dates as ISO8601 strings
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        try container.encode(formatter.string(from: updatedAt), forKey: .updatedAt)
        if let completedAt = completedAt {
            try container.encode(formatter.string(from: completedAt), forKey: .completedAt)
        }
    }
}

