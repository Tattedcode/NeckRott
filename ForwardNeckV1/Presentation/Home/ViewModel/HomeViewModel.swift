//
//  HomeViewModel.swift
//  ForwardNeckV1
//
//  ViewModel for the Dashboard screen. Holds observable state for Overview & Exercises tabs.
//

import Foundation
import SwiftUI

/// Model for an exercise item in the list
struct ExerciseItem: Identifiable {
    let id: UUID = UUID()
    let title: String
    let iconSystemName: String
    let durationMinutes: Int

    var durationLabel: String { "\(durationMinutes) min" }
}

/// Observable ViewModel following MVVM
@MainActor
final class HomeViewModel: ObservableObject {
    // Daily reminders summary for the progress card
    @Published var completedRemindersToday: Int = 0
    @Published var dailyReminderTarget: Int = 5
    
    /// Capped completed count to prevent UI stretching beyond daily target
    var cappedCompletedToday: Int {
        return min(completedRemindersToday, dailyReminderTarget)
    }

    // Weekly stats used by metric cards
    @Published var weeklyPostureCheckins: Int = 0
    @Published var weeklyExercisesDone: Int = 0
    @Published var longestStreakDays: Int = 0
    
    // Current streak for animated display
    @Published var currentStreakDays: Int = 0

    // Exercises for the Exercises tab
    @Published var exercises: [ExerciseItem] = []
    
    // Next exercise for the home screen
    @Published var nextExercise: Exercise?
    
    // Exercise completions for calendar view
    @Published var exerciseCompletions: [Date] = []

    // Store dependencies
    private let checkInStore: CheckInStore = CheckInStore.shared
    private let exerciseStore: ExerciseStore = ExerciseStore.shared
    private let streakStore: StreakStore = StreakStore.shared
    private let gamificationStore: GamificationStore = GamificationStore.shared
    private let goalsStore: GoalsStore = GoalsStore.shared

    // Loads initial data. In future, connect to persistence (e.g., Supabase/local store)
    @MainActor
    func loadDashboard() async {
        // Debug: simulate loading & log values
        print("[HomeViewModel] loadDashboard() called")

        // Load from stores and compute metrics
        let allCheckIns = checkInStore.all()
        let calendar = Calendar.current
        let now = Date()

        // Today count
        completedRemindersToday = allCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }.count

        // Weekly check-ins (this week starting Monday)
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) {
            weeklyPostureCheckins = allCheckIns.filter { $0.timestamp >= weekInterval.start && $0.timestamp < weekInterval.end }.count
        }

        // Daily target equals enabled reminders count
        dailyReminderTarget = ReminderStore.shared.all().filter { $0.enabled }.count

        // Weekly exercises completed
        let weeklyCompletions = exerciseStore.weeklyCompletions()
        weeklyExercisesDone = weeklyCompletions.count

        // Load current and longest streak data
        currentStreakDays = streakStore.currentStreak(for: .postureChecks)
        longestStreakDays = streakStore.longestStreak(for: .postureChecks)

        // Load exercises for the Exercises tab
        let allExercises = exerciseStore.allExercises()
        exercises = allExercises.map { exercise in
            ExerciseItem(
                title: exercise.title,
                iconSystemName: exercise.iconSystemName,
                durationMinutes: exercise.durationSeconds / 60
            )
        }
        
        // Set next exercise (randomly select one for now)
        nextExercise = allExercises.randomElement()
        
        // Load exercise completions for calendar view
        exerciseCompletions = exerciseStore.allCompletions().map { $0.completedAt }
    }

    /// Records a posture check-in and refreshes metrics
    /// Also updates streak data and gamification rewards
    /// Part of F-004: Streaks & Progress and F-005: Gamification
    func recordCheckIn() {
        Task { @MainActor in
            await checkInStore.addNow()
            
            // Update streaks with latest data
            await updateStreaks()
            
            // Add gamification rewards for posture check-in
            gamificationStore.addXP(10, source: "Posture Check-in")
            gamificationStore.addCoins(5, source: "Posture Check-in")
            
            // Check for achievements
            await checkAchievements()
            
            // Update custom goals progress
            goalsStore.updateAllGoalProgress()
            
            await loadDashboard()
        }
    }
    
    /// Update streak data based on current check-ins and exercise completions
    /// Part of F-004: Streaks & Progress feature
    private func updateStreaks() async {
        let allCheckIns = await checkInStore.all()
        let allExercises = await exerciseStore.completions
        
        let checkInDates = allCheckIns.map { $0.timestamp }
        let exerciseDates = allExercises.map { $0.completedAt }
        
        streakStore.updateDailyStreaks(checkIns: checkInDates, exerciseCompletions: exerciseDates)
        
        // Update current streak for UI
        currentStreakDays = streakStore.currentStreak(for: .postureChecks)
        longestStreakDays = streakStore.longestStreak(for: .postureChecks)
    }
    
    /// Check and unlock achievements based on current progress
    /// Part of F-005: Gamification feature
    private func checkAchievements() async {
        let allCheckIns = await checkInStore.all()
        let allExercises = await exerciseStore.completions
        
        // Check "First Check" achievement
        if allCheckIns.count >= 1 {
            let firstCheckAchievement = gamificationStore.achievements.first { $0.title == "First Check" }
            if let achievement = firstCheckAchievement, !achievement.isUnlocked {
                gamificationStore.unlockAchievement(achievement.id)
            }
        }
        
        // Check "Exercise Enthusiast" achievement
        if allExercises.count >= 10 {
            let exerciseAchievement = gamificationStore.achievements.first { $0.title == "Exercise Enthusiast" }
            if let achievement = exerciseAchievement, !achievement.isUnlocked {
                gamificationStore.unlockAchievement(achievement.id)
            }
        }
        
        // Check "Week Warrior" achievement (50 checks in a week)
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let weeklyChecks = allCheckIns.filter { $0.timestamp >= weekAgo }.count
        if weeklyChecks >= 50 {
            let weekWarriorAchievement = gamificationStore.achievements.first { $0.title == "Week Warrior" }
            if let achievement = weekWarriorAchievement, !achievement.isUnlocked {
                gamificationStore.unlockAchievement(achievement.id)
            }
        }
        
        // Check "Daily Streak" achievement (7 days in a row)
        let currentStreak = streakStore.currentStreak(for: .postureChecks)
        if currentStreak >= 7 {
            let streakAchievement = gamificationStore.achievements.first { $0.title == "Daily Streak" }
            if let achievement = streakAchievement, !achievement.isUnlocked {
                gamificationStore.unlockAchievement(achievement.id)
            }
        }
        
        // Check "Posture Pro" achievement (level 5)
        if gamificationStore.userProgress.level >= 5 {
            let proAchievement = gamificationStore.achievements.first { $0.title == "Posture Pro" }
            if let achievement = proAchievement, !achievement.isUnlocked {
                gamificationStore.unlockAchievement(achievement.id)
            }
        }
    }
    
    /// Reset all data including streaks, check-ins, exercises, and goals
    /// Useful for testing and fresh start
    func resetAllData() {
        Task { @MainActor in
            // Reset check-ins
            await checkInStore.resetAll()
            
            // Reset exercises
            await exerciseStore.resetAll()
            
            // Reset streaks
            streakStore.resetAll()
            
            // Reset gamification data
            gamificationStore.resetAll()
            
            // Reset goals
            goalsStore.resetAll()
            
            // Reload dashboard to reflect changes
            await loadDashboard()
            
            Log.info("All data has been reset")
        }
    }
    
    /// Start the next exercise
    func startNextExercise() {
        // This would typically start a timer or navigate to exercise detail
        Log.info("Starting next exercise: \(nextExercise?.title ?? "None")")
    }
    
    /// Complete the current exercise
    func completeNextExercise() {
        guard let exercise = nextExercise else { return }
        
        Task { @MainActor in
            // Record the exercise completion
            await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: exercise.durationSeconds)
            
            // Update streaks
            await updateStreaks()
            
            // Check for achievements
            await checkAchievements()
            
            // Reload dashboard to reflect changes
            await loadDashboard()
            
            Log.info("Completed exercise: \(exercise.title)")
        }
    }
}


// Another test
