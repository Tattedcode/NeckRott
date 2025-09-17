//
//  SettingsViewModel.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation
import SwiftUI

/// ViewModel for the Settings screen
/// Part of B-009: Finish S-007 Settings Screen
@MainActor
final class SettingsViewModel: ObservableObject {
    /// Store dependencies for settings management
    private let reminderStore: ReminderStore = ReminderStore.shared
    private let checkInStore: CheckInStore = CheckInStore.shared
    private let exerciseStore: ExerciseStore = ExerciseStore.shared
    private let streakStore: StreakStore = StreakStore.shared
    private let gamificationStore: GamificationStore = GamificationStore.shared
    private let goalsStore: GoalsStore = GoalsStore.shared
    private let themeManager: ThemeManager = ThemeManager.shared
    
    /// Published properties for UI updates
    @Published var reminders: [Reminder] = []
    @Published var newTime: Date = Date()
    @Published var isDarkMode: Bool = false
    @Published var currentTheme: ThemeManager.AppTheme = .system
    @Published var showingResetAlert: Bool = false
    @Published var resetType: ResetType = .allData
    
    /// Reset types available
    enum ResetType: String, CaseIterable, Identifiable {
        case allData = "All Data"
        case checkIns = "Check-ins Only"
        case exercises = "Exercises Only"
        case streaks = "Streaks Only"
        case gamification = "Gamification Only"
        case goals = "Goals Only"
        
        var id: String { rawValue }
        
        /// Description of what will be reset
        var description: String {
            switch self {
            case .allData:
                return "Reset all app data including check-ins, exercises, streaks, gamification, and goals"
            case .checkIns:
                return "Reset only posture check-in history"
            case .exercises:
                return "Reset only exercise completion history"
            case .streaks:
                return "Reset only streak data"
            case .gamification:
                return "Reset only XP, coins, levels, and achievements"
            case .goals:
                return "Reset only custom goals"
            }
        }
        
        /// Icon for the reset type
        var icon: String {
            switch self {
            case .allData:
                return "trash.fill"
            case .checkIns:
                return "checkmark.circle"
            case .exercises:
                return "figure.strengthtraining.functional"
            case .streaks:
                return "flame"
            case .gamification:
                return "rosette"
            case .goals:
                return "target"
            }
        }
    }
    
    /// Initialize the settings view model
    init() {
        loadSettings()
        observeThemeChanges()
        Log.info("SettingsViewModel initialized")
    }
    
    /// Load all settings data
    /// Part of B-009: Finish S-007 Settings Screen
    func loadSettings() {
        reminders = reminderStore.all()
        isDarkMode = themeManager.isDarkMode
        currentTheme = themeManager.currentTheme
        Log.info("Settings loaded: \(reminders.count) reminders, theme: \(currentTheme.rawValue)")
    }
    
    /// Add a new reminder
    /// - Parameter time: The time for the new reminder
    func addReminder(time: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        Task {
            await reminderStore.add(hour: hour, minute: minute, enabled: true)
            reminders = reminderStore.all()
            Log.info("Added reminder at \(hour):\(minute)")
        }
    }
    
    /// Delete a reminder
    /// - Parameter reminder: The reminder to delete
    func deleteReminder(_ reminder: Reminder) {
        Task {
            await reminderStore.remove(id: reminder.id)
            reminders = reminderStore.all()
            Log.info("Deleted reminder at \(reminder.timeString)")
        }
    }
    
    /// Toggle reminder enabled state
    /// - Parameter reminder: The reminder to toggle
    func toggleReminder(_ reminder: Reminder) {
        var updatedReminder = reminder
        updatedReminder.enabled.toggle()
        
        Task {
            await reminderStore.update(updatedReminder)
            reminders = reminderStore.all()
            Log.info("Toggled reminder at \(reminder.timeString) to \(updatedReminder.enabled ? "enabled" : "disabled")")
        }
    }
    
    /// Set the app theme
    /// - Parameter theme: The theme to set
    func setTheme(_ theme: ThemeManager.AppTheme) {
        themeManager.setTheme(theme)
        currentTheme = theme
        isDarkMode = themeManager.isDarkMode
        Log.info("Theme set to: \(theme.rawValue)")
    }
    
    /// Show reset alert for specific reset type
    /// - Parameter resetType: The type of reset to perform
    func showResetAlert(for resetType: ResetType) {
        self.resetType = resetType
        showingResetAlert = true
        Log.info("Showing reset alert for: \(resetType.rawValue)")
    }
    
    /// Perform the reset based on selected type
    func performReset() {
        Task {
            switch resetType {
            case .allData:
                await resetAllData()
            case .checkIns:
                await resetCheckIns()
            case .exercises:
                await resetExercises()
            case .streaks:
                await resetStreaks()
            case .gamification:
                await resetGamification()
            case .goals:
                await resetGoals()
            }
            
            showingResetAlert = false
            Log.info("Reset completed for: \(resetType.rawValue)")
        }
    }
    
    /// Reset all app data
    private func resetAllData() async {
        await checkInStore.resetAll()
        await exerciseStore.resetAll()
        streakStore.resetAll()
        gamificationStore.resetAll()
        goalsStore.resetAll()
        Log.info("All data reset completed")
    }
    
    /// Reset only check-ins
    private func resetCheckIns() async {
        await checkInStore.resetAll()
        Log.info("Check-ins reset completed")
    }
    
    /// Reset only exercises
    private func resetExercises() async {
        await exerciseStore.resetAll()
        Log.info("Exercises reset completed")
    }
    
    /// Reset only streaks
    private func resetStreaks() async {
        streakStore.resetAll()
        Log.info("Streaks reset completed")
    }
    
    /// Reset only gamification
    private func resetGamification() async {
        gamificationStore.resetAll()
        Log.info("Gamification reset completed")
    }
    
    /// Reset only goals
    private func resetGoals() async {
        goalsStore.resetAll()
        Log.info("Goals reset completed")
    }
    
    /// Observe theme changes from ThemeManager
    private func observeThemeChanges() {
        themeManager.$isDarkMode
            .assign(to: &$isDarkMode)
        
        themeManager.$currentTheme
            .assign(to: &$currentTheme)
    }
    
    /// Get app version information
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }
    
    /// Get app name
    var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "ForwardNeck"
    }
}
