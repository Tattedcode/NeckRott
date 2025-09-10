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
final class HomeViewModel: ObservableObject {
    // Daily reminders summary for the progress card
    @Published var completedRemindersToday: Int = 0
    @Published var dailyReminderTarget: Int = 5

    // Weekly stats used by metric cards
    @Published var weeklyPostureCheckins: Int = 0
    @Published var weeklyExercisesDone: Int = 0
    @Published var longestStreakDays: Int = 0

    // Exercises for the Exercises tab
    @Published var exercises: [ExerciseItem] = []

    // Loads initial data. In future, connect to persistence (e.g., Supabase/local store)
    func loadDashboard() {
        // Debug: simulate loading & log values
        print("[HomeViewModel] loadDashboard() called")

        // Temporary seeded values so UI looks alive; replace with real data layer later
        completedRemindersToday = 3
        dailyReminderTarget = 5
        weeklyPostureCheckins = 16
        weeklyExercisesDone = 7
        longestStreakDays = 12
        exercises = [
            ExerciseItem(title: "Neck Tilt Stretch", iconSystemName: "person.fill.viewfinder", durationMinutes: 2),
            ExerciseItem(title: "Chin Tucks", iconSystemName: "face.smiling", durationMinutes: 1),
            ExerciseItem(title: "Shoulder Rolls", iconSystemName: "figure.strengthtraining.traditional", durationMinutes: 2)
        ]
    }
}


