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
        // Schedule Quick Workout notifications (always send)
        await scheduleQuickWorkoutReminders()
        
        // Schedule Full Daily Workout notifications (conditionally based on completion)
        await rescheduleFullDailyWorkoutNotifications()
    }
    
    /// Schedule Quick Workout notifications at fixed times: 9am, 12pm, 3pm, 6pm, 9pm
    /// These notifications always fire regardless of completion status
    private func scheduleQuickWorkoutReminders() async {
        let center = UNUserNotificationCenter.current()
        
        // Quick Workout notification times: 9am, 12pm, 3pm, 6pm, 9pm
        let quickWorkoutTimes = [
            (hour: 9, minute: 0, identifier: "exercise.quick.9am"),
            (hour: 12, minute: 0, identifier: "exercise.quick.12pm"),
            (hour: 15, minute: 0, identifier: "exercise.quick.3pm"),
            (hour: 18, minute: 0, identifier: "exercise.quick.6pm"),
            (hour: 21, minute: 0, identifier: "exercise.quick.9pm")
        ]
        
        do {
            for time in quickWorkoutTimes {
                var dateComponents = DateComponents()
                dateComponents.hour = time.hour
                dateComponents.minute = time.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let content = UNMutableNotificationContent()
                content.title = "Quick Workout Time! ☀️"
                content.body = "Complete your quick workout to stay active"
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: time.identifier, content: content, trigger: trigger)
                try await center.add(request)
            }
            Log.info("Scheduled Quick Workout reminders at 9am, 12pm, 3pm, 6pm, 9pm")
        } catch {
            Log.error("Failed to schedule Quick Workout reminders: \(error.localizedDescription)")
        }
    }
    
    /// Check if Full Daily Workout is completed today
    private func isFullDailyWorkoutCompletedToday() -> Bool {
        let exerciseStore = ExerciseStore.shared
        return exerciseStore.isTimeSlotCompleted(.afternoon, for: Date())
    }
    
    /// Schedule Full Daily Workout notifications at 12pm, 3pm, 6pm, 9pm
    /// Always schedules repeating notifications (they fire daily)
    /// They will be cancelled if workout is completed today, but rescheduled when app becomes active
    func scheduleFullDailyWorkoutReminders() async {
        let center = UNUserNotificationCenter.current()
        
        // Full Daily Workout notification times: 12pm, 3pm, 6pm, 9pm
        let fullWorkoutTimes = [
            (hour: 12, minute: 0, identifier: "exercise.full.12pm"),
            (hour: 15, minute: 0, identifier: "exercise.full.3pm"),
            (hour: 18, minute: 0, identifier: "exercise.full.6pm"),
            (hour: 21, minute: 0, identifier: "exercise.full.9pm")
        ]
        
        do {
            // Schedule all Full Daily Workout notifications
            // Note: Adding a notification with an existing identifier will replace the old one
            for time in fullWorkoutTimes {
                var dateComponents = DateComponents()
                dateComponents.hour = time.hour
                dateComponents.minute = time.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let content = UNMutableNotificationContent()
                content.title = "Full Daily Workout Time! 💪"
                content.body = "Time for your full daily workout"
                content.sound = .default
                
                let request = UNNotificationRequest(identifier: time.identifier, content: content, trigger: trigger)
                try await center.add(request)
                Log.info("Scheduled Full Daily Workout reminder for \(time.hour):\(String(format: "%02d", time.minute))")
            }
        } catch {
            Log.error("Failed to schedule Full Daily Workout reminders: \(error.localizedDescription)")
        }
    }
    
    /// Cancel all pending Full Daily Workout notifications for today
    func cancelFullDailyWorkoutNotifications() async {
        let center = UNUserNotificationCenter.current()
        let identifiers = [
            "exercise.full.12pm",
            "exercise.full.3pm",
            "exercise.full.6pm",
            "exercise.full.9pm"
        ]
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        Log.info("Cancelled Full Daily Workout notifications")
    }
    
    /// Reschedule Full Daily Workout notifications based on current completion status
    /// Called when app becomes active to ensure notifications are up-to-date
    /// Always reschedules notifications (they're repeating, so they'll fire daily)
    /// but cancels them if workout is already completed today
    func rescheduleFullDailyWorkoutNotifications() async {
        // Always schedule notifications (they're repeating, so they'll fire every day)
        // But cancel them if already completed today
        await scheduleFullDailyWorkoutReminders()
        
        // If completed today, cancel remaining notifications for today
        if isFullDailyWorkoutCompletedToday() {
            await cancelFullDailyWorkoutNotifications()
            Log.info("Full Daily Workout completed today, cancelled remaining notifications for today")
        } else {
            Log.info("Full Daily Workout not completed today, notifications scheduled")
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
    
    // MARK: - Debug Helpers
    
    /// Debug method to print all pending notifications
    /// Useful for testing and verification
    func debugPrintPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            Log.info("📬 Total pending notifications: \(requests.count)")
            
            let quickWorkoutNotifications = requests.filter { $0.identifier.contains("exercise.quick") }
            let fullWorkoutNotifications = requests.filter { $0.identifier.contains("exercise.full") }
            
            Log.info("Quick Workout notifications: \(quickWorkoutNotifications.count)")
            for request in quickWorkoutNotifications {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let hour = trigger.dateComponents.hour ?? 0
                    let minute = trigger.dateComponents.minute ?? 0
                    Log.info("  - \(request.identifier): \(hour):\(String(format: "%02d", minute))")
                }
            }
            
            Log.info("Full Daily Workout notifications: \(fullWorkoutNotifications.count)")
            for request in fullWorkoutNotifications {
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    let hour = trigger.dateComponents.hour ?? 0
                    let minute = trigger.dateComponents.minute ?? 0
                    Log.info("  - \(request.identifier): \(hour):\(String(format: "%02d", minute))")
                }
            }
            
            // Check completion status
            Task { @MainActor in
                let exerciseStore = ExerciseStore.shared
                let isCompleted = exerciseStore.isTimeSlotCompleted(.afternoon, for: Date())
                Log.info("Full Daily Workout completed today: \(isCompleted)")
            }
        }
    }
}


