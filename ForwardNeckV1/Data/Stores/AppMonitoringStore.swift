//
//  AppMonitoringStore.swift
//  ForwardNeckV1
//
//  Store for managing selected apps to monitor and their usage data
//

import Foundation
import SwiftUI
import FamilyControls

@Observable
final class AppMonitoringStore {
    // MARK: - Observable Properties

    /// User's approved selection from the Family Activity picker
    var activitySelection: FamilyActivitySelection = .init()

    /// Dictionary of usage data in minutes keyed by bundle identifier
    var appUsageData: [String: Int] = [:]

    // MARK: - UserDefaults Keys

    private let selectionKey = "monitoredAppSelection"
    private let appUsageDataKey = "appUsageData"
    private let userDefaults = UserDefaults(suiteName: "group.forwardneck") ?? .standard

    var storageDefaults: UserDefaults { userDefaults }

    // MARK: - Initialization

    init() {
        loadSelection()
        loadUsageData()
    }

    // MARK: - Public Methods

    /// Persist the latest Family Activity selection
    func updateSelection(_ newSelection: FamilyActivitySelection) {
        activitySelection = newSelection
        saveSelection()
        Log.info("Updated monitored app selection: \(newSelection.applications.count) apps")
    }

    /// Update usage data for a specific app
    func updateUsageData(bundleIdentifier: String, minutes: Int) {
        appUsageData[bundleIdentifier] = minutes
        saveAppUsageData()
        Log.info("Updated usage for \(bundleIdentifier): \(minutes) minutes")
    }

    /// Get total usage time for all monitored apps
    func totalUsageMinutes() -> Int {
        return appUsageData.values.reduce(0, +)
    }

    /// Clear all monitoring data
    func clearAllData() {
        activitySelection = .init()
        appUsageData.removeAll()
        saveSelection()
        saveAppUsageData()
        Log.info("Cleared all monitoring data")
    }

    // MARK: - Private Methods

    private func loadSelection() {
        guard let data = userDefaults.data(forKey: selectionKey),
              let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }
        activitySelection = decoded
    }

    private func loadUsageData() {
        if let data = userDefaults.data(forKey: appUsageDataKey),
           let usageData = try? JSONDecoder().decode([String: Int].self, from: data) {
            appUsageData = usageData
        }
    }

    private func saveSelection() {
        guard let data = try? JSONEncoder().encode(activitySelection) else { return }
        userDefaults.set(data, forKey: selectionKey)
    }

    private func saveAppUsageData() {
        if let data = try? JSONEncoder().encode(appUsageData) {
            userDefaults.set(data, forKey: appUsageDataKey)
        }
    }
}
