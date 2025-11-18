//
//  Connect4MatchStore.swift
//  NeckRotV1
//
//  Local match state management for Connect 4 games.
//

import Foundation

/// Store for managing local Connect 4 match state
@MainActor
final class Connect4MatchStore: ObservableObject {
    static let shared = Connect4MatchStore()
    
    @Published private(set) var currentMatch: Connect4Match?
    @Published private(set) var currentGame: Connect4Game?
    @Published private(set) var moves: [Connect4Move] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    private let leaderboardStore = LeaderboardStore.shared
    
    // Polling timer for real-time updates
    private var pollingTimer: Timer?
    private let pollingInterval: TimeInterval = 3.0 // Poll every 3 seconds
    
    // Task tracking for cancellation
    private var currentMatchmakingTask: Task<Void, Never>?
    
    private init() {
        Log.info("Connect4MatchStore initialized")
    }
    
    // MARK: - Match Management
    
    /// Start matchmaking - find or create a match
    func startMatchmaking() async throws -> Connect4Match {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        let deviceId = leaderboardStore.userProfile.deviceId
        
        do {
            // First, try to find an existing waiting match
            if let waitingMatch = try await supabaseService.findWaitingConnect4Match(excludingDeviceId: deviceId) {
                // Join the waiting match
                let joinedMatch = try await supabaseService.joinConnect4Match(matchId: waitingMatch.id, deviceId: deviceId)
                currentMatch = joinedMatch
                await loadGameState(matchId: joinedMatch.id)
                startPolling(matchId: joinedMatch.id)
                Log.info("Joined existing match: \(joinedMatch.id)")
                return joinedMatch
            } else {
                // Create a new match and wait for opponent
                let newMatch = try await supabaseService.createConnect4Match(deviceId: deviceId)
                currentMatch = newMatch
                await loadGameState(matchId: newMatch.id)
                startPolling(matchId: newMatch.id)
                Log.info("Created new match: \(newMatch.id)")
                return newMatch
            }
        } catch {
            errorMessage = "Failed to start matchmaking: \(error.localizedDescription)"
            Log.error("Matchmaking error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Load game state for a match
    func loadGameState(matchId: UUID) async {
        // Check if match was cancelled before loading
        guard currentMatch?.id == matchId else {
            Log.info("Skipping loadGameState - match was cancelled or changed")
            return
        }
        
        do {
            // Fetch match and moves
            let match = try await supabaseService.getConnect4Match(matchId: matchId)
            let matchMoves = try await supabaseService.getConnect4Moves(matchId: matchId)
            
            // Double-check match still exists (might have been cancelled during fetch)
            guard currentMatch?.id == matchId else {
                Log.info("Match was cancelled during loadGameState fetch")
                return
            }
            
            // Update local state
            currentMatch = match
            moves = matchMoves
            
            // Create game state
            currentGame = Connect4Game(match: match, moves: matchMoves)
            
            Log.info("Loaded game state for match: \(matchId), moves: \(matchMoves.count)")
        } catch {
            // Ignore cancellation errors - they're expected when user cancels
            if error.localizedDescription.contains("cancelled") {
                Log.info("Load game state cancelled (expected when user cancels matchmaking)")
                return
            }
            errorMessage = "Failed to load game state: \(error.localizedDescription)"
            Log.error("Failed to load game state: \(error.localizedDescription)")
        }
    }
    
    /// Submit a move
    func submitMove(column: Int) async throws {
        guard let match = currentMatch else {
            throw Connect4Error.noActiveMatch
        }
        
        let deviceId = leaderboardStore.userProfile.deviceId
        
        // Verify it's our turn
        guard match.isMyTurn(deviceId: deviceId) else {
            throw Connect4Error.notYourTurn
        }
        
        // Get current game state
        guard let game = currentGame else {
            throw Connect4Error.gameNotLoaded
        }
        
        // Validate move
        guard game.engine.isValidMove(column: column) else {
            throw Connect4Error.invalidMove
        }
        
        // Calculate row
        guard let row = game.engine.nextAvailableRow(in: column) else {
            throw Connect4Error.invalidMove
        }
        
        // Make move locally first (optimistic update)
        guard let newEngine = game.engine.makeMove(column: column) else {
            throw Connect4Error.invalidMove
        }
        
        // Update local state optimistically
        let moveNumber = moves.count + 1
        let newMove = Connect4Move(
            matchId: match.id,
            playerDeviceId: deviceId,
            columnIndex: column,
            rowIndex: row,
            moveNumber: moveNumber
        )
        moves.append(newMove)
        
        // Update game state
        var updatedMatch = match
        updatedMatch.currentTurnDeviceId = match.opponentDeviceId(for: deviceId)
        
        // Check for win
        if newEngine.isGameOver {
            if newEngine.winner != .none {
                let winnerDeviceId = newEngine.winner == .player1 ? match.player1DeviceId : match.player2DeviceId
                updatedMatch.winnerDeviceId = winnerDeviceId
                updatedMatch.status = .completed
                updatedMatch.completedAt = Date()
            } else if newEngine.isBoardFull {
                // Draw
                updatedMatch.status = .completed
                updatedMatch.completedAt = Date()
            }
        }
        
        currentMatch = updatedMatch
        currentGame = Connect4Game(match: updatedMatch, moves: moves)
        
        // Submit to server
        do {
            let serverMove = try await supabaseService.submitConnect4Move(
                matchId: match.id,
                deviceId: deviceId,
                column: column,
                row: row,
                moveNumber: moveNumber
            )
            
            // Update with server response
            if let index = moves.firstIndex(where: { $0.id == serverMove.id }) {
                moves[index] = serverMove
            } else {
                moves.append(serverMove)
            }
            
            // Update match status if game is over
            if newEngine.isGameOver {
                let updatedMatch = try await supabaseService.updateConnect4MatchStatus(
                    matchId: match.id,
                    status: updatedMatch.status,
                    winnerDeviceId: updatedMatch.winnerDeviceId,
                    currentTurnDeviceId: updatedMatch.currentTurnDeviceId
                )
                currentMatch = updatedMatch
                currentGame = Connect4Game(match: updatedMatch, moves: moves)
                stopPolling()
            } else {
                // Update turn
                let updatedMatch = try await supabaseService.updateConnect4MatchStatus(
                    matchId: match.id,
                    status: .inProgress,
                    winnerDeviceId: nil,
                    currentTurnDeviceId: updatedMatch.currentTurnDeviceId
                )
                currentMatch = updatedMatch
                currentGame = Connect4Game(match: updatedMatch, moves: moves)
            }
            
            Log.info("Successfully submitted move: column=\(column), row=\(row)")
        } catch {
            // Revert optimistic update on error
            moves.removeLast()
            await loadGameState(matchId: match.id)
            throw error
        }
    }
    
    /// Stop current match and cleanup
    func stopMatch() {
        // Cancel any ongoing matchmaking tasks
        currentMatchmakingTask?.cancel()
        currentMatchmakingTask = nil
        
        // Stop polling
        stopPolling()
        
        // Clear state
        currentMatch = nil
        currentGame = nil
        moves = []
        errorMessage = nil
        isLoading = false
        
        Log.info("Stopped match and cancelled all operations")
    }
    
    // MARK: - Polling
    
    private func startPolling(matchId: UUID) {
        stopPolling()
        
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollingInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.pollMatchState(matchId: matchId)
            }
        }
        
        Log.info("Started polling for match: \(matchId)")
    }
    
    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        Log.info("Stopped polling")
    }
    
    private func pollMatchState(matchId: UUID) async {
        // Check if match still exists and matches the ID
        guard let match = currentMatch, match.id == matchId else {
            stopPolling()
            Log.info("Stopped polling - match was cancelled or changed")
            return
        }
        
        await loadGameState(matchId: matchId)
    }
}

// MARK: - Connect 4 Errors

enum Connect4Error: LocalizedError {
    case noActiveMatch
    case notYourTurn
    case gameNotLoaded
    case invalidMove
    
    var errorDescription: String? {
        switch self {
        case .noActiveMatch:
            return "No active match found"
        case .notYourTurn:
            return "It's not your turn"
        case .gameNotLoaded:
            return "Game state not loaded"
        case .invalidMove:
            return "Invalid move"
        }
    }
}

