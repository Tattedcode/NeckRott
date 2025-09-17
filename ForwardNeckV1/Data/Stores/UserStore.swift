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
    
    private let userDefaults = UserDefaults.standard
    private let userNameKey = "userName"
    
    init() {
        loadUserData()
    }
    
    /// Load user data from UserDefaults
    func loadUserData() {
        userName = userDefaults.string(forKey: userNameKey) ?? ""
        Log.info("Loaded user name: \(userName)")
    }
    
    /// Save user name to UserDefaults
    func saveUserName(_ name: String) {
        userName = name
        userDefaults.set(name, forKey: userNameKey)
        Log.info("Saved user name: \(name)")
    }
    
    /// Clear all user data
    func clearUserData() {
        userName = ""
        userDefaults.removeObject(forKey: userNameKey)
        Log.info("Cleared user data")
    }
}






