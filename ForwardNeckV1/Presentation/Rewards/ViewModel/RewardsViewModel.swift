//
//  RewardsViewModel.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// ViewModel for the Rewards screen
/// Part of S-006: Rewards/Levels Screen
@MainActor
final class RewardsViewModel: ObservableObject {
    /// Store dependencies for gamification data
    private let gamificationStore: GamificationStore = GamificationStore.shared
    
    /// Published properties for UI updates
    @Published var userProgress: UserProgress = UserProgress()
    @Published var levels: [Level] = []
    @Published var achievements: [Achievement] = []
    @Published var rewards: [Reward] = []
    
    /// Computed properties for easy access
    var currentLevel: Level? {
        return gamificationStore.getCurrentLevel()
    }
    
    var nextLevel: Level? {
        return gamificationStore.getNextLevel()
    }
    
    var progressToNextLevel: Double {
        return gamificationStore.getProgressToNextLevel()
    }
    
    /// Load all gamification data
    /// Part of F-005: Gamification feature
    func loadData() {
        userProgress = gamificationStore.userProgress
        levels = gamificationStore.levels
        achievements = gamificationStore.achievements
        rewards = gamificationStore.rewards
        
        Log.info("Loaded gamification data: Level \(userProgress.level), XP: \(userProgress.xp), Coins: \(userProgress.coins)")
    }

    /// Start listening for changes from the store so UI stays fresh
    func startObserving() {
        NotificationCenter.default.addObserver(
            forName: .userProgressDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                Log.info("RewardsViewModel received userProgressDidChange notification")
                self.loadData()
            }
        }

        NotificationCenter.default.addObserver(
            forName: .userProgressDidChangeMainThread,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                Log.info("RewardsViewModel received userProgressDidChangeMainThread notification")
                self.loadData()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Purchase a reward
    /// - Parameter rewardId: ID of the reward to purchase
    /// - Returns: True if successful, false if insufficient coins or already purchased
    func purchaseReward(_ rewardId: UUID) -> Bool {
        let success = gamificationStore.purchaseReward(rewardId)
        
        if success {
            // Refresh data after successful purchase
            loadData()
            Log.info("Successfully purchased reward")
        } else {
            Log.error("Failed to purchase reward")
        }
        
        return success
    }
    
    /// Unlock an achievement
    /// - Parameter achievementId: ID of the achievement to unlock
    /// - Returns: True if successful, false if already unlocked
    func unlockAchievement(_ achievementId: UUID) -> Bool {
        let success = gamificationStore.unlockAchievement(achievementId)
        
        if success {
            // Refresh data after successful unlock
            loadData()
            Log.info("Successfully unlocked achievement")
        } else {
            Log.error("Failed to unlock achievement")
        }
        
        return success
    }
    
    /// Add XP (called from other parts of the app)
    /// - Parameters:
    ///   - xp: Amount of XP to add
    ///   - source: Source of the XP
    func addXP(_ xp: Int, source: String) {
        gamificationStore.addXP(xp, source: source)
        loadData() // Refresh UI
    }
    
    /// Add coins (called from other parts of the app)
    /// - Parameters:
    ///   - coins: Amount of coins to add
    ///   - source: Source of the coins
    func addCoins(_ coins: Int, source: String) {
        gamificationStore.addCoins(coins, source: source)
        loadData() // Refresh UI
    }
}
