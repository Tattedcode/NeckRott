//
//  Theme.swift
//  ForwardNeckV1
//
//  Central place for colors, spacing, and shared UI constants.
//

import SwiftUI

enum Theme {
    // Background gradient - dark pink → plum → dark purple (static, high contrast)
    static var backgroundGradient: LinearGradient {
        Log.info("Theme.backgroundGradient applied (pink→purple)")
        return LinearGradient(
            colors: [
                Color(red: 0.478, green: 0.118, blue: 0.361), // dark pink
                Color(red: 0.341, green: 0.102, blue: 0.376), // plum
                Color(red: 0.176, green: 0.039, blue: 0.290)  // dark purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // Semi-transparent card background used across the app
    // Slightly increased opacity for readability on the lighter background
    static let cardBackground: Color = Color.white.opacity(0.12)

    // Segmented pill states
    static let pillSelected: Color = Color.blue.opacity(0.9)
    static let pillUnselected: Color = Color.white.opacity(0.16)

    // Text colors - revert to white for consistency on our gradient
    static let primaryText: Color = .white
    static let secondaryText: Color = Color.white.opacity(0.8)
}