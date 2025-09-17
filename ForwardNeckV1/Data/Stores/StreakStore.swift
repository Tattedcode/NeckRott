//
//  StreakStore.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import Foundation

/// Store for managing streak data persistence
/// Part of D-004: Daily streak count
/// Implements MVVM pattern for data management
@MainActor
final class StreakStore: ObservableObject {
    /// Shared instance for singleton pattern
    static let shared = StreakStore()
    
    /// Published property for streak records - triggers UI updates when changed
    @Published private(set) var streaks: [Streak] = []
    
    /// File URL for persisting streak data
    private let fileURL: URL
    
    /// Initialize the streak store
    /// Sets up file URL and loads existing data
    private init() {
        // Create file URL in Application Support directory
        let documentsPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.fileURL = documentsPath.appendingPathComponent("streaks.json")
        
        // Load existing data on initialization
        load()
    }
    
    /// Add a new streak record for a specific date and type
    /// - Parameters:
    ///   - date: The date for the streak record
    ///   - completed: Whether the goal was completed on this date
    ///   - type: The type of streak being tracked
    func addStreak(for date: Date, completed: Bool, type: StreakType) {
        // Check if streak already exists for this date and type
        let existingIndex = streaks.firstIndex { streak in
            Calendar.current.isDate(streak.date, inSameDayAs: date) && streak.type == type
        }
        
        if let index = existingIndex {
            // Update existing streak
            streaks[index] = Streak(date: date, completed: completed, type: type)
        } else {
            // Add new streak
            let newStreak = Streak(date: date, completed: completed, type: type)
            streaks.append(newStreak)
        }
        
        // Save changes to disk
        save()
    }
    
    /// Get all streak records for a specific type
    /// - Parameter type: The type of streaks to retrieve
    /// - Returns: Array of streak records for the specified type
    func streaks(for type: StreakType) -> [Streak] {
        return streaks.filter { $0.type == type }
    }
    
    /// Get streak records for a specific date range
    /// - Parameters:
    ///   - startDate: Start of the date range
    ///   - endDate: End of the date range
    ///   - type: The type of streaks to retrieve
    /// - Returns: Array of streak records within the date range
    func streaks(from startDate: Date, to endDate: Date, type: StreakType) -> [Streak] {
        return streaks.filter { streak in
            streak.type == type &&
            streak.date >= startDate &&
            streak.date <= endDate
        }
    }
    
    /// Calculate current streak for a specific type
    /// - Parameter type: The type of streak to calculate
    /// - Returns: Current active streak count
    func currentStreak(for type: StreakType) -> Int {
        let typeStreaks = streaks(for: type).sorted { $0.date > $1.date }
        
        var currentStreak = 0
        let calendar = Calendar.current
        let today = Date()
        
        // Start from today and work backwards
        for i in 0..<typeStreaks.count {
            let streak = typeStreaks[i]
            let daysDifference = calendar.dateComponents([.day], from: streak.date, to: today).day ?? 0
            
            // If this is today or yesterday and completed, count it
            if daysDifference <= 1 && streak.completed {
                currentStreak += 1
            } else if daysDifference == 1 && !streak.completed {
                // If yesterday wasn't completed, streak is broken
                break
            } else if daysDifference > 1 {
                // If there's a gap of more than 1 day, streak is broken
                break
            }
        }
        
        return currentStreak
    }
    
    /// Calculate longest streak for a specific type
    /// - Parameter type: The type of streak to calculate
    /// - Returns: Longest streak ever achieved
    func longestStreak(for type: StreakType) -> Int {
        let typeStreaks = streaks(for: type).sorted { $0.date < $1.date }
        
        var longestStreak = 0
        var currentStreak = 0
        let calendar = Calendar.current
        
        for i in 0..<typeStreaks.count {
            let streak = typeStreaks[i]
            
            if streak.completed {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return longestStreak
    }
    
    /// Get comprehensive streak statistics for a specific type
    /// - Parameter type: The type of streak to analyze
    /// - Returns: StreakStats object with all relevant statistics
    func getStats(for type: StreakType) -> StreakStats {
        let typeStreaks = streaks(for: type)
        let completedStreaks = typeStreaks.filter { $0.completed }
        
        return StreakStats(
            currentStreak: currentStreak(for: type),
            longestStreak: longestStreak(for: type),
            totalCompletedDays: completedStreaks.count,
            totalPostureChecks: 0, // Will be populated by integration with CheckInStore
            totalExercises: 0,     // Will be populated by integration with ExerciseStore
            type: type
        )
    }
    
    /// Update daily streaks based on check-ins and exercise completions
    /// This method should be called daily to update streak data
    /// - Parameters:
    ///   - checkIns: Array of check-in dates
    ///   - exerciseCompletions: Array of exercise completion dates
    func updateDailyStreaks(checkIns: [Date], exerciseCompletions: [Date]) {
        let calendar = Calendar.current
        let today = Date()
        
        // Get all unique dates from check-ins and exercise completions
        let allDates = Set(checkIns + exerciseCompletions).sorted()
        
        for date in allDates {
            // Check if there were check-ins on this date
            let hadCheckIns = checkIns.contains { calendar.isDate($0, inSameDayAs: date) }
            
            // Check if there were exercise completions on this date
            let hadExercises = exerciseCompletions.contains { calendar.isDate($0, inSameDayAs: date) }
            
            // Update posture check streak
            addStreak(for: date, completed: hadCheckIns, type: .postureChecks)
            
            // Update exercise streak
            addStreak(for: date, completed: hadExercises, type: .exercises)
            
            // Update combined streak (both check-ins and exercises)
            addStreak(for: date, completed: hadCheckIns && hadExercises, type: .combined)
        }
    }
    
    /// Load streak data from disk
    /// Called during initialization and when data needs to be refreshed
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            streaks = try JSONDecoder().decode([Streak].self, from: data)
            Log.info("Loaded \(streaks.count) streak records")
        } catch {
            Log.error("Failed to load streaks: \(error)")
            streaks = []
        }
    }
    
    /// Save streak data to disk
    /// Called whenever streak data is modified
    private func save() {
        do {
            let data = try JSONEncoder().encode(streaks)
            try data.write(to: fileURL)
            Log.info("Saved \(streaks.count) streak records")
        } catch {
            Log.error("Failed to save streaks: \(error)")
        }
    }
    
    /// Reset all streak data
    /// Useful for testing and fresh start
    func resetAll() {
        streaks = []
        save()
        Log.info("Reset all streak data")
    }
}