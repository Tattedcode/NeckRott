//
//  OnboardingFive.swift
//  ForwardNeckV1
//
//  Fifth onboarding screen for screen time permission
//

import SwiftUI

struct OnboardingFive: View {
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

#Preview {
    OnboardingFive(
        triggerPermissionRequest: .constant(false),
        isScreenTimePermissionGranted: .constant(false),
        hasAlertBeenDismissed: .constant(false),
        subtitle: "We need permission to track your screen time"
    )
}

