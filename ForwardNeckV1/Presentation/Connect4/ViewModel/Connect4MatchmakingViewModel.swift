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
    var elapsedTime: TimeInterval = 0 // Track elapsed time for UI updates
    
    // MARK: - Dependencies
    
    private let matchStore = Connect4MatchStore.shared
    
    // MARK: - Actions
    
    func startMatchmaking() async {
        guard !isMatchmaking else { return }
        
        isMatchmaking = true
        matchFound = false
        errorMessage = nil
        elapsedTime = 0 // Reset elapsed time
        
        do {
            let match = try await self.matchStore.startMatchmaking()
            
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
        // Poll until opponent joins (max 7 seconds before falling back to AI)
        let maxWaitTime: TimeInterval = 7
        let pollInterval: TimeInterval = 2
        let startTime = Date()
        
        while Date().timeIntervalSince(startTime) < maxWaitTime {
            // Check if matchmaking was cancelled
            guard isMatchmaking else {
                Log.info("Matchmaking cancelled - stopping waitForOpponent")
                return
            }
            
            // Check if match still exists
            guard let match = self.matchStore.currentMatch, match.id == matchId else {
                Log.info("Match was cancelled - stopping waitForOpponent")
                return
            }
            
            // Update elapsed time for UI
            elapsedTime = Date().timeIntervalSince(startTime)
            
            try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
            
            // Check again after sleep
            guard isMatchmaking, let existingMatch = self.matchStore.currentMatch, existingMatch.id == matchId else {
                Log.info("Matchmaking cancelled during wait")
                return
            }
            
            // Update elapsed time again
            elapsedTime = Date().timeIntervalSince(startTime)
            
            // Check match status
            await self.matchStore.loadGameState(matchId: matchId)
            
            if let match = self.matchStore.currentMatch, match.isReady {
                // Match is ready - update state
                matchFound = true
                Log.info("Opponent joined match: \(matchId)")
                return
            }
        }
        
        // Timeout after 7 seconds - create AI match (only if still matchmaking)
        if isMatchmaking {
            elapsedTime = maxWaitTime // Ensure elapsed time shows we've reached the timeout
            Log.info("No human opponent found after 7 seconds - creating AI match")
            
            // Check if task was cancelled before proceeding
            guard !Task.isCancelled else {
                Log.info("Task was cancelled before creating AI match")
                return
            }
            
            do {
                // Stop the current match
                self.matchStore.stopMatch()
                
                // Small delay to ensure cleanup completes
                // Check cancellation during delay
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                guard !Task.isCancelled else {
                    Log.info("Task was cancelled during cleanup delay")
                    return
                }
                
                // Create AI match
                // Call directly - cancellation will be handled by checking isMatchmaking flag
                // The view's .task modifier cancellation won't affect this since we check isMatchmaking
                let aiMatch = try await self.matchStore.createAIMatch()
                
                // Check cancellation after creating match
                guard !Task.isCancelled else {
                    Log.info("Task was cancelled after creating AI match")
                    return
                }
                
                // Small delay to ensure match is set in store
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                // Verify match was created and set
                guard self.matchStore.currentMatch?.id == aiMatch.id else {
                    Log.error("AI match was created but not set in store")
                    errorMessage = "Failed to create AI match"
                    isMatchmaking = false
                    return
                }
                
                matchFound = true
                isMatchmaking = false // Stop matchmaking since we found AI opponent
                Log.info("AI match created successfully: \(aiMatch.id), isReady: \(aiMatch.isReady), isAIMatch: \(aiMatch.isAIMatch)")
            } catch {
                // Check if it's a cancellation error
                if error is CancellationError {
                    Log.info("AI match creation was cancelled (expected if user navigates away)")
                    return
                }
                errorMessage = "Failed to create AI match: \(error.localizedDescription)"
                isMatchmaking = false
                Log.error("Failed to create AI match: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelMatchmaking() {
        self.matchStore.stopMatch()
        isMatchmaking = false
        matchFound = false
        errorMessage = nil
    }
}

