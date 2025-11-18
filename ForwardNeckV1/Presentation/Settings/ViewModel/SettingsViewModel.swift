//
//  SettingsViewModel.swift
//  NeckRotV1
//
//  Lightweight view model powering the redesigned Settings screen.
//

import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    struct LinkItem: Identifiable {
        let id = UUID()
        let icon: String
        let iconColor: Color
        let title: String
        let subtitle: String?
        let url: URL?
    }

    struct SocialLink: Identifiable {
        let id = UUID()
        let label: String
        let url: URL?
    }

    @Published var screenTimeGoalHours: Double {
        didSet { storeScreenTimeGoal() }
    }

    @Published var widgetConfigured: Bool {
        didSet { storeWidgetConfigured() }
    }

    @Published var showingWidgetSheet: Bool = false
    @Published var isResetting = false
    @Published var resetCompleted = false

    let screenTimeRange: ClosedRange<Double> = 1...8
    let sliderStep: Double = 1

    let supportItems: [LinkItem]
    let legalItems: [LinkItem]
    let socialLinks: [SocialLink]

    private let defaults: UserDefaults
    private let screenTimeGoalKey = "settings.screenTimeGoalHours"
    private let widgetConfiguredKey = "settings.widgetConfigured"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedGoal = defaults.double(forKey: screenTimeGoalKey)
        screenTimeGoalHours = storedGoal == 0 ? 7 : storedGoal
        widgetConfigured = defaults.bool(forKey: widgetConfiguredKey)

        supportItems = [
            LinkItem(
                icon: "questionmark.circle.fill",
                iconColor: Color(red: 0.31, green: 0.53, blue: 0.96),
                title: "Help & support",
                subtitle: nil,
                url: URL(string: "https://neckrot.app/support")
            ),
            LinkItem(
                icon: "lightbulb.fill",
                iconColor: Color(red: 0.43, green: 0.46, blue: 0.98),
                title: "Feature requests",
                subtitle: nil,
                url: URL(string: "https://neckrot.app/feedback")
            ),
            LinkItem(
                icon: "star.fill",
                iconColor: Color(red: 0.98, green: 0.78, blue: 0.2),
                title: "Leave a review",
                subtitle: nil,
                url: URL(string: "https://apps.apple.com/app/id0000000000?action=write-review")
            ),
            LinkItem(
                icon: "envelope.fill",
                iconColor: Color(red: 0.24, green: 0.52, blue: 0.96),
                title: "Contact us",
                subtitle: nil,
                url: URL(string: "mailto:support@neckrot.app")
            )
        ]

        legalItems = [
            LinkItem(
                icon: "hand.raised.fill",
                iconColor: Color(red: 0.47, green: 0.38, blue: 0.93),
                title: "Privacy policy",
                subtitle: nil,
                url: URL(string: "https://neckrot.app/privacy")
            ),
            LinkItem(
                icon: "doc.text.fill",
                iconColor: Color(red: 0.33, green: 0.52, blue: 0.94),
                title: "Terms of service",
                subtitle: nil,
                url: URL(string: "https://neckrot.app/terms")
            )
        ]

        socialLinks = [
            SocialLink(label: "X", url: URL(string: "https://x.com/neckrot")),
            SocialLink(label: "Instagram", url: URL(string: "https://instagram.com/neckrot")),
            SocialLink(label: "TikTok", url: URL(string: "https://www.tiktok.com/@neckrot"))
        ]
    }

    var screenTimeGoalLabel: String {
        let hours = Int(screenTimeGoalHours)
        return "\(hours) hour" + (hours == 1 ? "" : "s")
    }

    var widgetStatusHeadline: String {
        widgetConfigured ? "Widget ready" : "Widget not set up"
    }

    var widgetStatusDescription: String {
        widgetConfigured
            ? "Keep the widget on your home screen for quick neck health check"
            : "Add to home screen for quick neck health check"
    }

    var widgetButtonTitle: String {
        widgetConfigured ? "Manage" : "Set up"
    }

    var widgetIndicatorColor: Color {
        widgetConfigured ? Color(red: 0.33, green: 0.78, blue: 0.45) : Color(red: 0.94, green: 0.31, blue: 0.29)
    }

    var versionLabel: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "neckrot version \(version) (\(build))"
    }

    func markWidgetConfigured() {
        widgetConfigured.toggle()
    }

    func presentWidgetSheet() {
        showingWidgetSheet = true
    }

    func handle(link: LinkItem, openURL: OpenURLAction) {
        guard let url = link.url else { return }
        openURL(url)
    }

    func handle(socialLink: SocialLink, openURL: OpenURLAction) {
        guard let url = socialLink.url else { return }
        openURL(url)
    }

    func resetAppData() {
        guard !isResetting else { return }
        isResetting = true
        Task {
            await AppResetService.shared.resetAll()
            await MainActor.run {
                self.isResetting = false
                self.resetCompleted = true
            }
        }
    }

    func acknowledgeResetCompletion() {
        resetCompleted = false
    }

    private func storeScreenTimeGoal() {
        defaults.set(screenTimeGoalHours, forKey: screenTimeGoalKey)
    }

    private func storeWidgetConfigured() {
        defaults.set(widgetConfigured, forKey: widgetConfiguredKey)
    }
}
