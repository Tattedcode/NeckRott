//
//  GamificationStore.swift
//  ForwardNeckV1
//
//  Central gamification data store.
//

import Foundation

@MainActor
final class GamificationStore: ObservableObject {
    static let shared = GamificationStore()

    @Published var userProgress = UserProgress()
    @Published var levels: [Level] = []
    @Published var achievements: [Achievement] = []
    @Published var rewards: [Reward] = []

    let progressFileURL: URL
    let levelsFileURL: URL
    let achievementsFileURL: URL
    let rewardsFileURL: URL

    private init() {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        progressFileURL = supportDirectory.appendingPathComponent("user_progress.json")
        levelsFileURL = supportDirectory.appendingPathComponent("levels.json")
        achievementsFileURL = supportDirectory.appendingPathComponent("achievements.json")
        rewardsFileURL = supportDirectory.appendingPathComponent("rewards.json")

        loadAllData()
    }

    func addXP(_ xp: Int, source: String) {
        userProgress.xp += xp
        userProgress.totalXpEarned += xp
        userProgress.lastUpdated = Date()
        checkForLevelUp()
        saveUserProgress()
        notifyProgressChange(reason: "addXP")
        Log.info("Added \(xp) XP from \(source). Total XP: \(userProgress.xp)")
    }

    func unlockAchievement(_ achievementId: UUID) -> Bool {
        Log.info("Achievement unlocking is disabled while level-based rewards are in progress (id=\(achievementId))")
        return false
    }

    func purchaseReward(_ rewardId: UUID) -> Bool {
        Log.info("Reward purchasing is disabled. Attempted rewardId=\(rewardId)")
        return false
    }

    func getCurrentLevel() -> Level? {
        levels.first { $0.number == userProgress.level }
    }

    func getNextLevel() -> Level? {
        levels.first { $0.number == userProgress.level + 1 }
    }

    func getProgressToNextLevel() -> Double {
        guard let nextLevel = getNextLevel() else { return 1.0 }
        let currentLevelXP = getCurrentLevel()?.xpRequired ?? 0
        let xpInCurrentLevel = userProgress.xp - currentLevelXP
        let xpNeededForNextLevel = nextLevel.xpRequired - currentLevelXP
        return min(1.0, Double(xpInCurrentLevel) / Double(xpNeededForNextLevel))
    }

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
}
