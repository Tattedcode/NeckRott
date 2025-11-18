//
//  Connect4BoardView.swift
//  NeckRotV1
//
//  Connect 4 game board view component.
//

import SwiftUI

struct Connect4BoardView: View {
    let engine: Connect4Engine
    let currentPlayerDeviceId: String
    let match: Connect4Match
    let onColumnTapped: (Int) -> Void
    let isMyTurn: Bool
    let isLoading: Bool
    
    // Board dimensions
    private let columns = 7
    private let rows = 6
    private let cellSize: CGFloat = 40
    private let spacing: CGFloat = 4
    
    var body: some View {
        VStack(spacing: 8) {
            // Column headers (for tapping)
            HStack(spacing: spacing) {
                ForEach(0..<columns, id: \.self) { column in
                    // Keep the indicators visible during brief loading states to avoid flashing
                    let isEnabled = isMyTurn && !isLoading && engine.isValidMove(column: column)
                    let shouldShow = isMyTurn && engine.isValidMove(column: column)
                    
                    Button(action: {
                        if isEnabled {
                            onColumnTapped(column)
                        }
                    }) {
                        Circle()
                            .fill(shouldShow ? Color.blue.opacity(0.3) : Color.clear)
                            .frame(width: cellSize, height: cellSize)
                            .overlay(
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 16))
                                    .foregroundColor(shouldShow ? .blue : .clear)
                            )
                    }
                    .disabled(!isEnabled)
                    .allowsHitTesting(isEnabled)
                }
            }
            .padding(.bottom, 8)
            
            // Game board
            VStack(spacing: spacing) {
                ForEach((0..<rows).reversed(), id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { column in
                            cellView(column: column, row: row)
                        }
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.2))
            )
        }
    }
    
    @ViewBuilder
    private func cellView(column: Int, row: Int) -> some View {
        let player = engine.player(at: column, row: row)
        let playerNumber = match.playerNumber(for: currentPlayerDeviceId) ?? 1
        let isMyPiece = (player == .player1 && playerNumber == 1) || (player == .player2 && playerNumber == 2)
        
        Circle()
            .fill(pieceColor(for: player))
            .frame(width: cellSize, height: cellSize)
            .overlay(
                Circle()
                    .stroke(isMyPiece ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .shadow(color: player != .none ? Color.black.opacity(0.2) : Color.clear, radius: 2, x: 0, y: 1)
    }
    
    private func pieceColor(for player: Connect4Player) -> Color {
        switch player {
        case .none:
            return Color.white.opacity(0.3)
        case .player1:
            return Color.red
        case .player2:
            return Color.yellow
        }
    }
}

#Preview {
    Connect4BoardView(
        engine: Connect4Engine(),
        currentPlayerDeviceId: "test-device",
        match: Connect4Match(player1DeviceId: "test-device"),
        onColumnTapped: { _ in },
        isMyTurn: true,
        isLoading: false
    )
    .padding()
    .background(Theme.backgroundGradient)
}
