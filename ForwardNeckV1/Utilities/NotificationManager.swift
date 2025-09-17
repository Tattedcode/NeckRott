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
        await center.removeAllPendingNotificationRequests()
        for reminder in reminders where reminder.enabled {
            await schedule(reminder)
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


