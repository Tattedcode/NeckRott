//
//  HomeViewModel+AppMonitoring.swift
//  ForwardNeckV1
//
//  Screen-time tracking helpers and DeviceActivity integration.
//

import FamilyControls
import Foundation
#if canImport(DeviceActivity)
import DeviceActivity
#endif

extension HomeViewModel {
    var hasMonitoredApps: Bool { !activitySelection.applications.isEmpty }

    var trackedUsageDisplay: String {
        formatMinutes(trackedUsageMinutes)
    }

    func refreshTrackedAppUsage() {
        trackedUsageMinutes = appMonitoringStore.totalUsageMinutes()
    }

    func scheduleMonitoring(for selection: FamilyActivitySelection) {
        #if canImport(DeviceActivity)
        if #available(iOS 16.0, *) {
            Task { await configureMonitoring(for: selection) }
        } else {
            Log.info("Device activity monitoring requires iOS 16.0 or newer")
        }
        #else
        Log.info("DeviceActivity framework unavailable – skipping monitoring schedule")
        #endif
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }

    #if canImport(DeviceActivity)
    @available(iOS 16.0, *)
    private func configureMonitoring(for selection: FamilyActivitySelection) async {
        let monitoredApps = selection.applications
        let activityName = DeviceActivityName("ForwardNeckAppMonitoring")
        let center = DeviceActivityCenter()

        guard !monitoredApps.isEmpty else {
            center.stopMonitoring([activityName])
            Log.info("Stopped app monitoring – no apps selected")
            return
        }

        do {
            if AuthorizationCenter.shared.authorizationStatus != .approved {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            }

            let startOfDay = DateComponents(hour: 0, minute: 0)
            let endOfDay = DateComponents(hour: 23, minute: 59, second: 59)
            let schedule = DeviceActivitySchedule(intervalStart: startOfDay, intervalEnd: endOfDay, repeats: true)

            try center.startMonitoring(activityName, during: schedule)
            Log.info("Scheduled app monitoring for \(monitoredApps.count) apps")
        } catch {
            Log.error("Failed to schedule app monitoring: \(error.localizedDescription)")
        }
    }
    #endif
}
