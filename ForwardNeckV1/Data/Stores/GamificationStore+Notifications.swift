//
//  GamificationStore+Notifications.swift
//  ForwardNeckV1
//
//  Notification helpers for gamification updates.
//

import Foundation

extension Notification.Name {
    static let levelDidChange = Notification.Name("GamificationStore.levelDidChange")
    static let userProgressDidChange = Notification.Name("GamificationStore.userProgressDidChange")
    static let userProgressDidChangeMainThread = Notification.Name("GamificationStore.userProgressDidChangeMainThread")
}

extension GamificationStore {
    func notifyProgressChange(reason: String) {
        Log.info("GamificationStore progress changed due to: \(reason)")
        NotificationCenter.default.post(name: .userProgressDidChange, object: nil)
        Task { @MainActor in
            NotificationCenter.default.post(name: .userProgressDidChangeMainThread, object: nil)
        }
    }
}
