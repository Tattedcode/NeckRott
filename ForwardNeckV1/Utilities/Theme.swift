//
//  Theme.swift
//  ForwardNeckV1
//
//  Central place for colors, spacing, and shared UI constants.
//

import SwiftUI

enum Theme {
    // Background gradient - Darker cream gradient ⭐ NEW
    static var backgroundGradient: LinearGradient {
        Log.info("Theme.backgroundGradient applied (darker cream gradient - NEW)")
        return LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.92, blue: 0.85),   // F2EBD9 - darker cream
                Color(red: 0.92, green: 0.88, blue: 0.80),   // EBE0CC - medium cream
                Color(red: 0.88, green: 0.84, blue: 0.75)    // E0D6BF - warm cream
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // BACKUP: Light cream gradient (comment out above and uncomment below to revert)
//        Log.info("Theme.backgroundGradient applied (light cream gradient)")
//        return LinearGradient(
//            colors: [
//                Color(red: 1.0, green: 0.988, blue: 0.961), // FFFCF5 - light cream
//                Color(red: 0.98, green: 0.96, blue: 0.94),   // FAF5F0 - slightly darker cream
//                Color(red: 0.96, green: 0.94, blue: 0.92)    // F5F0EB - warm cream
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
        
        // BACKUP: Warm cream gradient (comment out above and uncomment below to revert)
//        Log.info("Theme.backgroundGradient applied (warm cream gradient)")
//        return LinearGradient(
//            colors: [
//                Color(red: 0.992, green: 0.941, blue: 0.835), // fdf0d5 - warm cream
//                Color(red: 0.965, green: 0.890, blue: 0.765), // f6e3c3 - slightly darker cream
//                Color(red: 0.925, green: 0.820, blue: 0.675)   // ecd1ac - warm beige
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
        
        // BACKUP: Original pink gradient (comment out above and uncomment below to revert)
//        Log.info("Theme.backgroundGradient applied (pink→purple)")
//        return LinearGradient(
//            colors: [
//                Color(red: 0.578, green: 0.218, blue: 0.461), // brighter dark pink
//                Color(red: 0.441, green: 0.202, blue: 0.476), // brighter plum
//                Color(red: 0.276, green: 0.139, blue: 0.390)  // brighter dark purple
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
        
        // ALTERNATE: Light blue gradient (comment out above and uncomment below to use)
//        Log.info("Theme.backgroundGradient applied (light blue)")
//        return LinearGradient(
//            colors: [
//                Color(red: 0.4, green: 0.7, blue: 1.0),   // light sky blue
//                Color(red: 0.3, green: 0.5, blue: 0.9),   // medium blue
//                Color(red: 0.2, green: 0.4, blue: 0.8)    // deeper blue
//            ],
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
    }

    // Brightest stop from the background gradient (exposed for places that need a solid color match)
    static let gradientBrightPink: Color = Color(red: 0.478, green: 0.118, blue: 0.361)

    // Semi-transparent card background used across the app
    // Dark for readability on the light background
    static let cardBackground: Color = Color.black.opacity(0.08)

    // Segmented pill states
    static let pillSelected: Color = Color.blue.opacity(0.9)
    static let pillUnselected: Color = Color.black.opacity(0.12)

    // Text colors - black for light gradient background
    static let primaryText: Color = .black
    static let secondaryText: Color = Color.black.opacity(0.7)
}