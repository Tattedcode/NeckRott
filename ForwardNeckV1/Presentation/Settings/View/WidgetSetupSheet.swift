//
//  WidgetSetupSheet.swift
//  NeckRotV1
//
//  Guided walkthrough to help users add the app widget to their home screen.
//

import SwiftUI
import UIKit
import WidgetKit

struct WidgetSetupSheet: View {
    let isConfigured: Bool
    let onDone: () -> Void
    let onToggleConfigured: () -> Void

    private let steps: [(title: String, body: String)] = [
        (
            "Long press your home screen",
            "Tap and hold on an empty area of your home screen until apps start wiggling"
        ),
        (
            "Tap the '+' button",
            "Look for the plus button in the top-left corner and tap it"
        ),
        (
            "Search for 'neckrot'",
            "Use the search bar at the top to find the NeckRot widgets"
        ),
        (
            "Select neck health widget",
            "Choose the widget size you like and tap Add Widget"
        ),
        (
            "Place the widget",
            "Position it where you want it and tap Done"
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
                Text("Widget Setup")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.primaryText)
                Text("Follow the quick guide to add the NeckRot widget")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.secondaryText)
            }

            Spacer()

            Button(action: {
                onToggleConfigured()
                onDone()
            }) {
                Text(isConfigured ? "Done" : "Mark Done")
                    .font(.system(size: 16, weight: .bold))
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

                    Text("Add Neck Health Widget")
                        .font(.system(size: 18, weight: .bold))
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
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Theme.primaryText)
                        Text(step.body)
                            .font(.system(size: 13))
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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Tip")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                Text("The widget updates throughout the day to reflect your latest neck health progress")
                    .font(.system(size: 13))
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
                .font(.system(size: 16, weight: .bold))
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
            // Render a preview of the widget with progress bar
            WidgetPreviewMockup()
        }
    }
}

// Mockup widget preview matching the actual widget design
// Shows mascot image with 100% progress bar, matching the real widget layout
private struct WidgetPreviewMockup: View {
    var body: some View {
        ZStack {
            // Widget background color matching NeckRotWidget
            Color(red: 0.99, green: 0.96, blue: 0.90)
            
            VStack(spacing: 8) {
                // Mascot image - use mascot4 for 100% progress (same as widget)
                // Respect user preference for female mascot if selected
                Image(MascotAssetProvider.resolvedMascotName(for: "mascot4"))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120) // Similar to widget's small size
                
                // Progress bar section - matching widget layout exactly
                VStack(spacing: 4) {
                    // Progress bar with 100% filled gradient
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Grey background track
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                            
                            // Full gradient progress bar (100%)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [.red, .orange, .green],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width, height: 8) // Full width for 100%
                        }
                    }
                    .frame(height: 8)
                    
                    // "Neck health" text below progress bar - matching widget styling
                    Text("Neck health")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.75))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .frame(width: 200, height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    WidgetSetupSheet(
        isConfigured: false,
        onDone: {},
        onToggleConfigured: {}
    )
}
