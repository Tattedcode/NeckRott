//
//  GamificationStore.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Store for managing gamification data persistence
/// Part of D-005: XP points and level
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
            Log.info("Loaded user progress: Level \(userProgress.level), XP: \(userProgress.xp)")
            notifyProgressChange(reason: "loadUserProgress_success")
        } catch {
            Log.error("Failed to load user progress: \(error)")
            userProgress = UserProgress() // Use default values
            notifyProgressChange(reason: "loadUserProgress_default")
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
        notifyProgressChange(reason: "addXP")

        Log.info("Added \(xp) XP from \(source). Total XP: \(userProgress.xp)")
    }

    /// Unlock an achievement (XP rewards disabled during level-based unlock phase)
    func unlockAchievement(_ achievementId: UUID) -> Bool {
        Log.info("Achievement unlocking is disabled while level-based rewards are in progress (id=\(achievementId))")
        return false
    }

    /// Purchase a reward (temporarily disabled during XP-only phase)
    /// - Parameter rewardId: ID of the reward to open
    /// - Returns: Always false while XP-only mode is active
    func purchaseReward(_ rewardId: UUID) -> Bool {
        Log.info("Reward purchasing is disabled. Attempted rewardId=\(rewardId)")
        return false
    }
    
    /// Check if user should level up and handle level up
    private func checkForLevelUp() {
        while let nextLevel = levels.first(where: { $0.number == userProgress.level + 1 }),
              userProgress.xp >= nextLevel.xpRequired {
            userProgress.level = nextLevel.number
            Log.info("Level up! Now level \(userProgress.level)")
            NotificationCenter.default.post(
                name: .levelDidChange,
                object: nil,
                userInfo: ["level": userProgress.level]
            )
        }
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
        let levelConfigs: [(title: String, description: String, icon: String, color: String)] = [
            ("Neck Rookie", "Just getting started", "figure.walk", "#8E8E93"),
            ("Posture Learner", "Finding your rhythm", "lightbulb", "#60A5FA"),
            ("Stance Scout", "Tracking your habits", "scope", "#34C759"),
            ("Alignment Apprentice", "Noticing the gains", "line.diagonal", "#FF9F0A"),
            ("Strain Slayer", "Tension is easing", "bolt.heart", "#FF375F"),
            ("Habit Builder", "Consistency is coming", "calendar", "#5AC8FA"),
            ("Alignment Advocate", "Your posture inspires", "megaphone", "#FF453A"),
            ("Neck Defender", "Daily moves on lock", "shield.lefthalf.filled", "#32ADE6"),
            ("Posture Protector", "You catch the slouch", "lock.shield", "#AF52DE"),
            ("Routine Hero", "No days skipped", "medal", "#FFD60A"),
            ("Balance Keeper", "Strong and centered", "figure.core.training", "#34C759"),
            ("Form Guardian", "Precision with every rep", "waveform.path.ecg", "#FF9F0A"),
            ("Mobility Mentor", "Sharing what works", "person.2.wave.2", "#30B0C7"),
            ("Core Champion", "Neck and core synced", "circle.grid.cross", "#FF2D55"),
            ("Focus Veteran", "Locked into progress", "eye.trianglebadge.exclamationmark", "#BF5AF2"),
            ("Resilience Expert", "Bounce back instantly", "arrow.uturn.backward", "#0A84FF"),
            ("Discipline Master", "Habits are automatic", "checkmark.seal", "#32D74B"),
            ("Mindful Pro", "Every lift is intentional", "brain.head.profile", "#FFB300"),
            ("Posture Sage", "You teach through example", "sparkles", "#FFD60A"),
            ("Neck Legend", "Posture perfected", "crown.fill", "#FFD700")
        ]

        var levels: [Level] = []
        var xpRequired = 0

        for index in 0..<levelConfigs.count {
            let levelNumber = index + 1
            if levelNumber == 1 {
                xpRequired = 0
            } else {
                let increment: Int
                switch levelNumber {
                case 2...5:
                    increment = 100
                case 6...10:
                    increment = 150
                case 11...15:
                    increment = 200
                default:
                    increment = 250
                }
                xpRequired += increment
            }

            let config = levelConfigs[index]
            levels.append(
                Level(
                    id: levelNumber,
                    number: levelNumber,
                    xpRequired: xpRequired,
                    title: config.title,
                    description: config.description,
                    iconSystemName: config.icon,
                    colorHex: config.color
                )
            )
        }

        return levels
    }
    
    /// Create default achievements for the gamification system
    /// - Returns: Array of default achievements
    private func createDefaultAchievements() -> [Achievement] {
        return [
            Achievement(title: "First Check", description: "Complete your first posture check",
                       xpReward: 0, iconSystemName: "checkmark.circle.fill", colorHex: "#34C759"),
            Achievement(title: "Daily Streak", description: "Complete 7 days in a row",
                       xpReward: 0, iconSystemName: "flame.fill", colorHex: "#FF9500"),
            Achievement(title: "Exercise Enthusiast", description: "Complete 10 exercises",
                       xpReward: 0, iconSystemName: "dumbbell.fill", colorHex: "#007AFF"),
            Achievement(title: "Week Warrior", description: "Complete 50 posture checks in a week",
                       xpReward: 0, iconSystemName: "calendar.badge.clock", colorHex: "#FF2D92"),
            Achievement(title: "Posture Pro", description: "Reach level 5",
                       xpReward: 0, iconSystemName: "star.fill", colorHex: "#FFD700")
        ]
    }

    /// Create default rewards for the gamification system
    /// - Returns: Array of default rewards
    private func createDefaultRewards() -> [Reward] {
        return [
            Reward(title: "Custom Theme", description: "Unlocked at Level 3",
                   iconSystemName: "paintbrush.fill", colorHex: "#34C759"),
            Reward(title: "Advanced Tips", description: "Unlocked at Level 7",
                   iconSystemName: "lightbulb.fill", colorHex: "#FF9500"),
            Reward(title: "Exclusive Badge", description: "Unlocked at Level 12",
                   iconSystemName: "badge.plus.radiowaves.right", colorHex: "#007AFF"),
            Reward(title: "Premium Features", description: "Unlocked at Level 18",
                   iconSystemName: "crown.fill", colorHex: "#FFD700")
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
        saveUserProgress()
        saveAchievements()
        saveRewards()
        notifyProgressChange(reason: "resetAll")
        Log.info("Reset all gamification data")
    }
}

extension Notification.Name {
    static let levelDidChange = Notification.Name("GamificationStore.levelDidChange")
    static let userProgressDidChange = Notification.Name("GamificationStore.userProgressDidChange")
    static let userProgressDidChangeMainThread = Notification.Name("GamificationStore.userProgressDidChangeMainThread")
}

// MARK: - Private Helpers
private extension GamificationStore {
    /// Notify listeners that the user's progress changed so UI can refresh
    /// - Parameter reason: Helpful label for debug logs
    func notifyProgressChange(reason: String) {
        Log.info("GamificationStore progress changed due to: \(reason)")
        NotificationCenter.default.post(name: .userProgressDidChange, object: nil)
        Task { @MainActor in
            NotificationCenter.default.post(name: .userProgressDidChangeMainThread, object: nil)
        }
    }
}
