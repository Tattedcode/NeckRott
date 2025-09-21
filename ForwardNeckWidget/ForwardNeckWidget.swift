import WidgetKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ForwardNeckEntry: TimelineEntry {
    let date: Date
    let percentage: Int
    let mascot: String

    static let placeholder = ForwardNeckEntry(date: Date(), percentage: 72, mascot: "mascot3")
}

struct ForwardNeckProvider: TimelineProvider {
    func placeholder(in context: Context) -> ForwardNeckEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ForwardNeckEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForwardNeckEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh roughly every 30 minutes so data stays current but battery friendly.
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> ForwardNeckEntry {
        let store = UserDefaults(suiteName: WidgetConstants.appGroup)
        let rawPercentage = store?.integer(forKey: WidgetConstants.Keys.percentage) ?? ForwardNeckEntry.placeholder.percentage
        let clamped = max(0, min(rawPercentage, 100))
        let storedMascot = store?.string(forKey: WidgetConstants.Keys.mascot)
        let mascot = storedMascot ?? mascotFor(percentage: clamped)

        return ForwardNeckEntry(date: Date(), percentage: clamped, mascot: mascot)
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
}

struct ForwardNeckWidgetEntryView: View {
    var entry: ForwardNeckProvider.Entry

    var body: some View {
        GeometryReader { proxy in
            let minSide = min(proxy.size.width, proxy.size.height)
            let headerFont = minSide * 0.12
            let percentageFont = minSide * 0.42
            let mascotHeight = minSide * 0.38
            let spacing = minSide * 0.08

            VStack(spacing: spacing) {
                Text("neck health")
                    .font(.system(size: headerFont, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .minimumScaleFactor(0.6)

                Text("\(entry.percentage)%")
                    .font(.system(size: percentageFont, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)

                MascotImage(name: entry.mascot, height: mascotHeight)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .containerBackground(for: .widget) {
            WidgetGradient()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Neck health \(entry.percentage) percent")
    }
}

struct ForwardNeckWidget: Widget {
    let kind: String = WidgetConstants.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ForwardNeckProvider()) { entry in
            ForwardNeckWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Neck Health")
        .description("Check your latest neck health progress at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct WidgetGradient: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.15, green: 0.11, blue: 0.28),
                Color(red: 0.09, green: 0.13, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum WidgetConstants {
    static let kind = "ForwardNeckWidget"
    static let appGroup = "group.forwardneck"

    enum Keys {
        static let percentage = "neckHealthPercent"
        static let mascot = "neckMascot"
    }
}

#Preview(as: .systemSmall) {
    ForwardNeckWidget()
} timeline: {
    ForwardNeckEntry.placeholder
}

#Preview(as: .systemMedium) {
    ForwardNeckWidget()
} timeline: {
    ForwardNeckEntry.placeholder
}

private struct MascotImage: View {
    let name: String
    let height: CGFloat

    var body: some View {
        Group {
#if canImport(UIKit)
            if let image = UIImage(named: name) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                fallback
            }
#else
            Image(name)
                .resizable()
                .scaledToFit()
#endif
        }
        .frame(height: height)
        .shadow(color: Color.black.opacity(0.35), radius: 4, x: 0, y: 2)
        .accessibilityHidden(true)
    }

    private var fallback: some View {
        Image(systemName: "brain.head.profile")
            .font(.system(size: height * 0.7, weight: .medium))
            .foregroundColor(.white.opacity(0.85))
    }
}
