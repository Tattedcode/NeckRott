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
    @State private var showContent = true
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
            title: "how much time do you spend scrolling daily?",
            subtitle: "",
            content: .screenTimeSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 2,
            title: "",
            subtitle: "",
            content: .forwardNeckInfo,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 3,
            title: "",
            subtitle: "",
            content: .reasonSelection,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 4,
            title: "",
            subtitle: "",
            content: .screenTimePermission,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 5,
            title: "",
            subtitle: "",
            content: .notificationsPermission,
            buttonText: "continue"
        ),
        OnboardingScreen(
            id: 6,
            title: "",
            subtitle: "",
            content: .ageSelection,
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
                            // Hide content during transition
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showContent = false
                            }
                            
                            // Change screen after content is hidden
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentScreen -= 1
                                }
                                
                                // Show content after screen change
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showContent = true
                                    }
                                }
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
                        // Add top spacing for first and second screens to center content
                        if currentScreen == 0 || currentScreen == 1 {
                            Spacer()
                                .frame(height: 80)
                        }
                        
                        // Current screen content
                        if showContent {
                            currentScreenContent
                        }
                        
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
        if currentScreen == 4 && hasScreenTimeAlertBeenDismissed && !isScreenTimePermissionGranted {
            return [Color.red, Color.red.opacity(0.8)]
        }
        return [Color.blue, Color.blue.opacity(0.8)]
    }
    
    // MARK: - Subviews
    
    private var currentScreenContent: some View {
        Group {
            switch onboardingScreens[currentScreen].content {
            case .phoneMockup:
                phoneMockup
            case .forwardNeckInfo:
                forwardNeckInfoMockup
            case .reasonSelection:
                reasonSelectionMockup
            case .ageSelection:
                ageSelectionMockup
            case .screenTimeSelection:
                screenTimeSelectionMockup
            case .screenTimePermission:
                screenTimePermissionMockup
            case .notificationsPermission:
                notificationsPermissionMockup
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
                if currentScreen == 6 { // Age selection screen (now last)
                    // Trigger validation in the AgeSelectionView
                    triggerAgeValidation = true
                    return
                }
                
                // Handle screen time permission request
                if currentScreen == 4 { // Screen time permission screen
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
                    // Hide content during transition
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showContent = false
                    }
                    
                    // Change screen after content is hidden
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen += 1
                        }
                        
                        // Show content after screen change
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showContent = true
                            }
                        }
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
    
    // MARK: - Mockup Views
    
    private var phoneMockup: some View {
        // Mascot image instead of phone mockup
        Image("mascot1")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var forwardNeckInfoMockup: some View {
        ForwardNeckInfoView()
    }
    
    private var reasonSelectionMockup: some View {
        ReasonSelectionView()
    }
    
    private var ageSelectionMockup: some View {
        AgeSelectionView(triggerValidation: $triggerAgeValidation) { name, age in
            userStore.saveUserName(name)
            onComplete()
        }
    }
    
    private var screenTimeSelectionMockup: some View {
        ScreenTimeSelectionView()
    }
    
    private var screenTimePermissionMockup: some View {
        ScreenTimePermissionView(
            triggerPermissionRequest: $triggerScreenTimePermission,
            isScreenTimePermissionGranted: $isScreenTimePermissionGranted,
            hasAlertBeenDismissed: $hasScreenTimeAlertBeenDismissed,
            subtitle: onboardingScreens[4].subtitle
        )
    }
    
    private var notificationsPermissionMockup: some View {
        NotificationsPermissionView(
            hasAlertBeenDismissed: $hasNotificationsAlertBeenDismissed,
            subtitle: onboardingScreens[5].subtitle
        )
    }
    
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
    case screenTimePermission
    case notificationsPermission
    case progressChart
    case rewards
}

// MARK: - First Screen Typewriter View

struct FirstScreenTypewriterView: View {
    @State private var showSubtitle = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Title with typewriter animation
            TypewriterTextView(
                text: "Welcome To Neckrot",
                onComplete: {
                    // Start showing subtitle after title completes
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSubtitle = true
                    }
                }
            )
            .font(.largeTitle.bold())
            .foregroundColor(.white)
            
            // Subtitle that appears after title completes
            if showSubtitle {
                TypewriterTextView(
                    text: "save your neck",
                    onComplete: {
                        // Animation complete
                    }
                )
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
    }
}

// MARK: - Typewriter Text View

struct TypewriterTextView: View {
    let text: String
    let onComplete: () -> Void
    
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    private func startTyping() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1
                
                // Haptic feedback for each character
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            } else {
                timer?.invalidate()
                onComplete()
            }
        }
    }
}

// MARK: - Forward Neck Info View

struct ForwardNeckInfoView: View {
    @State private var showCards = Array(repeating: false, count: 4)
    @State private var showMotivationalMessage = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // "Did you know?" title
            Text("Did you know?")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Information cards
            VStack(spacing: 12) {
                    InfoCard(
                        icon: "hourglass",
                        text: "the average person spends over 4 hours a day on their phone"
                    )
                    .opacity(showCards[0] ? 1 : 0)
                    .offset(y: showCards[0] ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showCards[0])
                    
                    InfoCard(
                        icon: "iphone",
                        text: "most of us check our phones 58 times per day without realizing"
                    )
                    .opacity(showCards[1] ? 1 : 0)
                    .offset(y: showCards[1] ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showCards[1])
                    
                    InfoCard(
                        icon: "mascot1",
                        text: "too much screen time messes with your memory, focus, and sleep"
                    )
                    .opacity(showCards[2] ? 1 : 0)
                    .offset(y: showCards[2] ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: showCards[2])
                    
                    InfoCard(
                        icon: "eye",
                        text: "7 out of 10 people get tired, dry eyes from staring at screens"
                    )
                    .opacity(showCards[3] ? 1 : 0)
                    .offset(y: showCards[3] ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.8), value: showCards[3])
                }
                
                // Motivational message
                Text("we're here to help you be more mindful of these habits")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .opacity(showMotivationalMessage ? 1 : 0)
                    .offset(y: showMotivationalMessage ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(1.0), value: showMotivationalMessage)
        }
        .onAppear {
            // Trigger staggered animations for cards
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    withAnimation {
                        showCards[i] = true
                    }
                }
            }
            
            // Trigger motivational message animation after all cards
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showMotivationalMessage = true
                }
            }
        }
    }
}

// MARK: - Info Card Component

struct InfoCard: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Check if it's a system icon or asset image
            if icon.hasPrefix("mascot") {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Reason Selection View

struct ReasonSelectionView: View {
    @State private var selectedReasons: Set<String> = []
    @State private var showCards = Array(repeating: false, count: 6)
    
    private let reasons = [
        "fix forward neck",
        "reduce mindless scrolling", 
        "sleep better",
        "be more confident",
        "be more productive",
        "just curious"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title underneath image
            Text("you're here for a reason")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Reason options with animation
            VStack(spacing: 8) {
                ForEach(Array(reasons.enumerated()), id: \.element) { index, reason in
                    ReasonOption(
                        text: reason,
                        isSelected: selectedReasons.contains(reason),
                        onTap: {
                            if selectedReasons.contains(reason) {
                                selectedReasons.remove(reason)
                            } else {
                                selectedReasons.insert(reason)
                            }
                        }
                    )
                    .opacity(showCards[index] ? 1 : 0)
                    .offset(y: showCards[index] ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: showCards[index])
                }
            }
        }
        .onAppear {
            // Trigger staggered animations for cards over 0.5 seconds faster (6 cards * 0.08s = 0.48s + 0.4s duration = 0.88s total)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation {
                        showCards[i] = true
                    }
                }
            }
        }
    }
}

// MARK: - Reason Option Component

struct ReasonOption: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Age Selection View

struct AgeSelectionView: View {
    @Binding var triggerValidation: Bool
    @State private var selectedAge: String? = nil
    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var shakeNameField = false
    @State private var shakeAgeField = false
    let onNameAndAgeSelected: (String, String) -> Void
    
    private let ageOptions = ["18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Name input field
            VStack(alignment: .leading, spacing: 8) {
                Text("what's your name?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("enter your name", text: $name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
                    .foregroundColor(.white)
                    .offset(x: shakeNameField ? -10 : 0)
                    .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shakeNameField)
            }
            
            // Age selection
            VStack(alignment: .leading, spacing: 8) {
                Text("what's your age?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    ForEach(ageOptions, id: \.self) { age in
                        AgeOption(
                            text: age,
                            isSelected: selectedAge == age,
                            onTap: {
                                selectedAge = age
                            }
                        )
                    }
                }
                .offset(x: shakeAgeField ? -10 : 0)
                .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shakeAgeField)
            }
        }
        .onChange(of: triggerValidation) { shouldValidate in
            if shouldValidate {
                validateInput()
                triggerValidation = false
            }
        }
        .onChange(of: selectedAge) { _ in
            // When age is selected, check if we can proceed
            if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedAge != nil {
                onNameAndAgeSelected(name.trimmingCharacters(in: .whitespacesAndNewlines), selectedAge ?? "")
            }
        }
        .alert("Missing Information", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func validateInput() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter your name to continue."
            triggerNameFieldShake()
            showingAlert = true
        } else if selectedAge == nil {
            alertMessage = "Please select your age to continue."
            triggerAgeFieldShake()
            showingAlert = true
        }
    }
    
    private func triggerNameFieldShake() {
        withAnimation {
            shakeNameField = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeNameField = false
        }
    }
    
    private func triggerAgeFieldShake() {
        withAnimation {
            shakeAgeField = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeAgeField = false
        }
    }
}

// MARK: - Age Option Component

struct AgeOption: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Screen Time Selection View

struct ScreenTimeSelectionView: View {
    @State private var screenTimeHours: Double = 6.0
    
    private var screenTimeText: String {
        if screenTimeHours >= 12 {
            return "12h+"
        } else {
            return "\(Int(screenTimeHours)) hours"
        }
    }
    
    private var warningMessage: String? {
        if screenTimeHours >= 6 {
            return "this is a significant percentage of your life"
        }
        return nil
    }
    
    private var mascotImage: String {
        switch Int(screenTimeHours) {
        case 0...2:
            return "mascot4"
        case 3...5:
            return "mascot3"
        case 6...8:
            return "mascot2"
        case 9...11:
            return "mascot1"
        default:
            return "mascot1"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image(mascotImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.3), value: mascotImage)
            
            // Screen time display
            Text(screenTimeText)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                
                // Slider
                VStack(spacing: 8) {
                    // Slider labels
                    HStack {
                        Text("0h")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("12h+")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Custom slider
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Track background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.3))
                                .frame(height: 8)
                            
                            // Progress track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * CGFloat(screenTimeHours / 12.0), height: 8)
                            
                            // Slider thumb
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                                .shadow(radius: 2)
                                .offset(x: (geometry.size.width - 24) * CGFloat(screenTimeHours / 12.0))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let progress = max(0, min(1, value.location.x / geometry.size.width))
                                            screenTimeHours = progress * 12.0
                                        }
                                )
                        }
                    }
                    .frame(height: 24)
                }
                
            // Warning message
            if let warning = warningMessage {
                Text(warning)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Screen Time Permission View

struct ScreenTimePermissionView: View {
    @Binding var triggerPermissionRequest: Bool
    @Binding var isScreenTimePermissionGranted: Bool
    @Binding var hasAlertBeenDismissed: Bool
    let subtitle: String
    
    @State private var showCards = Array(repeating: false, count: 4)
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let permissionFeatures = [
        (icon: "chart.bar.fill", title: "track usage", description: "see how much time you spend on different apps"),
        (icon: "exclamationmark.triangle.fill", title: "monitor screen habits", description: "highlight apps that affect your brain"),
        (icon: "brain.head.profile", title: "visualize impact", description: "see how screen time affects your brain health"),
        (icon: "lock.fill", title: "private & secure", description: "your data never leaves your device")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Permission feature cards with staggered animation
            VStack(spacing: 12) {
                ForEach(Array(permissionFeatures.enumerated()), id: \.offset) { index, feature in
                    PermissionFeatureCard(
                        icon: feature.icon,
                        title: feature.title,
                        description: feature.description
                    )
                    .opacity(showCards[index] ? 1 : 0)
                    .offset(y: showCards[index] ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: showCards[index])
                }
            }
            
            // Permission status text
            if hasAlertBeenDismissed {
                Text(isScreenTimePermissionGranted ? "✅ Permission granted! You can now track your screen time." : "❌ Permission required. The app needs screen time access to function properly.")
                    .font(.subheadline)
                    .foregroundColor(isScreenTimePermissionGranted ? .green : .red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            // Trigger staggered animations for permission cards (4 cards * 0.08s = 0.32s + 0.4s duration = 0.72s total)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation {
                        showCards[i] = true
                    }
                }
            }
            
            // Show alert after all cards have finished animating (0.72s + small buffer)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if !isScreenTimePermissionGranted {
                    requestScreenTimePermission()
                }
            }
        }
        .onChange(of: triggerPermissionRequest) { shouldTrigger in
            if shouldTrigger {
                requestScreenTimePermission()
                triggerPermissionRequest = false
            }
        }
        .alert("Screen Time Access Required", isPresented: $showingAlert) {
            Button("Don't Allow") {
                isScreenTimePermissionGranted = false
                hasAlertBeenDismissed = true
            }
            Button("Allow") {
                isScreenTimePermissionGranted = true
                hasAlertBeenDismissed = true
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func requestScreenTimePermission() {
        alertMessage = "Neckrot needs access to your screen time data to function. You can change this setting later in your device settings."
        showingAlert = true
    }
}

// MARK: - Permission Feature Card Component

struct PermissionFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Notifications Permission View

struct NotificationsPermissionView: View {
    @Binding var hasAlertBeenDismissed: Bool
    let subtitle: String
    
    @State private var showCards = Array(repeating: false, count: 4)
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isPermissionGranted = false
    
    private let notificationFeatures = [
        (icon: "bell.fill", title: "brain health insights", description: "get updates about your brain health and screen usage"),
        (icon: "chart.bar.fill", title: "daily stats", description: "see how you're doing with your screen time goals"),
        (icon: "exclamationmark.triangle.fill", title: "excessive use alerts", description: "be notified when you're spending too much time on certain apps"),
        (icon: "hand.raised.fill", title: "intervention reminders", description: "gentle reminders to take breaks and stay mindful")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Notification feature cards with staggered animation
            VStack(spacing: 12) {
                ForEach(Array(notificationFeatures.enumerated()), id: \.offset) { index, feature in
                    NotificationFeatureCard(
                        icon: feature.icon,
                        title: feature.title,
                        description: feature.description
                    )
                    .opacity(showCards[index] ? 1 : 0)
                    .offset(y: showCards[index] ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: showCards[index])
                }
            }
        }
        .onAppear {
            // Trigger staggered animations for notification cards (4 cards * 0.08s = 0.32s + 0.4s duration = 0.72s total)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation {
                        showCards[i] = true
                    }
                }
            }
            
            // Show alert after all cards have finished animating (0.72s + small buffer)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if !isPermissionGranted {
                    requestNotificationPermission()
                }
            }
        }
        .alert("Notifications Required", isPresented: $showingAlert) {
            Button("Don't Allow") {
                hasAlertBeenDismissed = true
            }
            Button("Allow") {
                requestNotificationPermission()
                hasAlertBeenDismissed = true
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func requestNotificationPermission() {
        alertMessage = "Neckrot needs to send you notifications to help you stay on track with your screen time goals and brain health. You can change this setting later in your device settings."
        showingAlert = true
    }
}

// MARK: - Notification Feature Card

struct NotificationFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    OnboardingContainer(onComplete: {
        print("Onboarding completed")
    })
}