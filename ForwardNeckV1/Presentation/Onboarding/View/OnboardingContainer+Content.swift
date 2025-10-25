//
//  OnboardingContainer+Content.swift
//  ForwardNeckV1
//
//  Screen-specific content wiring.
//

import SwiftUI

extension OnboardingContainer {
    @ViewBuilder
    var currentScreenContent: some View {
        switch viewModel.screens[viewModel.currentScreen].content {
        case .phoneMockup:
            PhoneMockupView()

        case .videoDemo:
            OnboardingVideoDemo()

        case .featureHighlights:
            OnboardingFeatures()

        case .forwardNeckInfo:
            OnboardingThree()

        case .reasonSelection:
            OnboardingFour(
                hasReasonSelected: viewModel.binding(\.hasReasonSelected),
                triggerValidation: viewModel.binding(\.triggerReasonValidation)
            )

        case .ageSelection:
            OnboardingSeven(
                triggerValidation: viewModel.binding(\.triggerAgeValidation),
                hasSelectedAge: viewModel.binding(\.hasSelectedAge)
            ) { age in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.completeAgeSelection(age)
                    }
                }
            }

        case .screenTimeSelection:
            OnboardingTwo(selectedScreenTime: viewModel.binding(\.selectedScreenTime))

        case .notificationsPermission:
            OnboardingSix(
                hasAlertBeenDismissed: viewModel.binding(\.hasNotificationsAlertBeenDismissed),
                triggerPermissionRequest: viewModel.binding(\.triggerNotificationPermission),
                onPermissionGranted: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.markNotificationStepComplete()
                        }
                    }
                },
                subtitle: viewModel.screens[7].subtitle
            )

        case .progressChart:
            progressChartMockup

        case .rewards:
            rewardsMockup

        case .reviews:
            OnboardingReviewsView()
        }
    }

    var navigationButtons: some View {
        Button(action: handleContinueTapped) {
            Text(viewModel.buttonText)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: viewModel.continueButtonColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .scaleEffect(1.0)
        }
        .buttonStyle(.plain)
        .scaleEffect(1.0)
        .onTapGesture {
            // Add press animation
            withAnimation(.easeInOut(duration: 0.1)) {
                // Scale effect handled by button style
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.continueButtonColors)
    }

    @ViewBuilder
    var legalText: some View {
        VStack(spacing: 8) {
            Text("by continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.blue.opacity(0.8))

            HStack(spacing: 16) {
                Button("Terms of Service") {}
                    .font(.caption)
                    .foregroundColor(.blue)

                Text("•")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.8))

                Button("Privacy Policy") {}
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }

    private func handleContinueTapped() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.advance(onComplete: onComplete)
        }
    }
}
