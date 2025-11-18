//
//  Connect4AI.swift
//  ForwardNeckV1
//
//  Simple fallback opponent for single-player testing.
//

import Foundation

/// Extremely lightweight heuristic AI for Connect 4.
/// Prefers center columns and otherwise picks any valid column.
struct Connect4AI {
    /// Choose the next column for the AI to drop a piece.
    /// - Parameter engine: Current board + turn information.
    /// - Returns: Column index (0-6) or nil if no moves remain.
    func selectColumn(for engine: Connect4Engine) -> Int? {
        let availableColumns = (0..<Connect4Engine.columns).filter { engine.isValidMove(column: $0) }
        guard !availableColumns.isEmpty else { return nil }
        
        // Try center-first ordering for more natural play.
        let center = Connect4Engine.columns / 2
        let ordered = availableColumns.sorted { lhs, rhs in
            let lhsDistance = abs(center - lhs)
            let rhsDistance = abs(center - rhs)
            if lhsDistance == rhsDistance {
                return lhs < rhs
            }
            return lhsDistance < rhsDistance
        }
        
        // Randomize within the ordered list so games feel slightly different.
        let topChoices = Array(ordered.prefix(3))
        return topChoices.randomElement() ?? ordered.first
    }
}

