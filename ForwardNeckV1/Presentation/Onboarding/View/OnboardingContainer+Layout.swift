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
                Button(action: { 
                    // Add haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { 
                        viewModel.goBack() 
                    } 
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Theme.primaryText)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .opacity(0)
                        )
                }
                .buttonStyle(.plain)
                .scaleEffect(1.0)
                .onTapGesture {
                    // Add press animation
                    withAnimation(.easeInOut(duration: 0.1)) {
                        // Scale effect handled by button style
                    }
                }
            } else {
                Spacer().frame(width: 44, height: 44)
            }

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<viewModel.screens.count, id: \.self) { index in
                    Circle()
                        .fill(index <= viewModel.currentScreen ? Color.blue : Color.blue.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == viewModel.currentScreen ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentScreen)
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

                // Screen content with transition animation
                currentScreenContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                VStack(spacing: 8) {
                    if viewModel.currentScreen == 0 {
                        FirstScreenTypewriterView()
                    } else if !viewModel.screens[viewModel.currentScreen].title.isEmpty {
                        Text(viewModel.screens[viewModel.currentScreen].title)
                            .font(viewModel.currentScreen == 6 ? .title.bold() : .largeTitle.bold()) // Updated index
                            .foregroundColor(Theme.primaryText)
                            .multilineTextAlignment(.center)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))

                        if shouldShowSubtitle {
                            Text(viewModel.screens[viewModel.currentScreen].subtitle)
                                .font(.title2)
                                .foregroundColor(Theme.secondaryText)
                                .transition(.opacity.combined(with: .offset(y: 10)))
                        }
                    }
                }

                if viewModel.currentScreen == 0 || viewModel.currentScreen == 1 || viewModel.currentScreen == 2 {
                    Spacer().frame(height: 80)
                }
            }
            .padding(.horizontal, 24)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.currentScreen)
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
        // Show subtitle for all screens except notifications permission screen (now index 7)
        viewModel.currentScreen != 7
    }
}
