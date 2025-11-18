//
//  MascotPreferenceManager.swift
//  NeckRotV1
//
//  Manages user's mascot preference (male/female)
//

import Foundation

/// Manages the user's mascot preference
enum MascotPreferenceManager {
    // MARK: - UserDefaults Keys
    
    private static let selectedMascotTypeKey = "user.selectedMascotType"
    
    // MARK: - Mascot Type
    
    enum MascotType: String {
        case male = "male"
        case female = "female"
    }
    
    // MARK: - Preference Management
    
    /// Get the current mascot type preference (defaults to male)
    static var selectedMascotType: MascotType {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: selectedMascotTypeKey),
               let type = MascotType(rawValue: rawValue) {
                return type
            }
            return .male // Default to male mascot
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedMascotTypeKey)
            Log.info("MascotPreferenceManager: Saved mascot type preference: \(newValue.rawValue)")
        }
    }
    
    /// Check if user has selected female mascot
    static var isFemaleMascotSelected: Bool {
        return selectedMascotType == .female
    }
}

