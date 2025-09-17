//
//  Theme.swift
//  ForwardNeckV1
//
//  Central place for colors, spacing, and shared UI constants.
//

import SwiftUI

enum Theme {
    // Background gradient - darker theme for better contrast
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.05, blue: 0.15),  // Very dark blue-purple
                Color(red: 0.1, green: 0.05, blue: 0.2),    // Dark purple
                Color(red: 0.05, green: 0.1, blue: 0.25)    // Dark blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Semi-transparent card background used across the app - enhanced for darker theme
    static let cardBackground: Color = Color.white.opacity(0.08)

    // Segmented pill states - enhanced for darker theme
    static let pillSelected: Color = Color.blue.opacity(0.9)
    static let pillUnselected: Color = Color.white.opacity(0.12)

    // Text colors
    static let primaryText: Color = .white
    static let secondaryText: Color = Color.white.opacity(0.8)
}