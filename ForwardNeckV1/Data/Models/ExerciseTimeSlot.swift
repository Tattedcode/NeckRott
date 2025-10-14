//
//  ExerciseTimeSlot.swift
//  ForwardNeckV1
//
//  Time slot system for spreading exercises throughout the day.
//

import Foundation

/// Represents the three daily exercise time slots
enum ExerciseTimeSlot: String, Codable, CaseIterable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    
    /// Time range for this slot (hour range in 24-hour format)
    var timeRange: (start: Int, end: Int) {
        switch self {
        case .morning:
            return (6, 11) // 6:00 AM - 11:59 AM
        case .afternoon:
            return (12, 17) // 12:00 PM - 5:59 PM
        case .evening:
            return (18, 23) // 6:00 PM - 11:59 PM
        }
    }
    
    /// Human-readable time range string
    var timeRangeString: String {
        switch self {
        case .morning:
            return "6:00 AM - 11:59 AM"
        case .afternoon:
            return "12:00 PM - 5:59 PM"
        case .evening:
            return "6:00 PM - 11:59 PM"
        }
    }
    
    /// Start hour for notifications
    var notificationHour: Int {
        switch self {
        case .morning:
            return 6 // 6:00 AM
        case .afternoon:
            return 12 // 12:00 PM
        case .evening:
            return 18 // 6:00 PM
        }
    }
    
    /// Get the current time slot based on current time
    static func currentTimeSlot(at date: Date = Date()) -> ExerciseTimeSlot? {
        let hour = Calendar.current.component(.hour, from: date)
        
        for slot in ExerciseTimeSlot.allCases {
            let range = slot.timeRange
            if hour >= range.start && hour <= range.end {
                return slot
            }
        }
        
        // Between midnight and 6 AM - no active slot
        return nil
    }
    
    /// Get the next available time slot from current time
    static func nextAvailableTimeSlot(from date: Date = Date()) -> ExerciseTimeSlot {
        let hour = Calendar.current.component(.hour, from: date)
        
        // Before morning starts (midnight to 6 AM)
        if hour < 6 {
            return .morning
        }
        
        // During or after morning, before afternoon
        if hour < 12 {
            return .afternoon
        }
        
        // During or after afternoon, before evening
        if hour < 18 {
            return .evening
        }
        
        // After evening - next is tomorrow morning
        return .morning
    }
    
    /// Check if this time slot is currently active (within its time range)
    func isActive(at date: Date = Date()) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        let range = timeRange
        return hour >= range.start && hour <= range.end
    }
    
    /// Calculate time interval until this slot becomes available
    func timeUntilAvailable(from date: Date = Date()) -> TimeInterval? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let startHour = timeRange.start
        
        // If we're currently in this slot, it's available now
        if isActive(at: date) {
            return 0
        }
        
        // If slot is in the future today
        if hour < startHour {
            var components = calendar.dateComponents([.year, .month, .day], from: date)
            components.hour = startHour
            components.minute = 0
            components.second = 0
            
            if let slotStart = calendar.date(from: components) {
                return slotStart.timeIntervalSince(date)
            }
        }
        
        // Slot is tomorrow (or for morning slot after evening)
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.day! += 1
        components.hour = startHour
        components.minute = 0
        components.second = 0
        
        if let slotStart = calendar.date(from: components) {
            return slotStart.timeIntervalSince(date)
        }
        
        return nil
    }
    
    /// Check if this slot's time window has already ended for the given date
    func timeSlotHasPassed(on date: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let endHour = timeRange.end
        return hour > endHour || (hour == endHour && minute >= 59)
    }
    
    /// Format time interval as countdown string (e.g., "2h 15m")
    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

