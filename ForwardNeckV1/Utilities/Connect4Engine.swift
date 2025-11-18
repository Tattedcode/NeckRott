//
//  Connect4Engine.swift
//  NeckRotV1
//
//  Core Connect 4 game logic: board state, win detection, and move validation.
//

import Foundation

/// Represents a player in Connect 4
enum Connect4Player: Int, Codable {
    case none = 0
    case player1 = 1
    case player2 = 2
    
    /// Get the opponent player
    var opponent: Connect4Player {
        switch self {
        case .player1: return .player2
        case .player2: return .player1
        case .none: return .none
        }
    }
}

/// Core Connect 4 game engine
struct Connect4Engine {
    // Board dimensions: 7 columns x 6 rows
    static let columns = 7
    static let rows = 6
    static let winLength = 4
    
    /// Board representation: [column][row]
    /// Each cell contains 0 (empty), 1 (player1), or 2 (player2)
    var board: [[Connect4Player]]
    
    /// Current player whose turn it is
    var currentPlayer: Connect4Player
    
    /// Winner of the game (if any)
    var winner: Connect4Player
    
    /// Whether the game is over
    var isGameOver: Bool
    
    /// Whether the board is full (draw)
    var isBoardFull: Bool
    
    /// Initialize a new game
    init() {
        // Initialize empty board (7 columns x 6 rows)
        self.board = Array(repeating: Array(repeating: .none, count: Connect4Engine.rows), count: Connect4Engine.columns)
        self.currentPlayer = .player1
        self.winner = .none
        self.isGameOver = false
        self.isBoardFull = false
    }
    
    /// Initialize game from existing board state
    init(board: [[Connect4Player]], currentPlayer: Connect4Player) {
        self.board = board
        self.currentPlayer = currentPlayer
        self.winner = .none
        self.isGameOver = false
        self.isBoardFull = false
        
        // Check for win and board full status
        checkGameState()
    }
    
    /// Get the player at a specific position
    func player(at column: Int, row: Int) -> Connect4Player {
        guard column >= 0 && column < Connect4Engine.columns &&
              row >= 0 && row < Connect4Engine.rows else {
            return .none
        }
        return board[column][row]
    }
    
    /// Check if a column is full
    func isColumnFull(_ column: Int) -> Bool {
        guard column >= 0 && column < Connect4Engine.columns else {
            return true
        }
        return board[column][Connect4Engine.rows - 1] != .none
    }
    
    /// Get the next available row in a column (returns nil if column is full)
    func nextAvailableRow(in column: Int) -> Int? {
        guard column >= 0 && column < Connect4Engine.columns else {
            return nil
        }
        
        // Find the first empty row from the bottom
        for row in 0..<Connect4Engine.rows {
            if board[column][row] == .none {
                return row
            }
        }
        return nil // Column is full
    }
    
    /// Check if a move is valid
    func isValidMove(column: Int) -> Bool {
        guard column >= 0 && column < Connect4Engine.columns else {
            return false
        }
        return !isColumnFull(column) && !isGameOver
    }
    
    /// Make a move (returns new engine state with the move applied)
    func makeMove(column: Int) -> Connect4Engine? {
        guard isValidMove(column: column) else {
            return nil
        }
        
        guard let row = nextAvailableRow(in: column) else {
            return nil
        }
        
        // Create a copy of the board
        var newBoard = board
        newBoard[column][row] = currentPlayer
        
        // Create new engine state
        var newEngine = Connect4Engine(board: newBoard, currentPlayer: currentPlayer.opponent)
        
        // Check if this move resulted in a win
        if newEngine.checkWin(at: column, row: row, player: currentPlayer) {
            newEngine.winner = currentPlayer
            newEngine.isGameOver = true
        } else {
            // Check if board is full (draw)
            newEngine.checkBoardFull()
            if newEngine.isBoardFull {
                newEngine.isGameOver = true
            }
        }
        
        return newEngine
    }
    
    /// Check game state (win, draw, etc.)
    private mutating func checkGameState() {
        // Check all positions for wins
        for column in 0..<Connect4Engine.columns {
            for row in 0..<Connect4Engine.rows {
                let player = board[column][row]
                if player != .none {
                    if checkWin(at: column, row: row, player: player) {
                        self.winner = player
                        self.isGameOver = true
                        return
                    }
                }
            }
        }
        
        // Check if board is full
        checkBoardFull()
        if isBoardFull {
            self.isGameOver = true
        }
    }
    
    /// Check if board is full
    private mutating func checkBoardFull() {
        for column in 0..<Connect4Engine.columns {
            if !isColumnFull(column) {
                self.isBoardFull = false
                return
            }
        }
        self.isBoardFull = true
    }
    
    /// Check if a specific position results in a win for the given player
    func checkWin(at column: Int, row: Int, player: Connect4Player) -> Bool {
        // Check horizontal, vertical, and both diagonals
        return checkHorizontalWin(at: column, row: row, player: player) ||
               checkVerticalWin(at: column, row: row, player: player) ||
               checkDiagonalWin1(at: column, row: row, player: player) ||
               checkDiagonalWin2(at: column, row: row, player: player)
    }
    
    /// Check for horizontal win (left-right)
    private func checkHorizontalWin(at column: Int, row: Int, player: Connect4Player) -> Bool {
        var count = 1 // Count the current position
        
        // Check left
        var c = column - 1
        while c >= 0 && board[c][row] == player {
            count += 1
            c -= 1
        }
        
        // Check right
        c = column + 1
        while c < Connect4Engine.columns && board[c][row] == player {
            count += 1
            c += 1
        }
        
        return count >= Connect4Engine.winLength
    }
    
    /// Check for vertical win (up-down)
    private func checkVerticalWin(at column: Int, row: Int, player: Connect4Player) -> Bool {
        var count = 1 // Count the current position
        
        // Check down
        var r = row - 1
        while r >= 0 && board[column][r] == player {
            count += 1
            r -= 1
        }
        
        // Check up
        r = row + 1
        while r < Connect4Engine.rows && board[column][r] == player {
            count += 1
            r += 1
        }
        
        return count >= Connect4Engine.winLength
    }
    
    /// Check for diagonal win (top-left to bottom-right)
    private func checkDiagonalWin1(at column: Int, row: Int, player: Connect4Player) -> Bool {
        var count = 1 // Count the current position
        
        // Check top-left
        var c = column - 1
        var r = row + 1
        while c >= 0 && r < Connect4Engine.rows && board[c][r] == player {
            count += 1
            c -= 1
            r += 1
        }
        
        // Check bottom-right
        c = column + 1
        r = row - 1
        while c < Connect4Engine.columns && r >= 0 && board[c][r] == player {
            count += 1
            c += 1
            r -= 1
        }
        
        return count >= Connect4Engine.winLength
    }
    
    /// Check for diagonal win (top-right to bottom-left)
    private func checkDiagonalWin2(at column: Int, row: Int, player: Connect4Player) -> Bool {
        var count = 1 // Count the current position
        
        // Check top-right
        var c = column + 1
        var r = row + 1
        while c < Connect4Engine.columns && r < Connect4Engine.rows && board[c][r] == player {
            count += 1
            c += 1
            r += 1
        }
        
        // Check bottom-left
        c = column - 1
        r = row - 1
        while c >= 0 && r >= 0 && board[c][r] == player {
            count += 1
            c -= 1
            r -= 1
        }
        
        return count >= Connect4Engine.winLength
    }
    
    /// Convert board to array representation for storage/transmission
    func boardToArray() -> [[Int]] {
        return board.map { column in
            column.map { $0.rawValue }
        }
    }
    
    /// Initialize board from array representation
    static func boardFromArray(_ array: [[Int]]) -> [[Connect4Player]] {
        return array.map { column in
            column.map { Connect4Player(rawValue: $0) ?? .none }
        }
    }
}

