//
//  OnboardingContainer.swift
//  ForwardNeckV1
//
//  Container for managing multiple onboarding screens with navigation.
//

import SwiftUI

struct OnboardingContainer: View {
    @State private var currentScreen = 0
    @StateObject private var userStore = UserStore()
    @State private var triggerScreenTimePermission = false
    @State private var isScreenTimePermissionGranted = false
    @State private var triggerAgeValidation = false
    @State private var hasScreenTimeAlertBeenDismissed = false
    @State private var hasNotificationsAlertBeenDismissed = false
    @State private var hasReasonSelected = false // Track if user selected a reason
    @State private var hasScreenTimePermissionResponded = false // Track if user responded to permission
    @State private var selectedScreenTime = 0 // Track selected screen time (0-8 for 1-9+ hours)
    let onComplete: () -> Void
    
    private let onboardingScreens = [
        OnboardingScreen(
            id: 0,
            title: "stop scrolling.",
            subtitle: "save your neck.",
            content: .phoneMockup,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 1,
            title: "",
            subtitle: "",
            content: .reasonSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 2,
            title: "",
            subtitle: "",
            content: .ageSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 3,
            title: "",
            subtitle: "",
            content: .forwardNeckInfo,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 4,
            title: "how much time do you spend scrolling daily?",
            subtitle: "",
            content: .screenTimeSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 5,
            title: "",
            subtitle: "",
            content: .screenTimeMath,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 6,
            title: "",
            subtitle: "",
            content: .screenTimePermission,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 7,
            title: "",
            subtitle: "",
            content: .notificationsPermission,
            buttonText: "continue"
        )
    ]
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar and back button at the top - always visible
                HStack {
                    // Back button (only show if not first screen)
                    if currentScreen > 0 {
                        Button(action: {
                            // Simple, clean transition
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Invisible spacer to maintain layout
                        Spacer()
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    // Progress bar
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingScreens.count, id: \.self) { index in
                            Circle()
                                .fill(index <= currentScreen ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Invisible spacer to balance layout
                    Spacer()
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Main content area
                ScrollView {
                    VStack(spacing: 24) {
                        // Add top spacing for first screen to center content
                        if currentScreen == 0 {
                            Spacer()
                                .frame(height: 80)
                        }
                        
                        // Current screen content
                        currentScreenContent
                        
                        // Main title and subtitle for each screen
                        VStack(spacing: 8) {
                            if currentScreen == 0 {
                                // Typewriter animation for first screen
                                FirstScreenTypewriterView()
                            } else if !onboardingScreens[currentScreen].title.isEmpty {
                                // Regular text for other screens (only show if title is not empty)
                                Text(onboardingScreens[currentScreen].title)
                                    .font(.largeTitle.bold())
                                    .foregroundColor(.white)
                                
                                if (currentScreen != 4 || !hasScreenTimeAlertBeenDismissed) && (currentScreen != 5 || !hasNotificationsAlertBeenDismissed) {
                                    Text(onboardingScreens[currentScreen].subtitle)
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        
                        // Legal text (only on first screen)
                        if currentScreen == 0 {
                            legalText
                        }
                        
                        // Add bottom spacing for first and second screens to center content
                        if currentScreen == 0 || currentScreen == 1 {
                            Spacer()
                                .frame(height: 80)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Navigation buttons - always visible at bottom
                VStack(spacing: 8) {
                    navigationButtons
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .background(
                    // Add a subtle gradient overlay to ensure buttons are visible
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var buttonText: String {
        if currentScreen == 4 && hasScreenTimeAlertBeenDismissed && !isScreenTimePermissionGranted {
            return "Permission Required"
        }
        return onboardingScreens[currentScreen].buttonText
    }
    
    private var buttonColors: [Color] {
        // Check if button should be disabled
        if (currentScreen == 1 && !hasReasonSelected) || 
           (currentScreen == 6 && !hasScreenTimePermissionResponded) {
            return [Color.gray, Color.gray.opacity(0.8)]
        }
        
        if currentScreen == 6 && hasScreenTimeAlertBeenDismissed && !isScreenTimePermissionGranted {
            return [Color.red, Color.red.opacity(0.8)]
        }
        return [Color.blue, Color.blue.opacity(0.8)]
    }
    
    // MARK: - Subviews
    
    private var currentScreenContent: some View {
        Group {
            switch onboardingScreens[currentScreen].content {
            case .phoneMockup:
                PhoneMockupView()
            case .forwardNeckInfo:
                OnboardingThree()
            case .reasonSelection:
                OnboardingFour(hasReasonSelected: $hasReasonSelected)
            case .ageSelection:
                OnboardingSeven(
                    triggerValidation: $triggerAgeValidation,
                    onNameAndAgeSelected: { name, age in
                        userStore.saveUserName(name)
                        // Trigger navigation to next screen after validation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if currentScreen < onboardingScreens.count - 1 {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentScreen += 1
                                }
                            }
                        }
                    }
                )
            case .screenTimeSelection:
                OnboardingTwo(selectedScreenTime: $selectedScreenTime)
            case .screenTimeMath:
                OnboardingScreenTimeMath(selectedScreenTime: selectedScreenTime)
            case .screenTimePermission:
                OnboardingFive(
                    triggerPermissionRequest: $triggerScreenTimePermission,
                    isScreenTimePermissionGranted: $isScreenTimePermissionGranted,
                    hasAlertBeenDismissed: $hasScreenTimeAlertBeenDismissed,
                    hasScreenTimePermissionResponded: $hasScreenTimePermissionResponded,
                    subtitle: onboardingScreens[6].subtitle
                )
            case .notificationsPermission:
                OnboardingSix(
                    hasAlertBeenDismissed: $hasNotificationsAlertBeenDismissed,
                    subtitle: onboardingScreens[7].subtitle
                )
            case .progressChart:
                progressChartMockup
            case .rewards:
                rewardsMockup
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Next/Complete button
            Button(action: {
                // Check if we're on the age selection screen and validate input
                if currentScreen == 2 { // Age selection screen
                    // Trigger validation in the AgeSelectionView
                    triggerAgeValidation = true
                    return
                }
                
                // Handle screen time permission request
                if currentScreen == 6 { // Screen time permission screen
                    if !hasScreenTimeAlertBeenDismissed {
                        // Trigger the permission request in the view
                        triggerScreenTimePermission = true
                        return
                    } else if !isScreenTimePermissionGranted {
                        // Permission was denied, don't allow continuing
                        return
                    }
                    // If permission is granted, continue to next screen
                }
                
                if currentScreen < onboardingScreens.count - 1 {
                    // Simple, clean transition
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen += 1
                    }
                } else {
                    onComplete()
                }
            }) {
                Text(buttonText)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: buttonColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Mockup Views (Legacy - keeping only progress and rewards)
    
    private var progressChartMockup: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground)
                .frame(width: 200, height: 300)
            
            VStack(spacing: 16) {
                Text("Progress Tracking")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Simple chart representation
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(0..<7) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(width: 20, height: CGFloat.random(in: 20...100))
                        }
                    }
                    
                    Text("Weekly Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    private var rewardsMockup: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground)
                .frame(width: 200, height: 300)
            
            VStack(spacing: 16) {
                Text("Rewards")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("Earn points for healthy habits")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Legal Text
    
    private var legalText: some View {
        VStack(spacing: 8) {
            Text("by continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    // Handle terms action
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Button("Privacy Policy") {
                    // Handle privacy action
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// MARK: - Data Models

struct OnboardingScreen {
    let id: Int
    let title: String
    let subtitle: String
    let content: OnboardingContent
    let buttonText: String
}

enum OnboardingContent {
    case phoneMockup
    case forwardNeckInfo
    case reasonSelection
    case ageSelection
    case screenTimeSelection
    case screenTimeMath
    case screenTimePermission
    case notificationsPermission
    case progressChart
    case rewards
}

#Preview {
    OnboardingContainer(onComplete: {
        print("Onboarding completed")
    })
}