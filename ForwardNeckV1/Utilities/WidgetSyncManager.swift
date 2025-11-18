import Foundation
import WidgetKit

enum WidgetSyncManager {
    static let appGroupIdentifier = "group.neckrot"
    private static let defaults = UserDefaults(suiteName: appGroupIdentifier)

    private enum Keys {
        static let percentage = "neckHealthPercent"
        static let mascot = "neckMascot"
        static let mascotPrefix = "neckMascotPrefix"
        static let payload = "neckWidgetPayload"
        static let lastUpdatedDate = "neckWidgetLastUpdated"
    }

    static func updateWidget(percentage: Int, mascot: String) {
        guard let defaults else {
            Log.error("WidgetSyncManager: Missing shared defaults for app group \(appGroupIdentifier)")
            return
        }
        
        let clampedPercentage = max(0, min(percentage, 100))
        let now = Date()
        defaults.set(clampedPercentage, forKey: Keys.percentage)
        
        // Get base mascot name (remove "female" prefix if present)
        // Note: mascot parameter may already have "female" prefix from MascotAssetProvider
        let baseMascot = mascot.replacingOccurrences(of: "female", with: "")
        defaults.set(baseMascot, forKey: Keys.mascot)
        
        // Store mascot prefix based on user preference (for widget compatibility)
        // This ensures widget can reconstruct the full mascot name if needed
        let prefix = MascotPreferenceManager.isFemaleMascotSelected ? "female" : ""
        defaults.set(prefix, forKey: Keys.mascotPrefix)

        // Track when data was last written so the widget can clear stale values daily
        defaults.set(now, forKey: Keys.lastUpdatedDate)
        
        // Persist a single payload blob so widget reads a consistent snapshot
        let payload = WidgetPayload(
            percentage: clampedPercentage,
            baseMascot: baseMascot,
            prefix: prefix,
            lastUpdated: now
        )
        if let data = try? JSONEncoder().encode(payload) {
            defaults.set(data, forKey: Keys.payload)
            Log.info("WidgetSyncManager: Stored payload - percentage: \(clampedPercentage)%, baseMascot: \(baseMascot), prefix: \(prefix), input mascot: \(mascot), lastUpdated: \(now)")
        } else {
            Log.error("WidgetSyncManager: Failed to encode widget payload")
        }
        
        // Flush immediately so the widget extension can read the latest values
        defaults.synchronize()
        
        DispatchQueue.main.async {
            WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.kind)
            Log.info("WidgetSyncManager: Requested widget timeline reload")
        }
    }

    static func mascot(for percentage: Int) -> String {
        // Get base mascot name
        let baseMascot: String
        switch percentage {
        case ..<25:
            baseMascot = "mascot1"
        case 25..<50:
            baseMascot = "mascot2"
        case 50..<75:
            baseMascot = "mascot3"
        default:
            baseMascot = "mascot4"
        }
        
        // Resolve mascot name with preference (adds female prefix if needed)
        return MascotAssetProvider.resolvedMascotName(for: baseMascot)
    }
}

enum WidgetConstants {
    static let kind = "NeckRotWidget"
    static let appGroup = WidgetSyncManager.appGroupIdentifier
}

private struct WidgetPayload: Codable {
    let percentage: Int
    let baseMascot: String
    let prefix: String
    let lastUpdated: Date?
}
