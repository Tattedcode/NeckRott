//
//  Connect4MatchmakingViewModel.swift
//  NeckRotV1
//
//  ViewModel for Connect 4 matchmaking flow.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class Connect4MatchmakingViewModel {
    // MARK: - Published State
    
    var isMatchmaking: Bool = false
    var matchFound: Bool = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let matchStore = Connect4MatchStore.shared
    
    // MARK: - Actions
    
    func startMatchmaking() async {
        guard !isMatchmaking else { return }
        
        isMatchmaking = true
        matchFound = false
        errorMessage = nil
        
        do {
            let match = try await matchStore.startMatchmaking()
            
            // Check if match is ready (has opponent)
            if match.isReady {
                matchFound = true
                Log.info("Match found: \(match.id)")
            } else {
                // Keep polling until opponent joins
                await waitForOpponent(matchId: match.id)
            }
        } catch {
            errorMessage = "Failed to find match: \(error.localizedDescription)"
            Log.error("Matchmaking error: \(error.localizedDescription)")
            isMatchmaking = false
        }
    }
    
    func waitForOpponent(matchId: UUID) async {
        // Poll until opponent joins (max 60 seconds)
        let maxWaitTime: TimeInterval = 60
        let pollInterval: TimeInterval = 2
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < maxWaitTime {
            // Check if matchmaking was cancelled
            guard isMatchmaking else {
                Log.info("Matchmaking cancelled - stopping waitForOpponent")
                return
            }
            
            // Check if match still exists
            guard let match = matchStore.currentMatch, match.id == matchId else {
                Log.info("Match was cancelled - stopping waitForOpponent")
                return
            }
            
            try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            
            // Check again after sleep
            guard isMatchmaking, let existingMatch = matchStore.currentMatch, existingMatch.id == matchId else {
                Log.info("Matchmaking cancelled during wait")
                return
            }
            
            // Check match status
            await matchStore.loadGameState(matchId: matchId)
            
            if let match = matchStore.currentMatch, match.isReady {
                // Match is ready - update state
                matchFound = true
                Log.info("Opponent joined match: \(matchId)")
                return
            }
        }
        
        // Timeout - no opponent found (only if still matchmaking)
        if isMatchmaking {
            errorMessage = "No opponent found. Please try again."
            isMatchmaking = false
            Log.info("Matchmaking timeout for match: \(matchId)")
        }
    }
    
    func cancelMatchmaking() {
        matchStore.stopMatch()
        isMatchmaking = false
        matchFound = false
        errorMessage = nil
    }
}

