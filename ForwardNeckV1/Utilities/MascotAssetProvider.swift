//
//  MascotAssetProvider.swift
//  NeckRotV1
//
//  Helper that returns mascot names with optional female prefix based on user preference.
//

import Foundation

/// Provider that returns mascot names with optional female prefix based on user preference
enum MascotAssetProvider {
    /// Return the mascot name with female prefix if user selected female mascot
    /// - Parameter baseName: Base mascot name (e.g., "mascot1", "mascot2", etc.)
    /// - Parameter ignorePreference: If true, always return base name (used for onboarding before selection)
    /// - Returns: Resolved mascot name (e.g., "mascot1" or "femalemascot1")
    static func resolvedMascotName(for baseName: String, ignorePreference: Bool = false) -> String {
        // If ignoring preference (e.g., during onboarding), return base name as-is
        if ignorePreference {
            Log.info("MascotAssetProvider: Using mascot: \(baseName) (preference ignored)")
            return baseName
        }
        
        // Check if user selected female mascot
        let isFemale = MascotPreferenceManager.isFemaleMascotSelected
        
        // If female selected and base name starts with "mascot", add "female" prefix
        if isFemale && baseName.hasPrefix("mascot") {
            let resolvedName = "female\(baseName)"
            Log.info("MascotAssetProvider: Resolved \(baseName) -> \(resolvedName) (female selected)")
            return resolvedName
        }
        
        // Otherwise return base name as-is
        Log.info("MascotAssetProvider: Using mascot: \(baseName)")
        return baseName
    }
}

