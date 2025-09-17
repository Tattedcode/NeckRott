//
//  Reminder.swift
//  ForwardNeckV1
//
//  Data model for a daily posture reminder time.
//

import Foundation

/// Represents a daily reminder at a specific local time (hour/minute)
struct Reminder: Codable, Identifiable, Equatable {
    let id: UUID
    var hour: Int
    var minute: Int
    var enabled: Bool
    /// Optional system notification identifier to cross-reference scheduled notifications
    var notificationId: String?

    init(id: UUID = UUID(), hour: Int, minute: Int, enabled: Bool = true, notificationId: String? = nil) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.enabled = enabled
        self.notificationId = notificationId
    }

    /// Human friendly time string (e.g., 8:30 AM)
    var timeString: String {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let calendar = Calendar.current
        let date = calendar.date(from: comps) ?? Date()
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}


