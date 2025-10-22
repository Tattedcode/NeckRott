//
//  OnboardingContainer+Layout.swift
//  ForwardNeckV1
//
//  Layout building blocks for the onboarding container.
//

import SwiftUI

extension OnboardingContainer {
    var headerBar: some View {
        HStack {
            if viewModel.shouldShowBackButton {
                Button(action: { withAnimation(.easeInOut(duration: 0.3)) { viewModel.goBack() } }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Theme.primaryText)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
            } else {
                Spacer().frame(width: 44, height: 44)
            }

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<viewModel.screens.count, id: \.self) { index in
                    Circle()
                        .fill(index <= viewModel.currentScreen ? Color.blue : Color.blue.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()
            Spacer().frame(width: 44, height: 44)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    var scrollableContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.currentScreen == 0 {
                    Spacer().frame(height: 80)
                }

                currentScreenContent

                VStack(spacing: 8) {
                    if viewModel.currentScreen == 0 {
                        FirstScreenTypewriterView()
                    } else if !viewModel.screens[viewModel.currentScreen].title.isEmpty {
                        Text(viewModel.screens[viewModel.currentScreen].title)
                            .font(viewModel.currentScreen == 4 ? .title.bold() : .largeTitle.bold())
                            .foregroundColor(Theme.primaryText)
                            .multilineTextAlignment(.center)

                        if shouldShowSubtitle {
                            Text(viewModel.screens[viewModel.currentScreen].subtitle)
                                .font(.title2)
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                }

                if viewModel.currentScreen == 0 || viewModel.currentScreen == 1 {
                    Spacer().frame(height: 80)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    var footer: some View {
        VStack(spacing: 8) {
            navigationButtons
            if viewModel.currentScreen == 0 {
                legalText
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var shouldShowSubtitle: Bool {
        // Show subtitle for all screens except notifications permission screen
        viewModel.currentScreen != 5
    }
}
