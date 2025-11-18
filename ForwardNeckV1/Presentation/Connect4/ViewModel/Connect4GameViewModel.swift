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
    private var completionRecorded: Bool = false
    private var recordedMatchId: UUID?
    private var statsUpdated: Bool = false
    private var leaderboardRefreshed: Bool = false
    
    // MARK: - Dependencies
    
    private let matchStore = Connect4MatchStore.shared
    private let exerciseStore = ExerciseStore.shared
    private let leaderboardStore = LeaderboardStore.shared
    private let streakStore = StreakStore.shared
    private let goalsStore = GoalsStore.shared
    private let checkInStore = CheckInStore.shared
    
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
        
        // Don't reload if we've already completed this match
        // This prevents repeated calls to handleGameCompletion() and cascading updates
        if let recordedMatchId, recordedMatchId == match.id {
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
            
            // Update local game state immediately to show player's move
            game = matchStore.currentGame
            
            // Delay to ensure player's move is visible before AI responds
            // This gives time for the UI to update and show the player's move
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            // Reload game state to sync with server
            await loadGame()
            
            // If it's an AI match and it's now the AI's turn, trigger AI move
            // performAIMoveIfNeeded() already has its own delay (1-2 seconds) and reloads
            if let match = matchStore.currentMatch,
               match.isAIMatch,
               match.currentTurnDeviceId == Connect4Match.aiDeviceId {
                await matchStore.performAIMoveIfNeeded()
                // Reload after AI move completes (performAIMoveIfNeeded already reloads, but ensure UI updates)
                await loadGame()
            }
            
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
        
        // If we've already handled this match, keep sheet visible and skip side effects
        if let recordedMatchId, recordedMatchId == game.match.id {
            showingCompletion = true
            return
        }
        
        // Mark this match as handled immediately to prevent duplicate recording
        recordedMatchId = game.match.id
        completionRecorded = true
        
        // Determine result
        if didIWin {
            gameResult = .win
            
            // Only record exercise completion on wins (1 win = 1 exercise)
            await recordExerciseCompletion()
            
            // Update streaks and goals after recording completion
            await updateStreaksAndGoals()
            
            // Refresh leaderboard and related stats so UI reflects the win immediately
            await refreshLeaderboardStats()
        } else if isDraw {
            gameResult = .draw
        } else {
            gameResult = .loss
        }
        
        // Show completion screen (for win, loss, or draw)
        showingCompletion = true
    }
    
    private func recordExerciseCompletion() async {
        // Need current match to ensure we only count once
        guard let matchId = matchStore.currentMatch?.id else {
            Log.error("No active match when attempting to record completion")
            return
        }
        
        // Prevent duplicate completions for the same match
        guard !matchStore.hasRecordedExercise(for: matchId) else {
            Log.info("Exercise already recorded for match \(matchId)")
            return
        }
        
        // Find Connect 4 exercise
        guard let connect4Exercise = exerciseStore.allExercises().first(where: { $0.title == "Connect 4" }) else {
            Log.error("Connect 4 exercise not found")
            return
        }
        
        // Calculate game duration (use a reasonable estimate or actual time)
        let gameDuration = calculateGameDuration()
        
        // Determine time slot
        let timeSlot = ExerciseTimeSlot.currentTimeSlot() ?? .morning
        
        // Mark as recorded up front to prevent any re-entry during async work
        matchStore.markRecordedExercise(for: matchId)
        
        // Record completion (1 Connect 4 win = 1 exercise completion)
        await exerciseStore.recordCompletion(
            exerciseId: connect4Exercise.id,
            durationSeconds: gameDuration,
            timeSlot: timeSlot
        )
        
        Log.info("Recorded Connect 4 exercise completion (win = 1 exercise)")
    }
    
    /// Update streaks and goals after exercise completion
    /// This ensures today stats, leaderboard, streak, and progress bar are updated
    private func updateStreaksAndGoals() async {
        if statsUpdated { return }
        statsUpdated = true
        
        // Update streaks based on check-ins and exercise completions
        let allCheckIns = checkInStore.all()
        let allExercises = exerciseStore.completions
        
        let checkInDates = allCheckIns.map { $0.timestamp }
        let exerciseDates = allExercises.map { $0.completedAt }
        
        streakStore.updateDailyStreaks(checkIns: checkInDates, exerciseCompletions: exerciseDates)
        
        // Update custom goals progress so everything stays in sync
        goalsStore.updateAllGoalProgress()
        
        Log.info("Updated streaks and goals after Connect 4 win")
    }
    
    private func refreshLeaderboardStats() async {
        guard statsUpdated, !leaderboardRefreshed else { return }
        leaderboardRefreshed = true
        await leaderboardStore.refreshLeaderboard(force: true)
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
    
    /// Dismiss the completion sheet (called when user taps "Done")
    func dismissCompletion() {
        showingCompletion = false
    }
    
    func resetGame() {
        matchStore.stopMatch()
        game = nil
        gameResult = nil
        showingCompletion = false
        errorMessage = nil
        completionRecorded = false
        recordedMatchId = nil
        statsUpdated = false
        leaderboardRefreshed = false
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
