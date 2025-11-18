//
//  OnboardingSix.swift
//  NeckRotV1
//
//  Sixth onboarding screen for notifications permission
//

import SwiftUI
import UserNotifications

struct OnboardingSix: View {
    @Binding var hasAlertBeenDismissed: Bool
    @Binding var triggerPermissionRequest: Bool
    let onPermissionGranted: (() -> Void)?
    let subtitle: String
    
    @State private var showCards = Array(repeating: false, count: 3)
    @State private var alertMessage = ""
    @State private var isPermissionGranted = false
    
    private let notificationFeatures = [
        (icon: "bell.fill", title: "Neck health insights", description: "Get updates about your neck health and exercises"),
        (icon: "chart.bar.fill", title: "Leaderboard stats", description: "See how you're doing against others around the world"),
        (icon: "exclamationmark.triangle.fill", title: "Daily Exercises", description: "Be notified when the best time is to work out your neck")
    ]
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) { // Reduced spacing
            // Mascot image - always use mascot1 during onboarding (ignore user preference)
            Image(MascotAssetProvider.resolvedMascotName(for: "mascot1", ignorePreference: true))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.top, -40) // Move image up to fill gap above
            
            // Title and cards grouped together with reduced spacing
            VStack(spacing: 8) {
                // Title
                Text("Allow us to remind you of your neck")
                    .font(.headline.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                // Notification feature cards with individual styling matching "Did you know" cards
                VStack(spacing: 12) {
                    ForEach(Array(notificationFeatures.enumerated()), id: \.offset) { index, feature in
                        NotificationFeatureCard(
                            icon: feature.icon,
                            title: feature.title,
                            description: feature.description
                        )
                        .opacity(showCards[index] ? 1 : 0)
                        .offset(y: showCards[index] ? 0 : 20)
                        .animation(.easeOut(duration: 0.4), value: showCards[index])
                    }
                }
            }
        }
        
        // Parent container that centers the grouped content vertically
        VStack(spacing: 0) {
            Spacer(minLength: 60) // Add space at the top
            content
                .padding(.horizontal, 24)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            // Show cards with 0.5 second delay between each (matching "Did you know" view)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showCards[i] = true
                    }
                    // Add haptic feedback for each card appearance
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            
            // Wait for the user to tap continue before requesting permission
        }
        .onChange(of: triggerPermissionRequest) { shouldTrigger in
            if shouldTrigger {
                triggerPermissionRequest = false
                requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        Log.info("OnboardingSix requesting notification authorization")

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                Log.info("OnboardingSix notifications already authorized: \(settings.authorizationStatus.rawValue)")
                DispatchQueue.main.async {
                    isPermissionGranted = true
                    hasAlertBeenDismissed = true
                    onPermissionGranted?()
                }
                return
            }

            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    if let error {
                        Log.error("OnboardingSix notification authorization failed: \(error.localizedDescription)")
                        alertMessage = error.localizedDescription
                        isPermissionGranted = false
                        hasAlertBeenDismissed = true
                        return
                    }

                    Log.info("OnboardingSix notification authorization granted=\(granted)")
                    isPermissionGranted = granted
                    hasAlertBeenDismissed = true
                    if granted {
                        onPermissionGranted?()
                    } else {
                        alertMessage = "Notifications are turned off. You can enable them later in Settings > Notifications."
                    }
                }
            }
        }
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
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity) // Make all cards the same width
        .padding(12) // Padding for individual card content
        .background(Color(red: 0.99, green: 0.96, blue: 0.90).opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
        )
    }
}

#Preview {
    OnboardingSix(
        hasAlertBeenDismissed: .constant(false),
        triggerPermissionRequest: .constant(false),
        onPermissionGranted: nil,
        subtitle: "We need permission to send you notifications"
    )
}

