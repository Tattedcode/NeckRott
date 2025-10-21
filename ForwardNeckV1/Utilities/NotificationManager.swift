//
//  NotificationManager.swift
//  ForwardNeckV1
//
//  Handles local notification permission and scheduling for reminders.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            Log.info("Notification permission granted: \(granted)")
            return granted
        } catch {
            Log.error("Notification permission error: \(error.localizedDescription)")
            return false
        }
    }

    func scheduleAll(from reminders: [Reminder]) async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        for reminder in reminders where reminder.enabled {
            await schedule(reminder)
        }
        // Also schedule exercise reminders
        await scheduleExerciseReminders()
    }
    
    func scheduleExerciseReminders() async {
        let center = UNUserNotificationCenter.current()
        
        // Quick Workout reminder - 6:00 AM
        var morningDate = DateComponents()
        morningDate.hour = 6
        morningDate.minute = 0
        
        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningDate, repeats: true)
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Quick Workout Time! ☀️"
        morningContent.body = "Complete your quick workout to start your day right"
        morningContent.sound = .default
        
        let morningRequest = UNNotificationRequest(identifier: "exercise.morning", content: morningContent, trigger: morningTrigger)
        
        // Full Daily Workout reminder - 12:00 PM
        var afternoonDate = DateComponents()
        afternoonDate.hour = 12
        afternoonDate.minute = 0
        
        let afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: afternoonDate, repeats: true)
        let afternoonContent = UNMutableNotificationContent()
        afternoonContent.title = "Full Daily Workout Time! 💪"
        afternoonContent.body = "Time for your full daily workout"
        afternoonContent.sound = .default
        
        let afternoonRequest = UNNotificationRequest(identifier: "exercise.afternoon", content: afternoonContent, trigger: afternoonTrigger)
        
        // Add all requests
        do {
            try await center.add(morningRequest)
            try await center.add(afternoonRequest)
            Log.info("Scheduled exercise reminders for Quick Workout and Full Daily Workout")
        } catch {
            Log.error("Failed to schedule exercise reminders: \(error.localizedDescription)")
        }
    }

    private func schedule(_ reminder: Reminder) async {
        let center = UNUserNotificationCenter.current()
        var date = DateComponents()
        date.hour = reminder.hour
        date.minute = reminder.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Posture Check"
        content.body = "Quick check: shoulders back, chin tucked"
        content.sound = .default

        let id = reminder.notificationId ?? reminder.id.uuidString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
            Log.info("Scheduled reminder at \(reminder.timeString)")
        } catch {
            Log.error("Failed to schedule: \(error.localizedDescription)")
        }
    }
}


