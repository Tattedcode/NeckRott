//
//  OnboardingFive.swift
//  ForwardNeckV1
//
//  Fifth onboarding screen for screen time permission
//

import SwiftUI
import FamilyControls

struct OnboardingFive: View {
    @Binding var triggerPermissionRequest: Bool
    @Binding var isScreenTimePermissionGranted: Bool
    @Binding var hasAlertBeenDismissed: Bool
    @Binding var hasScreenTimePermissionResponded: Bool
    let subtitle: String
    let onPermissionGranted: (() -> Void)? // Callback for when permission is granted
    
    @State private var showCards = Array(repeating: false, count: 4)
    @State private var showingRetryAlert = false
    @State private var showingPrePrompt = false
    @State private var alertMessage = ""
    
    private let permissionFeatures = [
        (icon: "chart.bar.fill", title: "track usage", description: "see how much time you spend on different apps"),
        (icon: "exclamationmark.triangle.fill", title: "monitor screen habits", description: "highlight apps that affect your brain"),
        (icon: "brain.head.profile", title: "visualize impact", description: "see how screen time affects your brain health"),
        (icon: "lock.fill", title: "private & secure", description: "your data never leaves your device")
    ]
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Mascot image - moved up to fill gap above
            Image(MascotAssetProvider.resolvedMascotName(for: "mascot1"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.top, -40) // Move image up to fill gap above
            
            // Title
            Text("Screen Time Access")
                .font(.title.bold())
                .foregroundColor(Theme.primaryText)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("Neckrott needs access to your screen time data to function")
                .font(.subheadline)
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Permission feature cards in one container with rounded corners
            VStack(spacing: 0) {
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
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
            // Trigger staggered animations for permission cards (4 cards * 0.08s = 0.32s + 0.4s duration = 0.72s total)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation {
                        showCards[i] = true
                    }
                }
            }
        }
        .onChange(of: triggerPermissionRequest) { shouldTrigger in
            if shouldTrigger {
                triggerPermissionRequest = false
                showingPrePrompt = true
            }
        }
        .alert("Screen Time Access", isPresented: $showingPrePrompt) {
            Button("Don't Allow", role: .cancel) {
                Log.info("OnboardingFive pre-prompt declined")
                Task { await handleAuthorizationStatus(.denied, error: nil) }
            }

            Button("Allow") {
                Log.info("OnboardingFive pre-prompt accepted")
                showingPrePrompt = false
                requestScreenTimePermission()
            }
        } message: {
            Text("Neckrot needs Screen Time access so we can track your progress. You can change this later in Settings.")
        }
        .alert("Permission Required", isPresented: $showingRetryAlert) {
            Button("Try Again") {
                showingRetryAlert = false
                showingPrePrompt = true
            }
        } message: {
            Text("We need access for the app to work. Please grant screen time permission to continue.")
        }
    }
    
    private func requestScreenTimePermission() {
        Log.info("OnboardingFive starting Screen Time authorization flow")

        Task {
            let statusBeforeRequest = AuthorizationCenter.shared.authorizationStatus
            if statusBeforeRequest == .approved {
                Log.info("OnboardingFive detected existing Screen Time approval")
                await handleAuthorizationStatus(.approved, error: nil)
                return
            }

            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let updatedStatus = AuthorizationCenter.shared.authorizationStatus
                Log.info("OnboardingFive authorization completed with status=\(updatedStatus.rawValue)")
                await handleAuthorizationStatus(updatedStatus, error: nil)
            } catch {
                let fallbackStatus = AuthorizationCenter.shared.authorizationStatus
                Log.error("OnboardingFive Screen Time authorization threw error: \(error.localizedDescription) (status=\(fallbackStatus.rawValue))")
                await handleAuthorizationStatus(fallbackStatus, error: error)
            }
        }
    }

    @MainActor
    private func handleAuthorizationStatus(_ status: AuthorizationStatus, error: Error?) {
        hasAlertBeenDismissed = true
        hasScreenTimePermissionResponded = true

        switch status {
        case .approved:
            isScreenTimePermissionGranted = true
            showingRetryAlert = false
            Log.info("Screen Time permission approved")
            onPermissionGranted?()

#if targetEnvironment(simulator)
        case .notDetermined:
            isScreenTimePermissionGranted = true
            showingRetryAlert = false
            Log.info("Screen Time status notDetermined on simulator; treating as approved for testing")
            onPermissionGranted?()
#endif

        case .notDetermined:
            isScreenTimePermissionGranted = false
            alertMessage = "Screen Time isn’t fully set up. Turn on Screen Time in Settings, then come back and tap Continue."
            showingRetryAlert = true
            Log.info("Screen Time status notDetermined after request; guiding user to Settings")

        case .denied:
            isScreenTimePermissionGranted = false
            alertMessage = "We couldn’t get Screen Time access. Double-check Screen Time is enabled in Settings > Screen Time and try again."
            showingRetryAlert = true
            Log.error("Screen Time permission denied or restricted")

        @unknown default:
            isScreenTimePermissionGranted = false
            alertMessage = error?.localizedDescription ?? "We couldn’t confirm Screen Time access. Please try again."
            showingRetryAlert = true
            Log.error("Screen Time permission returned unknown status=\(status.rawValue)")
        }
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
    OnboardingFive(
        triggerPermissionRequest: .constant(false),
        isScreenTimePermissionGranted: .constant(false),
        hasAlertBeenDismissed: .constant(false),
        hasScreenTimePermissionResponded: .constant(false),
        subtitle: "We need permission to track your screen time",
        onPermissionGranted: nil
    )
}

