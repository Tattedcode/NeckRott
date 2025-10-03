//
//  GamificationStore+Persistence.swift
//  ForwardNeckV1
//
//  Disk IO helpers and default data factories.
//

import Foundation

extension GamificationStore {
    func loadAllData() {
        loadUserProgress()
        loadLevels()
        loadAchievements()
        loadRewards()
    }

    func loadUserProgress() {
        do {
            let data = try Data(contentsOf: progressFileURL)
            userProgress = try JSONDecoder().decode(UserProgress.self, from: data)
            Log.info("Loaded user progress: Level \(userProgress.level), XP: \(userProgress.xp)")
            notifyProgressChange(reason: "loadUserProgress_success")
        } catch {
            Log.error("Failed to load user progress: \(error)")
            userProgress = UserProgress()
            notifyProgressChange(reason: "loadUserProgress_default")
        }
    }

    func loadLevels() {
        do {
            let data = try Data(contentsOf: levelsFileURL)
            levels = try JSONDecoder().decode([Level].self, from: data)
            Log.info("Loaded \(levels.count) levels")
        } catch {
            Log.error("Failed to load levels: \(error)")
            levels = createDefaultLevels()
            saveLevels()
        }
    }

    func loadAchievements() {
        do {
            let data = try Data(contentsOf: achievementsFileURL)
            achievements = try JSONDecoder().decode([Achievement].self, from: data)
            Log.info("Loaded \(achievements.count) achievements")
        } catch {
            Log.error("Failed to load achievements: \(error)")
            achievements = createDefaultAchievements()
            saveAchievements()
        }
    }

    func loadRewards() {
        do {
            let data = try Data(contentsOf: rewardsFileURL)
            rewards = try JSONDecoder().decode([Reward].self, from: data)
            Log.info("Loaded \(rewards.count) rewards")
        } catch {
            Log.error("Failed to load rewards: \(error)")
            rewards = createDefaultRewards()
            saveRewards()
        }
    }

    func saveUserProgress() {
        do {
            let data = try JSONEncoder().encode(userProgress)
            try data.write(to: progressFileURL)
            Log.info("Saved user progress")
        } catch {
            Log.error("Failed to save user progress: \(error)")
        }
    }

    func saveLevels() {
        do {
            let data = try JSONEncoder().encode(levels)
            try data.write(to: levelsFileURL)
            Log.info("Saved levels")
        } catch {
            Log.error("Failed to save levels: \(error)")
        }
    }

    func saveAchievements() {
        do {
            let data = try JSONEncoder().encode(achievements)
            try data.write(to: achievementsFileURL)
            Log.info("Saved achievements")
        } catch {
            Log.error("Failed to save achievements: \(error)")
        }
    }

    func saveRewards() {
        do {
            let data = try JSONEncoder().encode(rewards)
            try data.write(to: rewardsFileURL)
            Log.info("Saved rewards")
        } catch {
            Log.error("Failed to save rewards: \(error)")
        }
    }

    func createDefaultLevels() -> [Level] {
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

    func createDefaultAchievements() -> [Achievement] {
        [
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

    func createDefaultRewards() -> [Reward] {
        [
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
}
