//
//  Connect4GameView.swift
//  NeckRotV1
//
//  Main Connect 4 game view.
//

import SwiftUI

struct Connect4GameView: View {
    @State private var viewModel = Connect4GameViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onExit: (() -> Void)?
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            if let game = viewModel.game {
                gameContentView(game: game)
            } else {
                loadingView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Exit") {
                    viewModel.resetGame()
                    dismiss()
                }
                .foregroundColor(.black)
            }
        }
        .sheet(isPresented: Binding(
            get: { viewModel.showingCompletion },
            set: { viewModel.showingCompletion = $0 }
        )) {
            completionSheet
                .presentationDetents([.medium]) // Small sheet similar to achievements
                .interactiveDismissDisabled(true) // User closes via button to avoid auto-dismiss
        }
        .task {
            await viewModel.loadGame()
            // Poll for game state updates - stop when game completes
            // Check showingCompletion at the start of each iteration to exit immediately
            while Connect4MatchStore.shared.currentMatch != nil && !viewModel.showingCompletion {
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
                // Double-check conditions before loading (prevents unnecessary loads after completion)
                guard Connect4MatchStore.shared.currentMatch != nil,
                      !viewModel.showingCompletion else {
                    break
                }
                // Only load if game hasn't been completed yet
                guard viewModel.game?.isFinished != true else {
                    Log.info("Game already finished, stopping poll")
                    break
                }
                await viewModel.loadGame()
            }
            Log.info("Stopped polling - game completed or match ended")
        }
    }
    
    private func handleCompletionDismissed() {
        viewModel.dismissCompletion()
        viewModel.resetGame()
        onExit?()
        dismiss()
    }
    
    @ViewBuilder
    private func gameContentView(game: Connect4Game) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Posture reminder (always visible)
                Connect4PostureReminderView()
                    .padding(.top, 16)
                
                // Game status
                gameStatusView(game: game)
                
                // Game board
                if let match = Connect4MatchStore.shared.currentMatch {
                    Connect4BoardView(
                        engine: game.engine,
                        currentPlayerDeviceId: viewModel.currentPlayerDeviceId,
                        match: match,
                        onColumnTapped: { column in
                            Task {
                                await viewModel.makeMove(column: column)
                            }
                        },
                        isMyTurn: viewModel.isMyTurn,
                        isLoading: viewModel.isLoading
                    )
                    .padding(.horizontal, 20)
                }
                
                // Turn indicator
                turnIndicatorView(game: game)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
            }
        }
    }
    
    @ViewBuilder
    private func gameStatusView(game: Connect4Game) -> some View {
        VStack(spacing: 8) {
            if game.isFinished {
                if viewModel.didIWin {
                    Text("🎉 You Won!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.green)
                } else if viewModel.isDraw {
                    Text("🤝 It's a Draw!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.orange)
                } else {
                    Text("😔 You Lost")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.red)
                }
            } else {
                Text("Playing Connect 4")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func turnIndicatorView(game: Connect4Game) -> some View {
        HStack(spacing: 12) {
            if viewModel.isMyTurn && !game.isFinished {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                Text("Your turn")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            } else if !game.isFinished {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 12, height: 12)
                Text("Waiting for opponent...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading game...")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.7))
        }
    }
    
    private var completionSheet: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                if let result = viewModel.gameResult {
                    // Result icon
                    Text(result == .win ? "🎉" : result == .loss ? "😔" : "🤝")
                        .font(.system(size: 64))
                    
                    // Result title
                    Text(result.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    // Result message
                    Text(result.message)
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Exercise completion badge - only show on wins
                    if result == .win {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Exercise Completed")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                }
                
                Button(action: {
                    handleCompletionDismissed()
                }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold))
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
                .padding(.top, 20)
            }
            .padding(.vertical, 40)
        }
    }
}

#Preview {
    NavigationStack {
        Connect4GameView()
    }
}
