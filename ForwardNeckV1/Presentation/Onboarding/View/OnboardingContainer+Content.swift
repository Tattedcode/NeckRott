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
        case .mascotSelection:
            OnboardingMascotSelection(
                currentSelection: viewModel.binding(\.selectedMascotPrefix),
                hasSelectedMascot: viewModel.binding(\.hasSelectedMascot)
            ) { prefix in
                viewModel.updateMascotSelection(prefix: prefix)
            }

        case .phoneMockup:
            PhoneMockupView()

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

        case .screenTimeMath:
            OnboardingScreenTimeMath(selectedScreenTime: viewModel.selectedScreenTime)

        case .screenTimePermission:
            OnboardingFive(
                triggerPermissionRequest: viewModel.binding(\.triggerScreenTimePermission),
                isScreenTimePermissionGranted: viewModel.binding(\.isScreenTimePermissionGranted),
                hasAlertBeenDismissed: viewModel.binding(\.hasScreenTimeAlertBeenDismissed),
                hasScreenTimePermissionResponded: viewModel.binding(\.hasScreenTimePermissionResponded),
                subtitle: viewModel.screens[6].subtitle
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.markScreenTimePermissionGranted()
                    }
                }
            }

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
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var legalText: some View {
        VStack(spacing: 8) {
            Text("by continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 16) {
                Button("Terms of Service") {}
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                Text("•")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Button("Privacy Policy") {}
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    private func handleContinueTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.advance(onComplete: onComplete)
        }
    }
}
