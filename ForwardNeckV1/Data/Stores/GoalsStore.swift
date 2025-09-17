//
//  GoalsStore.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Store for managing custom goals data persistence
/// Part of D-006: Custom goals set by user
/// Implements MVVM pattern for data management
@MainActor
final class GoalsStore: ObservableObject {
    /// Shared instance for singleton pattern
    static let shared = GoalsStore()
    
    /// Published properties for goals data - triggers UI updates when changed
    @Published private(set) var goals: [CustomGoal] = []
    
    /// File URL for persisting goals data
    private let fileURL: URL
    
    /// Initialize the goals store
    /// Sets up file URL and loads existing data
    private init() {
        // Create file URL in Application Support directory
        let documentsPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.fileURL = documentsPath.appendingPathComponent("custom_goals.json")
        
        // Load existing data on initialization
        loadGoals()
    }
    
    /// Load goals from disk
    /// Called during initialization and when data needs to be refreshed
    private func loadGoals() {
        do {
            let data = try Data(contentsOf: fileURL)
            goals = try JSONDecoder().decode([CustomGoal].self, from: data)
            Log.info("Loaded \(goals.count) custom goals")
        } catch {
            Log.error("Failed to load goals: \(error)")
            // Create default goals if none exist
            goals = DefaultGoals.create()
            saveGoals()
            Log.info("Created default goals for new user")
        }
    }
    
    /// Save goals to disk
    /// Called whenever goals data is modified
    private func saveGoals() {
        do {
            let data = try JSONEncoder().encode(goals)
            try data.write(to: fileURL)
            Log.info("Saved \(goals.count) custom goals")
        } catch {
            Log.error("Failed to save goals: \(error)")
        }
    }
    
    /// Add a new custom goal
    /// - Parameter goal: The goal to add
    func addGoal(_ goal: CustomGoal) {
        goals.append(goal)
        saveGoals()
        Log.info("Added new goal: \(goal.title)")
    }
    
    /// Update an existing goal
    /// - Parameter goal: The updated goal
    func updateGoal(_ goal: CustomGoal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
            Log.info("Updated goal: \(goal.title)")
        } else {
            Log.error("Goal with ID \(goal.id) not found for update")
        }
    }
    
    /// Delete a goal
    /// - Parameter goalId: ID of the goal to delete
    func deleteGoal(_ goalId: UUID) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            let goalTitle = goals[index].title
            goals.remove(at: index)
            saveGoals()
            Log.info("Deleted goal: \(goalTitle)")
        } else {
            Log.error("Goal with ID \(goalId) not found for deletion")
        }
    }
    
    /// Toggle goal active status
    /// - Parameter goalId: ID of the goal to toggle
    func toggleGoalActive(_ goalId: UUID) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].isActive.toggle()
            goals[index].updatedAt = Date()
            saveGoals()
            Log.info("Toggled goal active status: \(goals[index].title)")
        } else {
            Log.error("Goal with ID \(goalId) not found for toggle")
        }
    }
    
    /// Update progress for a specific goal
    /// - Parameters:
    ///   - goalId: ID of the goal to update
    ///   - progress: New progress value
    func updateGoalProgress(_ goalId: UUID, progress: Int) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentProgress = max(0, progress) // Ensure progress is not negative
            goals[index].updatedAt = Date()
            saveGoals()
            Log.info("Updated progress for goal \(goals[index].title): \(progress)/\(goals[index].targetValue)")
        } else {
            Log.error("Goal with ID \(goalId) not found for progress update")
        }
    }
    
    /// Get active goals
    /// - Returns: Array of active goals
    func getActiveGoals() -> [CustomGoal] {
        return goals.filter { $0.isActive }
    }
    
    /// Get goals by type
    /// - Parameter type: Type of goals to retrieve
    /// - Returns: Array of goals of the specified type
    func getGoalsByType(_ type: GoalType) -> [CustomGoal] {
        return goals.filter { $0.type == type }
    }
    
    /// Get goals by time period
    /// - Parameter timePeriod: Time period of goals to retrieve
    /// - Returns: Array of goals with the specified time period
    func getGoalsByTimePeriod(_ timePeriod: GoalTimePeriod) -> [CustomGoal] {
        return goals.filter { $0.timePeriod == timePeriod }
    }
    
    /// Reset progress for all goals of a specific time period
    /// Called when a time period resets (e.g., daily goals reset at midnight)
    /// - Parameter timePeriod: Time period to reset
    func resetProgressForTimePeriod(_ timePeriod: GoalTimePeriod) {
        for index in goals.indices {
            if goals[index].timePeriod == timePeriod {
                goals[index].currentProgress = 0
                goals[index].updatedAt = Date()
            }
        }
        saveGoals()
        Log.info("Reset progress for \(timePeriod.rawValue) goals")
    }
    
    /// Calculate progress for a specific goal based on current data
    /// - Parameter goal: The goal to calculate progress for
    /// - Returns: Current progress value
    func calculateProgressForGoal(_ goal: CustomGoal) -> Int {
        let checkInStore = CheckInStore.shared
        let exerciseStore = ExerciseStore.shared
        let streakStore = StreakStore.shared
        
        let calendar = Calendar.current
        let now = Date()
        
        switch goal.type {
        case .dailyPostureChecks:
            let allCheckIns = checkInStore.all()
            let todaysCheckIns = allCheckIns.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
            return todaysCheckIns.count
            
        case .dailyExercises:
            let allExercises = exerciseStore.completions
            let todaysExercises = allExercises.filter { calendar.isDate($0.completedAt, inSameDayAs: now) }
            return todaysExercises.count
            
        case .weeklyPostureChecks:
            let allCheckIns = checkInStore.all()
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let weeklyCheckIns = allCheckIns.filter { $0.timestamp >= weekAgo }
            return weeklyCheckIns.count
            
        case .weeklyExercises:
            let allExercises = exerciseStore.completions
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            let weeklyExercises = allExercises.filter { $0.completedAt >= weekAgo }
            return weeklyExercises.count
            
        case .streakDays:
            return streakStore.currentStreak(for: .postureChecks)
            
        case .totalPostureChecks:
            let allCheckIns = checkInStore.all()
            return allCheckIns.count
            
        case .totalExercises:
            let allExercises = exerciseStore.completions
            return allExercises.count
        }
    }
    
    /// Update all goal progress based on current data
    /// Called when check-ins or exercises are completed
    func updateAllGoalProgress() {
        for index in goals.indices {
            let newProgress = calculateProgressForGoal(goals[index])
            goals[index].currentProgress = newProgress
            goals[index].updatedAt = Date()
        }
        saveGoals()
        Log.info("Updated progress for all goals")
    }
    
    /// Get completion statistics
    /// - Returns: Tuple with (completed goals, total active goals, completion percentage)
    func getCompletionStats() -> (completed: Int, total: Int, percentage: Double) {
        let activeGoals = getActiveGoals()
        let completedGoals = activeGoals.filter { $0.isCompleted }
        
        let completed = completedGoals.count
        let total = activeGoals.count
        let percentage = total > 0 ? Double(completed) / Double(total) : 0.0
        
        return (completed, total, percentage)
    }
    
    /// Reset all goals data
    /// Useful for testing and fresh start
    func resetAll() {
        goals = DefaultGoals.create()
        saveGoals()
        Log.info("Reset all goals data")
    }
}
