//
//  Connect4MatchmakingView.swift
//  NeckRotV1
//
//  Matchmaking view for finding Connect 4 opponents.
//

import SwiftUI

struct Connect4MatchmakingView: View {
    @State private var viewModel = Connect4MatchmakingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Title
                VStack(spacing: 12) {
                    Text("Connect 4")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Play against other players while maintaining good posture")
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Check if match already exists and is ready (including AI matches)
                if let match = Connect4MatchStore.shared.currentMatch, (match.isReady || match.isAIMatch) {
                    matchFoundView
                } else if viewModel.isMatchmaking {
                    matchmakingInProgressView
                } else if viewModel.matchFound {
                    matchFoundView
                } else {
                    startMatchmakingView
                }
                
                Spacer()
                
                // Cancel button
                if viewModel.isMatchmaking || Connect4MatchStore.shared.currentMatch != nil {
                    Button(action: {
                        viewModel.cancelMatchmaking()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    viewModel.cancelMatchmaking()
                    dismiss()
                }
                .foregroundColor(.black)
            }
        }
        .task {
            // Check if matchmaking is already in progress from HomeView
            if let existingMatch = Connect4MatchStore.shared.currentMatch {
                // Matchmaking was already started - update viewModel state
                viewModel.isMatchmaking = true
                // Check if it's an AI match or ready match
                if existingMatch.isAIMatch || existingMatch.isReady {
                    viewModel.matchFound = true
                    viewModel.isMatchmaking = false
                } else {
                    // Wait for opponent if match exists but isn't ready
                    await viewModel.waitForOpponent(matchId: existingMatch.id)
                }
            } else {
                // No match exists - automatically start matchmaking when view appears
                await viewModel.startMatchmaking()
            }
        }
        .onChange(of: Connect4MatchStore.shared.currentMatch) { oldValue, newValue in
            if let match = newValue {
                // Check if match is ready (has opponent) or is an AI match
                if match.isReady || match.isAIMatch {
                    viewModel.matchFound = true
                    viewModel.isMatchmaking = false
                    Log.info("Match found via onChange - isReady: \(match.isReady), isAIMatch: \(match.isAIMatch)")
                }
            } else {
                // Match was cleared
                viewModel.matchFound = false
            }
        }
        .onChange(of: viewModel.matchFound) { oldValue, newValue in
            // Force view update when matchFound changes
            if newValue {
                Log.info("Match found flag set to true - should show match found view")
            }
        }
    }
    
    private var startMatchmakingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.7))
            
            Button(action: {
                Task {
                    await viewModel.startMatchmaking()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Find Opponent")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Theme.gradientBrightPink, Theme.gradientBrightBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    private var matchmakingInProgressView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Finding opponent...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
            
            // Show different message after 7 seconds
            if viewModel.elapsedTime >= 7 {
                Text("No players found. Matching with opponent...")
                    .font(.system(size: 14))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            } else {
            Text("Please wait while we match you with another player")
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            }
        }
    }
    
    private var matchFoundView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("Match Found!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Text("Starting game...")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}

#Preview {
    NavigationStack {
        Connect4MatchmakingView()
    }
}

