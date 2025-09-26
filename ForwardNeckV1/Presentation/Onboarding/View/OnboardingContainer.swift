//
//  OnboardingContainer.swift
//  ForwardNeckV1
//
//  Container for managing multiple onboarding screens with navigation.
//

import SwiftUI

struct OnboardingContainer: View {
    @State private var currentScreen: Int
    @StateObject private var userStore = UserStore()
    @State private var triggerScreenTimePermission = false
    @State private var isScreenTimePermissionGranted = false
    @State private var triggerAgeValidation = false
    @State private var triggerNotificationPermission = false
    @State private var hasScreenTimeAlertBeenDismissed = false
    @State private var hasNotificationsAlertBeenDismissed = false
    @State private var hasSelectedMascot = false
    @State private var selectedMascotPrefix: String = MascotThemeState.currentPrefix()
    @State private var hasReasonSelected = false // Track if user selected a reason
    @State private var triggerReasonValidation = false // Fire when user taps continue without a reason selected
    @State private var hasSelectedAge = false // Track if an age has been selected
    @State private var hasScreenTimePermissionResponded = false // Track if user responded to permission
    @State private var selectedScreenTime = 0 // Track selected screen time (0-8 for 1-9+ hours)
    let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
#if targetEnvironment(simulator)
        _currentScreen = State(initialValue: 0)
#else
        _currentScreen = State(initialValue: 0)
#endif
    }
    
    private let onboardingScreens = [
        OnboardingScreen(
            id: 0,
            title: "Stop Scrolling.",
            subtitle: "Save Your Neck.",
            content: .phoneMockup,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 1,
            title: "Choose your mascot",
            subtitle: "Pick the buddy who will cheer you on",
            content: .mascotSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 2,
            title: "",
            subtitle: "",
            content: .reasonSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 3,
            title: "",
            subtitle: "",
            content: .ageSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 4,
            title: "",
            subtitle: "",
            content: .forwardNeckInfo,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 5,
            title: "How much time do you spend scrolling daily?",
            subtitle: "",
            content: .screenTimeSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 6,
            title: "",
            subtitle: "",
            content: .screenTimeMath,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 7,
            title: "",
            subtitle: "",
            content: .screenTimePermission,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 8,
            title: "",
            subtitle: "",
            content: .notificationsPermission,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 9,
            title: "",
            subtitle: "",
            content: .reviews,
            buttonText: "continue"
        ),
    ]
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar and back button at the top - always visible
                HStack {
                    // Back button (only show if not first screen)
                    if shouldShowBackButton {
                        Button(action: {
                            // Safety check to prevent going below 0
                            guard currentScreen > 0 else { return }
                            
                            // Add haptic feedback for back button
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            
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
                        .disabled(currentScreen <= 0) // Additional safety check
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
                                    .font(currentScreen == 4 ? .title.bold() : .largeTitle.bold()) // Smaller font for screen time selection
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center) // Center align the text
                                
                                if (currentScreen != 4 || !hasScreenTimeAlertBeenDismissed) && (currentScreen != 5 || !hasNotificationsAlertBeenDismissed) {
                                    Text(onboardingScreens[currentScreen].subtitle)
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
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
                    
                    // Legal text (only on first screen)
                    if currentScreen == 0 {
                        legalText
                    }
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
    
    private var shouldShowBackButton: Bool {
        return currentScreen > 0
    }
    
    private var buttonText: String {
        if currentScreen == 6 && hasScreenTimeAlertBeenDismissed && !isScreenTimePermissionGranted {
            return "Permission Required"
        }
        return onboardingScreens[currentScreen].buttonText
    }
    
    private var buttonColors: [Color] {
        // Check if button should be disabled
        if currentScreen == 1 {
            return [Color.blue, Color.blue.opacity(hasSelectedMascot ? 0.8 : 0.3)]
        }
        if currentScreen == 2 {
            return [Color.blue, Color.blue.opacity(hasReasonSelected ? 0.8 : 0.3)]
        }
        if currentScreen == 3 {
            return [Color.blue, Color.blue.opacity(hasSelectedAge ? 0.8 : 0.3)]
        }

        return [Color.blue, Color.blue.opacity(0.8)]
    }
    
    // MARK: - Subviews
    
    private var currentScreenContent: some View {
        Group {
            switch onboardingScreens[currentScreen].content {
            case .mascotSelection:
                OnboardingMascotSelection(
                    currentSelection: $selectedMascotPrefix,
                    hasSelectedMascot: $hasSelectedMascot,
                    onSelectionChanged: { prefix in
                        selectedMascotPrefix = prefix
                        hasSelectedMascot = true
                        Log.info("OnboardingContainer updated mascot prefix -> \(prefix.isEmpty ? "default" : prefix)")
                    }
                )
            case .phoneMockup:
                PhoneMockupView()
            case .forwardNeckInfo:
                OnboardingThree()
            case .reasonSelection:
                OnboardingFour(
                    hasReasonSelected: $hasReasonSelected,
                    triggerValidation: $triggerReasonValidation
                )
            case .ageSelection:
                OnboardingSeven(
                    triggerValidation: $triggerAgeValidation,
                    hasSelectedAge: $hasSelectedAge,
                    onAgeSelected: { age in
                        hasSelectedAge = true
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
                    subtitle: onboardingScreens[6].subtitle,
                    onPermissionGranted: {
                        // Automatically proceed to next screen when permission is granted
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen += 1
                            }
                        }
                    }
                )
            case .notificationsPermission:
                OnboardingSix(
                    hasAlertBeenDismissed: $hasNotificationsAlertBeenDismissed,
                    triggerPermissionRequest: $triggerNotificationPermission,
                    onPermissionGranted: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentScreen += 1
                            }
                        }
                    },
                    subtitle: onboardingScreens[7].subtitle
                )
            case .progressChart:
                progressChartMockup
            case .rewards:
                rewardsMockup
            case .reviews:
                OnboardingReviewsView()
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Next/Complete button
            Button(action: {
                // Add haptic feedback for continue button
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                if currentScreen == 1 {
                    guard hasSelectedMascot else {
                        Log.info("OnboardingContainer mascot not picked yet")
                        return
                    }
                    userStore.saveMascotPrefix(selectedMascotPrefix)
                }

                if currentScreen == 2 {
                    guard hasReasonSelected else {
                        Log.info("OnboardingContainer detected missing reason selection, triggering shake")
                        triggerReasonValidation = true
                        return
                    }
                }

                // Check if we're on the age selection screen and validate input
                if currentScreen == 3 { // Age selection screen
                    // Trigger validation in the AgeSelectionView
                    triggerAgeValidation = true
                    return
                }
                
                // Handle screen time permission request
                if currentScreen == 7 { // Screen time permission screen
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
                
                // Handle notification permission request
                if currentScreen == 8 { // Notification permission screen
                    if !hasNotificationsAlertBeenDismissed {
                        // Trigger the permission request in the view
                        triggerNotificationPermission = true
                        return
                    }
                    // If permission is granted or denied, continue to next screen
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
    case mascotSelection
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
    case reviews
}

#Preview {
    OnboardingContainer(onComplete: {
        print("Onboarding completed")
    })
}
