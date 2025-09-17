//
//  GoalsViewModel.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// ViewModel for the Goals screen
/// Part of S-005: Goals Screen
@MainActor
final class GoalsViewModel: ObservableObject {
    /// Store dependencies for goals data
    private let goalsStore: GoalsStore = GoalsStore.shared
    
    /// Published properties for UI updates
    @Published var goals: [CustomGoal] = []
    @Published var completedGoals: Int = 0
    @Published var totalGoals: Int = 0
    @Published var completionPercentage: Double = 0.0
    @Published var activeGoalsCount: Int = 0
    
    /// Load all goals data
    /// Part of F-006: Custom Goals feature
    func loadGoals() {
        goals = goalsStore.goals
        updateStats()
        Log.info("Loaded \(goals.count) goals")
    }
    
    /// Add a new goal
    /// - Parameter goal: The goal to add
    func addGoal(_ goal: CustomGoal) {
        goalsStore.addGoal(goal)
        loadGoals() // Refresh data
        Log.info("Added new goal: \(goal.title)")
    }
    
    /// Update an existing goal
    /// - Parameter goal: The updated goal
    func updateGoal(_ goal: CustomGoal) {
        goalsStore.updateGoal(goal)
        loadGoals() // Refresh data
        Log.info("Updated goal: \(goal.title)")
    }
    
    /// Delete a goal
    /// - Parameter goalId: ID of the goal to delete
    func deleteGoal(_ goalId: UUID) {
        goalsStore.deleteGoal(goalId)
        loadGoals() // Refresh data
        Log.info("Deleted goal with ID: \(goalId)")
    }
    
    /// Toggle goal active status
    /// - Parameter goalId: ID of the goal to toggle
    func toggleGoalActive(_ goalId: UUID) {
        goalsStore.toggleGoalActive(goalId)
        loadGoals() // Refresh data
        Log.info("Toggled goal active status for ID: \(goalId)")
    }
    
    /// Update all goal progress based on current data
    /// Called when check-ins or exercises are completed
    func updateAllGoalProgress() {
        goalsStore.updateAllGoalProgress()
        loadGoals() // Refresh data
        Log.info("Updated progress for all goals")
    }
    
    /// Get active goals only
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
    
    /// Update completion statistics
    /// Part of F-006: Custom Goals feature
    private func updateStats() {
        let stats = goalsStore.getCompletionStats()
        completedGoals = stats.completed
        totalGoals = stats.total
        completionPercentage = stats.percentage
        activeGoalsCount = getActiveGoals().count
        
        Log.info("Updated stats: \(completedGoals)/\(totalGoals) goals completed (\(Int(completionPercentage * 100))%)")
    }
}
