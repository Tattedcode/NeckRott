//
//  LevelUpManager.swift
//  ForwardNeckV1
//
//  Manages level up celebrations and sheet presentation
//

import SwiftUI
import Foundation

@MainActor
final class LevelUpManager: ObservableObject {
    static let shared = LevelUpManager()
    
    @Published var showLevelUpSheet = false
    @Published var currentLevelUp: Level?
    
    private var previousLevel = 1
    private let gamificationStore = GamificationStore.shared
    
    private init() {
        // Listen for level changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLevelChange),
            name: .levelDidChange,
            object: nil
        )
        
        // Initialize with current level
        previousLevel = gamificationStore.userProgress.level
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleLevelChange(_ notification: Notification) {
        guard let levelNumber = notification.userInfo?["level"] as? Int else { return }
        
        // Check if this is actually a level up (not just initialization)
        if levelNumber > previousLevel {
            Log.info("LevelUpManager: Detected level up from \(previousLevel) to \(levelNumber)")
            
            // Get the new level details
            if let newLevel = gamificationStore.getCurrentLevel() {
                currentLevelUp = newLevel
                showLevelUpSheet = true
                
                // Add celebration haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                
                Log.info("LevelUpManager: Showing level up sheet for level \(newLevel.number) - \(newLevel.title)")
            }
        }
        
        // Update previous level
        previousLevel = levelNumber
    }
    
    func dismissLevelUpSheet() {
        showLevelUpSheet = false
        currentLevelUp = nil
    }
    
    /// Manually trigger a level up for testing purposes
    func triggerTestLevelUp() {
        guard let testLevel = gamificationStore.getCurrentLevel() else { return }
        
        currentLevelUp = testLevel
        showLevelUpSheet = true
        
        Log.info("LevelUpManager: Triggered test level up for level \(testLevel.number)")
    }
}
