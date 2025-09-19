//
//  UserStore.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Manages user profile data persistence
@MainActor
class UserStore: ObservableObject {
    @Published var userName: String = ""
    @Published var dailyGoal: Int = 3 // Default to 3 hours
    
    private let userDefaults = UserDefaults.standard
    private let userNameKey = "userName"
    private let dailyGoalKey = "dailyGoal"
    
    init() {
        loadUserData()
    }
    
    /// Load user data from UserDefaults
    func loadUserData() {
        userName = userDefaults.string(forKey: userNameKey) ?? ""
        dailyGoal = userDefaults.integer(forKey: dailyGoalKey)
        if dailyGoal == 0 { dailyGoal = 3 } // Default to 3 hours if not set
        Log.info("Loaded user name: \(userName), daily goal: \(dailyGoal)")
    }
    
    /// Save user name to UserDefaults
    func saveUserName(_ name: String) {
        userName = name
        userDefaults.set(name, forKey: userNameKey)
        Log.info("Saved user name: \(name)")
    }
    
    /// Save daily goal to UserDefaults
    func saveDailyGoal(_ goal: Int) {
        dailyGoal = goal
        userDefaults.set(goal, forKey: dailyGoalKey)
        Log.info("Saved daily goal: \(goal) hours")
    }
    
    /// Clear all user data
    func clearUserData() {
        userName = ""
        dailyGoal = 3 // Reset to default
        userDefaults.removeObject(forKey: userNameKey)
        userDefaults.removeObject(forKey: dailyGoalKey)
        Log.info("Cleared user data")
    }
}






