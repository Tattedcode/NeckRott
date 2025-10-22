//
//  OnboardingSix.swift
//  ForwardNeckV1
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
    
    @State private var showCards = Array(repeating: false, count: 4)
    @State private var alertMessage = ""
    @State private var isPermissionGranted = false
    
    private let notificationFeatures = [
        (icon: "bell.fill", title: "brain health insights", description: "get updates about your brain health and screen usage"),
        (icon: "chart.bar.fill", title: "daily stats", description: "see how you're doing with your screen time goals"),
        (icon: "exclamationmark.triangle.fill", title: "excessive use alerts", description: "be notified when you're spending too much time on certain apps"),
        (icon: "hand.raised.fill", title: "intervention reminders", description: "gentle reminders to take breaks and stay mindful")
    ]
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) { // Reduced spacing
            // Mascot image - moved up to fill gap above
            Image(MascotAssetProvider.resolvedMascotName(for: "mascot1"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 240, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.top, -40) // Move image up to fill gap above
            
            // Title
            Text("Notifications")
                .font(.title.bold())
                .foregroundColor(Theme.primaryText)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("Allow us to remind you of your neck")
                .font(.subheadline)
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Notification feature cards in one container with rounded corners
            VStack(spacing: 0) { // Changed spacing to 0
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
            .background(Color.white.opacity(0.1)) // Background for the single container
            .clipShape(RoundedRectangle(cornerRadius: 12)) // Rounded corners for the single container
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
            // Trigger staggered animations for notification cards (4 cards * 0.08s = 0.32s + 0.4s duration = 0.72s total)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation {
                        showCards[i] = true
                    }
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
                    .foregroundColor(Theme.primaryText)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity) // Make all cards the same width
        .padding(12) // Padding for individual card content
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

