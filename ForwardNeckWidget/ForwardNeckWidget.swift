import WidgetKit
import SwiftUI
import UIKit

struct NeckRotEntry: TimelineEntry {
    let date: Date
    let percentage: Int
    let mascot: String

    // Default to a neutral zero state so we never show an old/stale value
    static let placeholder = NeckRotEntry(date: Date(), percentage: 0, mascot: "mascot1")
}

struct NeckRotProvider: TimelineProvider {
    func placeholder(in context: Context) -> NeckRotEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (NeckRotEntry) -> Void) {
        // When the widget is displayed inside the gallery we don't have access
        // to the shared defaults yet. Return a static preview so users can see
        // what to expect instead of the system redacted placeholder.
        if context.isPreview {
            completion(.placeholder)
        } else {
            completion(loadEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NeckRotEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh roughly every 30 minutes so data stays current but battery friendly.
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> NeckRotEntry {
        guard let store = UserDefaults(suiteName: WidgetConstants.appGroup) else {
            // If the app group cannot be read, show a neutral empty state instead of an old cached value
            print("Widget: Missing shared defaults for app group \(WidgetConstants.appGroup) - returning zero state")
            return NeckRotEntry(date: Date(), percentage: 0, mascot: "mascot1")
        }
        let today = Date()
        let calendar = Calendar.current

        if let payload = loadPayload(from: store) {
            // If payload is stale (from a previous day), show a reset state
            let payloadDate = payload.lastUpdated
            let isStale = !(payloadDate.map { calendar.isDate($0, inSameDayAs: today) } ?? false)
            if isStale {
                let mascot = resolvedMascotName(for: mascotFor(percentage: 0), prefix: payload.prefix)
                print("Widget: Payload stale (lastUpdated: \(payloadDate?.description ?? "nil")) - resetting to 0% with mascot \(mascot)")
                return NeckRotEntry(date: today, percentage: 0, mascot: mascot)
            }

            let clamped = max(0, min(payload.percentage, 100))
            let mascot = resolvedMascotName(for: payload.baseMascot, prefix: payload.prefix)
            // Debug: Log widget data loading from payload
            print("Widget: Loaded from payload - percentage: \(clamped)%, baseMascot: \(payload.baseMascot), prefix: \(payload.prefix), resolved mascot: \(mascot), lastUpdated: \(payloadDate?.description ?? "nil")")
            return NeckRotEntry(date: today, percentage: clamped, mascot: mascot)
        }

        let storedDate = store.object(forKey: WidgetConstants.Keys.lastUpdatedDate) as? Date
        let isStale = storedDate.map { !calendar.isDate($0, inSameDayAs: today) } ?? true
        let rawPercentage = isStale ? 0 : store.integer(forKey: WidgetConstants.Keys.percentage)
        let clamped = max(0, min(rawPercentage, 100))
        let storedMascot = isStale ? nil : store.string(forKey: WidgetConstants.Keys.mascot)
        let storedPrefix = store.string(forKey: WidgetConstants.Keys.mascotPrefix) ?? ""
        let baseMascot = storedMascot ?? mascotFor(percentage: clamped)
        let mascot = resolvedMascotName(for: baseMascot, prefix: storedPrefix)
        
        // Debug: Log widget data loading from individual keys
        print("Widget: Loaded from keys - percentage: \(clamped)%, baseMascot: \(baseMascot), prefix: \(storedPrefix), resolved mascot: \(mascot), lastUpdated: \(storedDate?.description ?? "nil") stale=\(isStale)")

        return NeckRotEntry(date: today, percentage: clamped, mascot: mascot)
    }
    
    // Map percentage -> mascot asset, same thresholds used on HomeView
    private func mascotFor(percentage: Int) -> String {
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

    private func resolvedMascotName(for base: String, prefix: String) -> String {
        guard base.hasPrefix("mascot"), !prefix.isEmpty else { return base }
        return "\(prefix)\(base)"
    }
    
    private func loadPayload(from store: UserDefaults?) -> WidgetPayload? {
        guard let data = store?.data(forKey: WidgetConstants.Keys.payload) else { return nil }
        return try? JSONDecoder().decode(WidgetPayload.self, from: data)
    }
}

struct NeckRotWidgetEntryView: View {
    var entry: NeckRotProvider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        VStack(spacing: 8) {
            // Bigger mascot now that the number is gone
            MascotImage(name: entry.mascot)
                .frame(height: family == .systemSmall ? 120 : 150)

            // Progress bar section
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.red, .yellow, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(entry.percentage) / 100.0,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                Text("Neck health")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .unredacted(if: redactionReasons.contains(.placeholder))
        .containerBackground(for: .widget) {
            WidgetGradient()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Neck health \(entry.percentage) percent")
    }
}

struct NeckRotWidget: Widget {
    let kind: String = WidgetConstants.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NeckRotProvider()) { entry in
            NeckRotWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Neck Health")
        .description("Check your latest neck health progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct WidgetGradient: View {
    private static let lightBackground = Color(red: 0.99, green: 0.96, blue: 0.90)

    var body: some View {
        WidgetGradient.lightBackground
    }
}

enum WidgetConstants {
    static let kind = "NeckRotWidget"
    static let appGroup = "group.neckrot"

    enum Keys {
        static let percentage = "neckHealthPercent"
        static let mascot = "neckMascot"
        static let mascotPrefix = "neckMascotPrefix"
        static let payload = "neckWidgetPayload"
        static let lastUpdatedDate = "neckWidgetLastUpdated"
    }
}

#Preview(as: .systemSmall) {
    NeckRotWidget()
} timeline: {
    NeckRotEntry.placeholder
}

#Preview(as: .systemMedium) {
    NeckRotWidget()
} timeline: {
    NeckRotEntry.placeholder
}

private struct MascotImage: View {
    let name: String
    
    // Strip "female" prefix if present - widget only has mascot1-4 assets
    private var assetName: String {
        if name.hasPrefix("female") {
            return String(name.dropFirst(6))
        }
        return name
    }
    
    // Get widget bundle explicitly
    private var widgetBundle: Bundle {
        // Widget extensions use Bundle.main for their own assets
        return Bundle.main
    }

    var body: some View {
        // Use UIImage with explicit bundle to ensure widget assets are loaded
        if let uiImage = UIImage(named: assetName, in: widgetBundle, compatibleWith: nil) {
            let scaled = uiImage.downscaled(maxDimension: 800)
            Image(uiImage: scaled)
                .resizable()
                .scaledToFit()
        } else {
            // Fallback - try direct Image
            Image(assetName)
                .resizable()
                .scaledToFit()
        }
    }
}

private extension View {
    @ViewBuilder
    func unredacted(if condition: Bool) -> some View {
        if condition {
            self.unredacted()
        } else {
            self
        }
    }
}

private struct WidgetPayload: Codable {
    let percentage: Int
    let baseMascot: String
    let prefix: String
    let lastUpdated: Date?
}

private extension UIImage {
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        let scaleRatio = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scaleRatio, height: size.height * scaleRatio)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false

        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
