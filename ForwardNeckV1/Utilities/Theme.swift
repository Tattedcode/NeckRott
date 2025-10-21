//
//  Theme.swift
//  ForwardNeckV1
//
//  Central place for colors, spacing, and shared UI constants.
//

import SwiftUI

enum Theme {
    // Background gradient - deep blue gradient (219ebc → 023047) ⭐ RECOMMENDED
    static var backgroundGradient: LinearGradient {
        Log.info("Theme.backgroundGradient applied (deep blue gradient - RECOMMENDED)")
        return LinearGradient(
            colors: [
                Color(red: 0.129, green: 0.620, blue: 0.737), // 219ebc - medium blue
                Color(red: 0.008, green: 0.188, blue: 0.278)  // 023047 - dark blue
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
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
    // Light for readability on the dark background
    static let cardBackground: Color = Color.white.opacity(0.12)

    // Segmented pill states
    static let pillSelected: Color = Color.blue.opacity(0.9)
    static let pillUnselected: Color = Color.white.opacity(0.16)

    // Text colors - white for dark gradient background
    static let primaryText: Color = .white
    static let secondaryText: Color = Color.white.opacity(0.8)
}