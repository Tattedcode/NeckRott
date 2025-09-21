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
        let percentage = store?.integer(forKey: WidgetConstants.Keys.percentage) ?? ForwardNeckEntry.placeholder.percentage
        let mascot = store?.string(forKey: WidgetConstants.Keys.mascot) ?? ForwardNeckEntry.placeholder.mascot
        return ForwardNeckEntry(date: Date(), percentage: max(0, min(percentage, 100)), mascot: mascot)
    }
}

struct ForwardNeckWidgetEntryView: View {
    var entry: ForwardNeckProvider.Entry

    var body: some View {
        ZStack {
            WidgetGradient()

            VStack(spacing: 12) {
                Text("neck health")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))

                Text("\(entry.percentage)%")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.6)

                MascotImage(name: entry.mascot)
            }
            .padding()
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
        .supportedFamilies([.systemSmall])
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

private struct MascotImage: View {
    let name: String

    var body: some View {
#if canImport(UIKit)
        if let image = UIImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 4)
                .accessibilityHidden(true)
        } else {
            fallback
        }
#else
        fallback
#endif
    }

    private var fallback: some View {
        Image(systemName: "brain.head.profile")
            .font(.system(size: 40, weight: .medium))
            .foregroundColor(.white.opacity(0.85))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .accessibilityHidden(true)
    }
}
