//
//  NeckRotV1App.swift
//  NeckRotV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

@main
struct NeckRotV1App: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Initialize leaderboard store on app launch
        // This generates device ID and sets up local profile
        _ = LeaderboardStore.shared
        Log.info("NeckRotV1 app initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Schedule exercise reminders on app launch
                    Task {
                        await NotificationManager.shared.scheduleExerciseReminders()
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    // Reschedule Full Daily Workout notifications when app becomes active
                    // This ensures notifications are cancelled if workout was completed while app was in background
                    if newPhase == .active && oldPhase != .active {
                        Task {
                            await NotificationManager.shared.rescheduleFullDailyWorkoutNotifications()
                        }
                    }
                }
        }
    }
}
