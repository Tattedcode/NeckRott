//
//  Connect4GameViewModel.swift
//  NeckRotV1
//
//  ViewModel for managing Connect 4 game state and interactions.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class Connect4GameViewModel {
    // MARK: - Published State
    
    var game: Connect4Game?
    var isLoading: Bool = false
    var errorMessage: String?
    var showingCompletion: Bool = false
    var gameResult: GameResult?
    
    // MARK: - Dependencies
    
    private let matchStore = Connect4MatchStore.shared
    private let exerciseStore = ExerciseStore.shared
    private let leaderboardStore = LeaderboardStore.shared
    
    // MARK: - Computed Properties
    
    var currentPlayerDeviceId: String {
        leaderboardStore.userProfile.deviceId
    }
    
    var isMyTurn: Bool {
        guard let game = game else { return false }
        return game.isMyTurn(deviceId: currentPlayerDeviceId)
    }
    
    var opponentDeviceId: String? {
        guard let game = game else { return nil }
        return game.match.opponentDeviceId(for: currentPlayerDeviceId)
    }
    
    var isGameFinished: Bool {
        return game?.isFinished ?? false
    }
    
    var winnerDeviceId: String? {
        return game?.winnerDeviceId
    }
    
    var didIWin: Bool {
        return winnerDeviceId == currentPlayerDeviceId
    }
    
    var isDraw: Bool {
        guard let game = game else { return false }
        return game.engine.isBoardFull && game.engine.winner == .none
    }
    
    // MARK: - Initialization
    
    init() {
        // Observe match store changes
        Task {
            await observeMatchStore()
        }
    }
    
    // MARK: - Observation
    
    private func observeMatchStore() async {
        // Load initial game state if match exists
        if matchStore.currentMatch != nil {
            await loadGame()
        }
    }
    
    // MARK: - Game Actions
    
    func loadGame() async {
        guard let match = matchStore.currentMatch else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        await matchStore.loadGameState(matchId: match.id)
        
        // Update local game state
        game = matchStore.currentGame
        
        // Check if game is finished and handle completion
        if let game = game, game.isFinished {
            await handleGameCompletion()
        }
        
        isLoading = false
    }
    
    func makeMove(column: Int) async {
        guard !isLoading else { return }
        guard isMyTurn else {
            errorMessage = "It's not your turn"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await matchStore.submitMove(column: column)
            
            // Reload game state
            await loadGame()
            
            // Check if game is finished
            if isGameFinished {
                await handleGameCompletion()
            }
        } catch {
            errorMessage = error.localizedDescription
            Log.error("Failed to make move: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func handleGameCompletion() async {
        guard let game = game, game.isFinished else { return }
        
        // Determine result
        if didIWin {
            gameResult = .win
        } else if isDraw {
            gameResult = .draw
        } else {
            gameResult = .loss
        }
        
        // Record exercise completion
        await recordExerciseCompletion()
        
        // Show completion screen
        showingCompletion = true
    }
    
    private func recordExerciseCompletion() async {
        // Find Connect 4 exercise
        guard let connect4Exercise = exerciseStore.allExercises().first(where: { $0.title == "Connect 4" }) else {
            Log.error("Connect 4 exercise not found")
            return
        }
        
        // Calculate game duration (use a reasonable estimate or actual time)
        let gameDuration = calculateGameDuration()
        
        // Determine time slot
        let timeSlot = ExerciseTimeSlot.currentTimeSlot() ?? .morning
        
        // Record completion
        await exerciseStore.recordCompletion(
            exerciseId: connect4Exercise.id,
            durationSeconds: gameDuration,
            timeSlot: timeSlot
        )
        
        Log.info("Recorded Connect 4 exercise completion")
    }
    
    private func calculateGameDuration() -> Int {
        // Estimate duration based on number of moves
        // Average Connect 4 game takes about 5-10 minutes
        guard let game = game else { return 300 } // Default 5 minutes
        
        let moveCount = game.moves.count
        // Estimate: ~30 seconds per move on average
        let estimatedSeconds = moveCount * 30
        // Clamp between 2 minutes and 15 minutes
        return max(120, min(900, estimatedSeconds))
    }
    
    func resetGame() {
        matchStore.stopMatch()
        game = nil
        gameResult = nil
        showingCompletion = false
        errorMessage = nil
    }
}

// MARK: - Game Result

enum GameResult {
    case win
    case loss
    case draw
    
    var title: String {
        switch self {
        case .win: return "You Won!"
        case .loss: return "You Lost"
        case .draw: return "It's a Draw!"
        }
    }
    
    var message: String {
        switch self {
        case .win: return "Great job! You maintained good posture and won the game."
        case .loss: return "Good game! Keep practicing your posture."
        case .draw: return "Well played! Both players maintained good posture."
        }
    }
}

