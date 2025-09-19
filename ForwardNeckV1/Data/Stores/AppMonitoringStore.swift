//
//  AppMonitoringStore.swift
//  ForwardNeckV1
//
//  Store for managing selected apps to monitor and their usage data
//

import Foundation
import SwiftUI

@Observable
final class AppMonitoringStore {
    // MARK: - Observable Properties
    
    /// Set of selected app names to monitor
    var selectedApps: Set<String> = []
    
    /// Dictionary of app usage data (app name: usage time in minutes)
    var appUsageData: [String: Int] = [:]
    
    // MARK: - UserDefaults Keys
    
    private let selectedAppsKey = "selectedApps"
    private let appUsageDataKey = "appUsageData"
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    init() {
        loadData()
    }
    
    // MARK: - Public Methods
    
    /// Add an app to the monitoring list
    func addApp(_ appName: String) {
        selectedApps.insert(appName)
        saveSelectedApps()
        Log.info("Added app to monitoring: \(appName)")
    }
    
    /// Remove an app from the monitoring list
    func removeApp(_ appName: String) {
        selectedApps.remove(appName)
        appUsageData.removeValue(forKey: appName)
        saveSelectedApps()
        saveAppUsageData()
        Log.info("Removed app from monitoring: \(appName)")
    }
    
    /// Update the set of selected apps (used from onboarding)
    func updateSelectedApps(_ apps: Set<String>) {
        selectedApps = apps
        saveSelectedApps()
        Log.info("Updated selected apps: \(apps)")
    }
    
    /// Update usage data for a specific app
    func updateUsageData(for appName: String, minutes: Int) {
        appUsageData[appName] = minutes
        saveAppUsageData()
        Log.info("Updated usage for \(appName): \(minutes) minutes")
    }
    
    /// Get total usage time for all monitored apps
    func getTotalUsageTime() -> Int {
        return appUsageData.values.reduce(0, +)
    }
    
    /// Get usage time for a specific app
    func getUsageTime(for appName: String) -> Int {
        return appUsageData[appName] ?? 0
    }
    
    /// Get the most used app
    func getMostUsedApp() -> String? {
        return appUsageData.max(by: { $0.value < $1.value })?.key
    }
    
    /// Check if an app is being monitored
    func isAppMonitored(_ appName: String) -> Bool {
        return selectedApps.contains(appName)
    }
    
    /// Clear all monitoring data
    func clearAllData() {
        selectedApps.removeAll()
        appUsageData.removeAll()
        saveSelectedApps()
        saveAppUsageData()
        Log.info("Cleared all monitoring data")
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        // Load selected apps
        if let data = userDefaults.data(forKey: selectedAppsKey),
           let apps = try? JSONDecoder().decode(Set<String>.self, from: data) {
            selectedApps = apps
        }
        
        // Load app usage data
        if let data = userDefaults.data(forKey: appUsageDataKey),
           let usageData = try? JSONDecoder().decode([String: Int].self, from: data) {
            appUsageData = usageData
        }
        
        Log.info("Loaded monitoring data: \(selectedApps.count) apps, \(appUsageData.count) usage entries")
    }
    
    private func saveSelectedApps() {
        if let data = try? JSONEncoder().encode(selectedApps) {
            userDefaults.set(data, forKey: selectedAppsKey)
        }
    }
    
    private func saveAppUsageData() {
        if let data = try? JSONEncoder().encode(appUsageData) {
            userDefaults.set(data, forKey: appUsageDataKey)
        }
    }
}

// MARK: - Mock Data for Development

extension AppMonitoringStore {
    /// Generate mock usage data for development/testing
    func generateMockData() {
        let mockApps = ["TikTok", "Instagram", "YouTube", "Facebook", "Snapchat"]
        let mockUsageData: [String: Int] = [
            "TikTok": 120,      // 2 hours
            "Instagram": 90,    // 1.5 hours
            "YouTube": 60,      // 1 hour
            "Facebook": 45,     // 45 minutes
            "Snapchat": 30      // 30 minutes
        ]
        
        selectedApps = Set(mockApps)
        appUsageData = mockUsageData
        
        saveSelectedApps()
        saveAppUsageData()
        
        Log.info("Generated mock monitoring data")
    }
}
