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
        
        // Morning reminder - 6:00 AM
        var morningDate = DateComponents()
        morningDate.hour = 6
        morningDate.minute = 0
        
        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningDate, repeats: true)
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Morning Stretch Time! ☀️"
        morningContent.body = "Complete your first neck fix to start your day right"
        morningContent.sound = .default
        
        let morningRequest = UNNotificationRequest(identifier: "exercise.morning", content: morningContent, trigger: morningTrigger)
        
        // Afternoon reminder - 12:00 PM
        var afternoonDate = DateComponents()
        afternoonDate.hour = 12
        afternoonDate.minute = 0
        
        let afternoonTrigger = UNCalendarNotificationTrigger(dateMatching: afternoonDate, repeats: true)
        let afternoonContent = UNMutableNotificationContent()
        afternoonContent.title = "Afternoon Break! ☕️"
        afternoonContent.body = "Time for your second neck fix of the day"
        afternoonContent.sound = .default
        
        let afternoonRequest = UNNotificationRequest(identifier: "exercise.afternoon", content: afternoonContent, trigger: afternoonTrigger)
        
        // Evening reminder - 6:00 PM
        var eveningDate = DateComponents()
        eveningDate.hour = 18
        eveningDate.minute = 0
        
        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningDate, repeats: true)
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Evening Unwind! 🌙"
        eveningContent.body = "Complete your final neck fix to finish strong"
        eveningContent.sound = .default
        
        let eveningRequest = UNNotificationRequest(identifier: "exercise.evening", content: eveningContent, trigger: eveningTrigger)
        
        // Add all requests
        do {
            try await center.add(morningRequest)
            try await center.add(afternoonRequest)
            try await center.add(eveningRequest)
            Log.info("Scheduled exercise reminders for morning, afternoon, and evening")
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


