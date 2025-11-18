//
//  OnboardingFlowViewModel.swift
//  NeckRotV1
//
//  Drives the multi-screen onboarding flow.
//

import Foundation
import SwiftUI

@MainActor
final class OnboardingFlowViewModel: ObservableObject {
    // MARK: - Published State

    @Published var currentScreen: Int
    @Published var triggerAgeValidation = false
    @Published var triggerNotificationPermission = false
    @Published var hasNotificationsAlertBeenDismissed = false
    @Published var hasReasonSelected = false
    @Published var triggerReasonValidation = false
    @Published var hasSelectedAge = false
    @Published var selectedScreenTime = 0
    @Published var selectedMascotType: MascotPreferenceManager.MascotType = .male

    // MARK: - Dependencies

    let screens: [OnboardingScreen]
    private let userStore: UserStore

    // MARK: - Init

    init(userStore: UserStore? = nil, initialScreen: Int = 0) {
        self.userStore = userStore ?? UserStore()
        self.screens = OnboardingScreen.makeDefaultSequence()
        self.currentScreen = initialScreen
        // Load saved mascot preference or default to male
        self.selectedMascotType = MascotPreferenceManager.selectedMascotType
    }

    // MARK: - Derived State

    var shouldShowBackButton: Bool { currentScreen > 0 }

    var buttonText: String {
        return screens[currentScreen].buttonText
    }

    var continueButtonColors: [Color] {
        switch currentScreen {
        case 4: // Reason selection
            if hasReasonSelected {
                return [Color.blue, Color.blue.opacity(0.8)]
            } else {
                return [Color.gray.opacity(0.5), Color.gray.opacity(0.4)]
            }
        case 5: // Age selection
            if hasSelectedAge {
                return [Color.blue, Color.blue.opacity(0.8)]
            } else {
                return [Color.gray.opacity(0.5), Color.gray.opacity(0.4)]
            }
        default:
            return [Color.blue, Color.blue.opacity(0.8)]
        }
    }

    // MARK: - Flow Control

    func goBack() {
        guard currentScreen > 0 else { return }
        currentScreen -= 1
    }

    func advance(onComplete: () -> Void) {
        guard handlePreconditions() else { return }

        if currentScreen < screens.count - 1 {
            currentScreen += 1
        } else {
            onComplete()
        }
    }

    func completeAgeSelection(_ ageLabel: String) {
        hasSelectedAge = true
        Log.info("OnboardingFlow selected age=\(ageLabel)")
        if currentScreen == 5 { // Age selection
            currentScreen += 1
        }
    }

    func markNotificationStepComplete() {
        hasNotificationsAlertBeenDismissed = true
        if currentScreen == 7 { // Notifications permission
            currentScreen += 1
        }
    }

    func binding<Value>(_ keyPath: ReferenceWritableKeyPath<OnboardingFlowViewModel, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }

    // MARK: - Helpers

    private func handlePreconditions() -> Bool {
        switch currentScreen {
        case 4: // Reason selection
            guard hasReasonSelected else {
                triggerReasonValidation = true
                Log.info("OnboardingFlow continue blocked – reason not selected")
                return false
            }
            return true

        case 5: // Age selection
            triggerAgeValidation = true
            Log.info("OnboardingFlow requesting age validation")
            return false

        case 1: // Screen time selection (moved from index 6 to index 1)
            // Screen time selection - no special preconditions needed
            return true

        case 7: // Notifications permission (was 5)
            if !hasNotificationsAlertBeenDismissed {
                triggerNotificationPermission = true
                Log.info("OnboardingFlow triggering notifications permission")
                return false
            }
            return true

        default:
            return true
        }
    }
}
