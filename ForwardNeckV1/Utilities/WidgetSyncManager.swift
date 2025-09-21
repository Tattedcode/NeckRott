import Foundation
import WidgetKit

enum WidgetSyncManager {
    static let appGroupIdentifier = "group.forwardneck"
    private static let defaults = UserDefaults(suiteName: appGroupIdentifier)

    private enum Keys {
        static let percentage = "neckHealthPercent"
        static let mascot = "neckMascot"
    }

    static func updateWidget(percentage: Int, mascot: String) {
        defaults?.set(percentage, forKey: Keys.percentage)
        defaults?.set(mascot, forKey: Keys.mascot)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.kind)
    }

    static func mascot(for percentage: Int) -> String {
        switch percentage {
        case ..<25:
            return "mascot1"
        case 25..<50:
            return "mascot2"
        case 50..<75:
            return "mascot3"
        default:
            return "mascot4"
        }
    }
}

enum WidgetConstants {
    static let kind = "ForwardNeckWidget"
}
