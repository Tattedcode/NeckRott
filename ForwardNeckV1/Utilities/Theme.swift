//
//  Theme.swift
//  ForwardNeckV1
//
//  Central place for colors, spacing, and shared UI constants.
//

import SwiftUI

enum Theme {
    // Background gradient similar to the mockup
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.bgColorOne, Color.bgColorTwo],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Semi-transparent card background used across the app
    static let cardBackground: Color = Color.white.opacity(0.06)

    // Segmented pill states
    static let pillSelected: Color = Color.blue.opacity(0.9)
    static let pillUnselected: Color = Color.white.opacity(0.08)

    // Text colors
    static let primaryText: Color = .white
    static let secondaryText: Color = Color.white.opacity(0.8)
}


