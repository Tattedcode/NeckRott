//
//  WidgetSetupSheet.swift
//  ForwardNeckV1
//
//  Guided walkthrough to help users add the app widget to their home screen.
//

import SwiftUI
import UIKit

struct WidgetSetupSheet: View {
    let isConfigured: Bool
    let onDone: () -> Void
    let onToggleConfigured: () -> Void

    private let steps: [(title: String, body: String)] = [
        (
            "long press your home screen",
            "tap and hold on an empty area of your home screen until apps start wiggling"
        ),
        (
            "tap the '+' button",
            "look for the plus button in the top-left corner and tap it"
        ),
        (
            "search for 'forwardneck'",
            "use the search bar at the top to find the ForwardNeck widgets"
        ),
        (
            "select brain health widget",
            "choose the widget size you like and tap Add Widget"
        ),
        (
            "place the widget",
            "position it where you want it and tap Done"
        )
    ]

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    header
                    previewImage
                    stepList
                    tipCard
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("widget setup")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.primaryText)
                Text("follow the quick guide to add the ForwardNeck widget")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.secondaryText)
            }

            Spacer()

            Button(action: {
                onToggleConfigured()
                onDone()
            }) {
                Text(isConfigured ? "done" : "mark done")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.cyan)
            }
            .buttonStyle(.plain)
        }
    }

    private var previewImage: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Theme.cardBackground.opacity(0.6))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.08))
            )
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .overlay(
                VStack(spacing: 16) {
                    WidgetPreviewImage()

                    Text("add brain health widget")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primaryText)
                }
                .padding()
            )
    }

    private var stepList: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 16) {
                    stepBadge(number: index + 1)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(step.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.primaryText)
                        Text(step.body)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.secondaryText)
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.08))
                )
        )
    }

    private var tipCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("tip")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.yellow)
                Text("the widget updates throughout the day to reflect your latest neck health progress")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Theme.cardBackground.opacity(0.7))
        )
    }

    private func stepBadge(number: Int) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.35))
                .frame(width: 34, height: 34)
            Text("\(number)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color.blue)
        }
    }
}

private struct WidgetPreviewImage: View {
    var body: some View {
        if let image = UIImage(named: "widget-preview") {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 280)
                .shadow(radius: 8)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.cardBackground.opacity(0.4))
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white.opacity(0.75))
            }
            .frame(width: 240, height: 160)
        }
    }
}

#Preview {
    WidgetSetupSheet(
        isConfigured: false,
        onDone: {},
        onToggleConfigured: {}
    )
}
