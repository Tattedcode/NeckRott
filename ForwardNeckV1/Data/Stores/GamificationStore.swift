//
//  GamificationStore.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Store for managing gamification data persistence
/// Part of D-005: XP points, coins, and level
/// Implements MVVM pattern for data management
@MainActor
final class GamificationStore: ObservableObject {
    /// Shared instance for singleton pattern
    static let shared = GamificationStore()
    
    /// Published properties for gamification data - triggers UI updates when changed
    @Published private(set) var userProgress: UserProgress = UserProgress()
    @Published private(set) var levels: [Level] = []
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var rewards: [Reward] = []
    
    /// File URLs for persisting gamification data
    private let progressFileURL: URL
    private let levelsFileURL: URL
    private let achievementsFileURL: URL
    private let rewardsFileURL: URL
    
    /// Initialize the gamification store
    /// Sets up file URLs and loads existing data
    private init() {
        // Create file URLs in Application Support directory
        let documentsPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.progressFileURL = documentsPath.appendingPathComponent("user_progress.json")
        self.levelsFileURL = documentsPath.appendingPathComponent("levels.json")
        self.achievementsFileURL = documentsPath.appendingPathComponent("achievements.json")
        self.rewardsFileURL = documentsPath.appendingPathComponent("rewards.json")
        
        // Load existing data on initialization
        loadAllData()
    }
    
    /// Load all gamification data from disk
    /// Called during initialization and when data needs to be refreshed
    private func loadAllData() {
        loadUserProgress()
        loadLevels()
        loadAchievements()
        loadRewards()
    }
    
    /// Load user progress from disk
    private func loadUserProgress() {
        do {
            let data = try Data(contentsOf: progressFileURL)
            userProgress = try JSONDecoder().decode(UserProgress.self, from: data)
            Log.info("Loaded user progress: Level \(userProgress.level), XP: \(userProgress.xp), Coins: \(userProgress.coins)")
        } catch {
            Log.error("Failed to load user progress: \(error)")
            userProgress = UserProgress() // Use default values
        }
    }
    
    /// Load levels from disk
    private func loadLevels() {
        do {
            let data = try Data(contentsOf: levelsFileURL)
            levels = try JSONDecoder().decode([Level].self, from: data)
            Log.info("Loaded \(levels.count) levels")
        } catch {
            Log.error("Failed to load levels: \(error)")
            levels = createDefaultLevels() // Create default levels
            saveLevels()
        }
    }
    
    /// Load achievements from disk
    private func loadAchievements() {
        do {
            let data = try Data(contentsOf: achievementsFileURL)
            achievements = try JSONDecoder().decode([Achievement].self, from: data)
            Log.info("Loaded \(achievements.count) achievements")
        } catch {
            Log.error("Failed to load achievements: \(error)")
            achievements = createDefaultAchievements() // Create default achievements
            saveAchievements()
        }
    }
    
    /// Load rewards from disk
    private func loadRewards() {
        do {
            let data = try Data(contentsOf: rewardsFileURL)
            rewards = try JSONDecoder().decode([Reward].self, from: data)
            Log.info("Loaded \(rewards.count) rewards")
        } catch {
            Log.error("Failed to load rewards: \(error)")
            rewards = createDefaultRewards() // Create default rewards
            saveRewards()
        }
    }
    
    /// Add XP to user progress and check for level up
    /// - Parameters:
    ///   - xp: Amount of XP to add
    ///   - source: Source of the XP (for logging)
    func addXP(_ xp: Int, source: String) {
        userProgress.xp += xp
        userProgress.totalXpEarned += xp
        userProgress.lastUpdated = Date()
        
        // Check for level up
        checkForLevelUp()
        
        // Save progress
        saveUserProgress()
        
        Log.info("Added \(xp) XP from \(source). Total XP: \(userProgress.xp)")
    }
    
    /// Add coins to user progress
    /// - Parameters:
    ///   - coins: Amount of coins to add
    ///   - source: Source of the coins (for logging)
    func addCoins(_ coins: Int, source: String) {
        userProgress.coins += coins
        userProgress.totalCoinsEarned += coins
        userProgress.lastUpdated = Date()
        
        // Save progress
        saveUserProgress()
        
        Log.info("Added \(coins) coins from \(source). Total coins: \(userProgress.coins)")
    }
    
    /// Spend coins (for purchasing rewards)
    /// - Parameters:
    ///   - coins: Amount of coins to spend
    ///   - source: What the coins are being spent on
    /// - Returns: True if successful, false if insufficient coins
    func spendCoins(_ coins: Int, source: String) -> Bool {
        guard userProgress.coins >= coins else {
            Log.error("Insufficient coins to spend \(coins) on \(source)")
            return false
        }
        
        userProgress.coins -= coins
        userProgress.lastUpdated = Date()
        
        // Save progress
        saveUserProgress()
        
        Log.info("Spent \(coins) coins on \(source). Remaining coins: \(userProgress.coins)")
        return true
    }
    
    /// Check if user should level up and handle level up
    private func checkForLevelUp() {
        let currentLevel = userProgress.level
        let nextLevel = levels.first { $0.number == currentLevel + 1 }
        
        if let nextLevel = nextLevel, userProgress.xp >= nextLevel.xpRequired {
            // Level up!
            userProgress.level = nextLevel.number
            
            // Add coins reward for leveling up
            addCoins(nextLevel.coinsReward, source: "Level \(nextLevel.number) up")
            
            Log.info("Level up! Now level \(userProgress.level)")
            
            // Check for more level ups
            checkForLevelUp()
        }
    }
    
    /// Unlock an achievement
    /// - Parameter achievementId: ID of the achievement to unlock
    /// - Returns: True if successful, false if already unlocked
    func unlockAchievement(_ achievementId: UUID) -> Bool {
        guard let index = achievements.firstIndex(where: { $0.id == achievementId }) else {
            Log.error("Achievement with ID \(achievementId) not found")
            return false
        }
        
        guard !achievements[index].isUnlocked else {
            Log.info("Achievement \(achievements[index].title) already unlocked")
            return false
        }
        
        // Unlock the achievement
        achievements[index].isUnlocked = true
        achievements[index].unlockedAt = Date()
        
        // Add rewards
        addXP(achievements[index].xpReward, source: "Achievement: \(achievements[index].title)")
        addCoins(achievements[index].coinsReward, source: "Achievement: \(achievements[index].title)")
        
        // Save achievements
        saveAchievements()
        
        Log.info("Unlocked achievement: \(achievements[index].title)")
        return true
    }
    
    /// Purchase a reward
    /// - Parameter rewardId: ID of the reward to purchase
    /// - Returns: True if successful, false if insufficient coins or already purchased
    func purchaseReward(_ rewardId: UUID) -> Bool {
        guard let index = rewards.firstIndex(where: { $0.id == rewardId }) else {
            Log.error("Reward with ID \(rewardId) not found")
            return false
        }
        
        guard !rewards[index].isPurchased else {
            Log.info("Reward \(rewards[index].title) already purchased")
            return false
        }
        
        guard spendCoins(rewards[index].coinsCost, source: "Reward: \(rewards[index].title)") else {
            return false
        }
        
        // Mark as purchased
        rewards[index].isPurchased = true
        rewards[index].purchasedAt = Date()
        
        // Save rewards
        saveRewards()
        
        Log.info("Purchased reward: \(rewards[index].title)")
        return true
    }
    
    /// Get current level information
    /// - Returns: Current level object
    func getCurrentLevel() -> Level? {
        return levels.first { $0.number == userProgress.level }
    }
    
    /// Get next level information
    /// - Returns: Next level object, or nil if at max level
    func getNextLevel() -> Level? {
        return levels.first { $0.number == userProgress.level + 1 }
    }
    
    /// Get progress towards next level (0.0 to 1.0)
    /// - Returns: Progress as a decimal between 0 and 1
    func getProgressToNextLevel() -> Double {
        guard let nextLevel = getNextLevel() else { return 1.0 } // At max level
        
        let currentLevel = getCurrentLevel()
        let currentLevelXP = currentLevel?.xpRequired ?? 0
        let xpInCurrentLevel = userProgress.xp - currentLevelXP
        let xpNeededForNextLevel = nextLevel.xpRequired - currentLevelXP
        
        return min(1.0, Double(xpInCurrentLevel) / Double(xpNeededForNextLevel))
    }
    
    /// Create default levels for the gamification system
    /// - Returns: Array of default levels
    private func createDefaultLevels() -> [Level] {
        return [
            Level(id: 1, number: 1, xpRequired: 0, coinsReward: 0, title: "Beginner", 
                  description: "Starting your posture journey", iconSystemName: "person.fill", colorHex: "#8E8E93"),
            Level(id: 2, number: 2, xpRequired: 100, coinsReward: 10, title: "Aware", 
                  description: "You're becoming aware of your posture", iconSystemName: "eye.fill", colorHex: "#34C759"),
            Level(id: 3, number: 3, xpRequired: 250, coinsReward: 25, title: "Focused", 
                  description: "You're focused on improving", iconSystemName: "target", colorHex: "#007AFF"),
            Level(id: 4, number: 4, xpRequired: 500, coinsReward: 50, title: "Dedicated", 
                  description: "You're dedicated to good posture", iconSystemName: "heart.fill", colorHex: "#FF2D92"),
            Level(id: 5, number: 5, xpRequired: 1000, coinsReward: 100, title: "Expert", 
                  description: "You're a posture expert", iconSystemName: "star.fill", colorHex: "#FF9500"),
            Level(id: 6, number: 6, xpRequired: 2000, coinsReward: 200, title: "Master", 
                  description: "You've mastered good posture", iconSystemName: "crown.fill", colorHex: "#FFD700"),
            Level(id: 7, number: 7, xpRequired: 5000, coinsReward: 500, title: "Legend", 
                  description: "You're a posture legend", iconSystemName: "sparkles", colorHex: "#AF52DE")
        ]
    }
    
    /// Create default achievements for the gamification system
    /// - Returns: Array of default achievements
    private func createDefaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Check", description: "Complete your first posture check", 
                       xpReward: 10, coinsReward: 5, iconSystemName: "checkmark.circle.fill", colorHex: "#34C759"),
            Achievement(title: "Daily Streak", description: "Complete 7 days in a row", 
                       xpReward: 50, coinsReward: 25, iconSystemName: "flame.fill", colorHex: "#FF9500"),
            Achievement(title: "Exercise Enthusiast", description: "Complete 10 exercises", 
                       xpReward: 30, coinsReward: 15, iconSystemName: "dumbbell.fill", colorHex: "#007AFF"),
            Achievement(title: "Week Warrior", description: "Complete 50 posture checks in a week", 
                       xpReward: 100, coinsReward: 50, iconSystemName: "calendar.badge.clock", colorHex: "#FF2D92"),
            Achievement(title: "Posture Pro", description: "Reach level 5", 
                       xpReward: 200, coinsReward: 100, iconSystemName: "star.fill", colorHex: "#FFD700")
        ]
    }
    
    /// Create default rewards for the gamification system
    /// - Returns: Array of default rewards
    private func createDefaultRewards() -> [Reward] {
        return [
            Reward(title: "Custom Theme", description: "Unlock a new app theme", 
                   coinsCost: 50, iconSystemName: "paintbrush.fill", colorHex: "#34C759"),
            Reward(title: "Advanced Tips", description: "Unlock advanced posture tips", 
                   coinsCost: 100, iconSystemName: "lightbulb.fill", colorHex: "#FF9500"),
            Reward(title: "Exclusive Badge", description: "Get an exclusive achievement badge", 
                   coinsCost: 200, iconSystemName: "badge.plus.radiowaves.right", colorHex: "#007AFF"),
            Reward(title: "Premium Features", description: "Unlock premium app features", 
                   coinsCost: 500, iconSystemName: "crown.fill", colorHex: "#FFD700")
        ]
    }
    
    /// Save user progress to disk
    private func saveUserProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            try data.write(to: progressFileURL)
            Log.info("Saved user progress")
        } catch {
            Log.error("Failed to save user progress: \(error)")
        }
    }
    
    /// Save levels to disk
    private func saveLevels() {
        do {
            let data = try JSONEncoder().encode(levels)
            try data.write(to: levelsFileURL)
            Log.info("Saved levels")
        } catch {
            Log.error("Failed to save levels: \(error)")
        }
    }
    
    /// Save achievements to disk
    private func saveAchievements() {
        do {
            let data = try JSONEncoder().encode(achievements)
            try data.write(to: achievementsFileURL)
            Log.info("Saved achievements")
        } catch {
            Log.error("Failed to save achievements: \(error)")
        }
    }
    
    /// Save rewards to disk
    private func saveRewards() {
        do {
            let data = try JSONEncoder().encode(rewards)
            try data.write(to: rewardsFileURL)
            Log.info("Saved rewards")
        } catch {
            Log.error("Failed to save rewards: \(error)")
        }
    }
    
    /// Reset all gamification data
    /// Useful for testing and fresh start
    func resetAll() {
        userProgress = UserProgress()
        achievements = createDefaultAchievements()
        rewards = createDefaultRewards()
        // Keep levels as they are static
        
        saveUserProgress()
        saveAchievements()
        saveRewards()
        
        Log.info("Reset all gamification data")
    }
}
