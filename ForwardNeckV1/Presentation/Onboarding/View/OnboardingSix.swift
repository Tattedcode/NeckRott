//
//  OnboardingSix.swift
//  ForwardNeckV1
//
//  Sixth onboarding screen for notifications permission
//

import SwiftUI

struct OnboardingSix: View {
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
    OnboardingSix(
        hasAlertBeenDismissed: .constant(false),
        subtitle: "We need permission to send you notifications"
    )
}

