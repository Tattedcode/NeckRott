//
//  ForwardNeckV1App.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

@main
struct ForwardNeckV1App: App {
    init() {
        // Initialize leaderboard store on app launch
        // This generates device ID and sets up local profile
        _ = LeaderboardStore.shared
        Log.info("ForwardNeckV1 app initialized")
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
        }
    }
}
