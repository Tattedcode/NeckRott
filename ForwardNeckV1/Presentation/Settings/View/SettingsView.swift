//
//  SettingsView.swift
//  ForwardNeckV1
//
//  Redesigned settings screen inspired by the provided mockups.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    header
                    screenTimeSection
                    widgetSection
                    supportSection
                    legalSection
                    socialSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showingWidgetSheet) {
            WidgetSetupSheet(
                isConfigured: viewModel.widgetConfigured,
                onDone: { viewModel.showingWidgetSheet = false },
                onToggleConfigured: viewModel.markWidgetConfigured
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        Text("settings")
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(Theme.primaryText)
    }

    private var screenTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("screen time goal")
            settingsCard {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 14) {
                        iconBadge(systemImage: "clock.fill", foreground: Color.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("daily screen time goal")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.primaryText)
                            Text("set a daily limit for healthy screen usage")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Theme.secondaryText)
                        }
                    }

                    Text(viewModel.screenTimeGoalLabel)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primaryText)

                    Slider(
                        value: $viewModel.screenTimeGoalHours,
                        in: viewModel.screenTimeRange,
                        step: viewModel.sliderStep
                    )
                    .tint(Color.orange)

                    HStack {
                        Text("1h")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondaryText)
                        Spacer()
                        Text("8h")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondaryText)
                    }
                }
            }
        }
    }

    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("widget")
            settingsCard {
                HStack(alignment: .center, spacing: 16) {
                    iconBadge(systemImage: "iphone.homebutton", foreground: Color.cyan)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.widgetIndicatorColor)
                                .frame(width: 10, height: 10)
                            Text(viewModel.widgetStatusHeadline)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Theme.primaryText)
                        }

                        Text(viewModel.widgetStatusDescription)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondaryText)
                    }

                    Spacer()

                    Button(action: { viewModel.presentWidgetSheet() }) {
                        Text(viewModel.widgetButtonTitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("support & feedback")
            listCard(items: viewModel.supportItems)
        }
    }

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("legal")
            listCard(items: viewModel.legalItems)
        }
    }

    private var socialSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionTitle("follow us")

            HStack(spacing: 24) {
                ForEach(viewModel.socialLinks) { social in
                    Button {
                        viewModel.handle(socialLink: social, openURL: openURL)
                    } label: {
                        Text(social.label)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.primaryText)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text(viewModel.versionLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Theme.secondaryText)
                .padding(.top, 8)
        }
        .padding(.bottom, 16)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(Theme.secondaryText)
            .textCase(.lowercase)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.08))
                    )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 20, x: 0, y: 14)
    }

    private func listCard(items: [SettingsViewModel.LinkItem]) -> some View {
        settingsCard {
            VStack(spacing: 12) {
                ForEach(items) { item in
                    Button {
                        viewModel.handle(link: item, openURL: openURL)
                    } label: {
                        HStack(spacing: 14) {
                            iconBadge(systemImage: item.icon, foreground: item.iconColor)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(Theme.primaryText)
                                if let subtitle = item.subtitle {
                                    Text(subtitle)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Theme.secondaryText)
                                }
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.secondaryText)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Theme.cardBackground.opacity(0.55))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.06))
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func iconBadge(systemImage: String, foreground: Color) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(foreground.opacity(0.18))
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(foreground)
            )
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
