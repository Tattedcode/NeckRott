//
//  OnboardingFlowModels.swift
//  NeckRotV1
//
//  Data models describing the onboarding sequence.
//

import Foundation

struct OnboardingScreen {
    let id: Int
    let title: String
    let subtitle: String
    let content: OnboardingContent
    let buttonText: String
}

enum OnboardingContent {
    case phoneMockup
    case videoDemo          // NEW
    case featureHighlights  // NEW
    case neckRotInfo
    case reasonSelection
    case ageSelection
    case screenTimeSelection
    case notificationsPermission
    case progressChart
    case rewards
    case reviews
    case mascotSelection   // NEW: Mascot selection screen
}

extension OnboardingScreen {
    static func makeDefaultSequence() -> [OnboardingScreen] {
        [
            OnboardingScreen(id: 0, title: "Stop Scrolling.", subtitle: "Save Your Neck.", content: .phoneMockup, buttonText: "continue"),
            OnboardingScreen(id: 1, title: "Check it out yourself", subtitle: "", content: .screenTimeSelection, buttonText: "continue"),
            OnboardingScreen(id: 2, title: "See Neckrot in Action", subtitle: "Watch how quick workouts help strengthen your neck", content: .videoDemo, buttonText: "continue"),
            OnboardingScreen(id: 3, title: "", subtitle: "", content: .featureHighlights, buttonText: "continue"),
            OnboardingScreen(id: 4, title: "", subtitle: "", content: .reasonSelection, buttonText: "continue"),
            OnboardingScreen(id: 5, title: "", subtitle: "", content: .ageSelection, buttonText: "continue"),
            OnboardingScreen(id: 6, title: "", subtitle: "", content: .neckRotInfo, buttonText: "continue"),
            OnboardingScreen(id: 7, title: "", subtitle: "", content: .notificationsPermission, buttonText: "continue"),
            OnboardingScreen(id: 8, title: "", subtitle: "", content: .reviews, buttonText: "continue"),
            OnboardingScreen(id: 9, title: "", subtitle: "", content: .mascotSelection, buttonText: "continue")
        ]
    }
}
