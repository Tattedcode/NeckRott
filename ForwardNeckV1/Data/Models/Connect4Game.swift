//
//  Connect4Game.swift
//  NeckRotV1
//
//  Data model for Connect 4 game state.
//

import Foundation

/// Represents the complete game state for Connect 4
struct Connect4Game {
    let match: Connect4Match
    let engine: Connect4Engine
    let moves: [Connect4Move]
    
    /// Initialize game from match and moves
    init(match: Connect4Match, moves: [Connect4Move]) {
        self.match = match
        self.moves = moves.sorted { $0.moveNumber < $1.moveNumber }
        
        // Rebuild board state from moves
        var engine = Connect4Engine()
        var moveCount = 0
        
        for move in self.moves {
            // Determine which player made the move
            let playerNumber = match.playerNumber(for: move.playerDeviceId) ?? 1
            let player = Connect4Player(rawValue: playerNumber) ?? .player1
            
            // Set current player to the player making the move
            engine = Connect4Engine(
                board: engine.boardToArray().map { column in
                    column.map { Connect4Player(rawValue: $0) ?? .none }
                },
                currentPlayer: player
            )
            
            // Apply the move
            if let newEngine = engine.makeMove(column: move.columnIndex) {
                engine = newEngine
                moveCount += 1
            }
        }
        
        // Set current player based on match state (who should move next)
        if let currentTurnDeviceId = match.currentTurnDeviceId,
           let playerNumber = match.playerNumber(for: currentTurnDeviceId) {
            let currentPlayer = Connect4Player(rawValue: playerNumber) ?? .player1
            engine = Connect4Engine(
                board: engine.boardToArray().map { column in
                    column.map { Connect4Player(rawValue: $0) ?? .none }
                },
                currentPlayer: currentPlayer
            )
        } else {
            // If no current turn set, determine from move count
            // Even moves = player1's turn, odd moves = player2's turn
            let nextPlayerNumber = (moveCount % 2 == 0) ? 1 : 2
            let currentPlayer = Connect4Player(rawValue: nextPlayerNumber) ?? .player1
            engine = Connect4Engine(
                board: engine.boardToArray().map { column in
                    column.map { Connect4Player(rawValue: $0) ?? .none }
                },
                currentPlayer: currentPlayer
            )
        }
        
        self.engine = engine
    }
    
    /// Get player for a specific device ID
    func player(for deviceId: String) -> Connect4Player? {
        guard let playerNumber = match.playerNumber(for: deviceId) else {
            return nil
        }
        return Connect4Player(rawValue: playerNumber)
    }
    
    /// Check if it's a specific device's turn
    func isMyTurn(deviceId: String) -> Bool {
        return match.isMyTurn(deviceId: deviceId) && !engine.isGameOver
    }
    
    /// Check if game is finished
    var isFinished: Bool {
        return engine.isGameOver || match.isFinished
    }
    
    /// Get winner device ID
    var winnerDeviceId: String? {
        if let winner = match.winnerDeviceId {
            return winner
        }
        if engine.winner != .none {
            // Determine winner from engine state
            if engine.winner == .player1 {
                return match.player1DeviceId
            } else if engine.winner == .player2 {
                return match.player2DeviceId
            }
        }
        return nil
    }
}

