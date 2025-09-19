//
//  OnboardingAppSelection.swift
//  ForwardNeckV1
//
//  App selection onboarding screen for choosing apps to limit
//

import SwiftUI
import FamilyControls

struct OnboardingAppSelection: View {
    @State private var selectedApps: Set<String> = []
    @State private var showAppSelection = false
    @State private var appMonitoringStore = AppMonitoringStore()
    @State private var familyActivitySelection = FamilyActivitySelection()
    @State private var recentApps: [String] = []
    
    // Get the most recently used social apps for preview
    private var previewApps: [String] {
        if recentApps.isEmpty {
            return ["Instagram", "TikTok", "YouTube", "Facebook"] // Fallback apps
        }
        return Array(recentApps.prefix(4))
    }
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Mascot image
            Image("mascot4")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title
            Text("Select Apps to Limit")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle and additional note
            VStack(spacing: 0) {
                Text("Choose which apps you want to reduce time on")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text("(you can update this later)")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // App selection card
            Button(action: {
                showAppSelection = true
            }) {
                VStack(spacing: 16) {
                    // App selection header - centered
                    Text("Select apps to limit")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    if familyActivitySelection.applicationTokens.isEmpty {
                        // No apps selected - show recent apps preview
                        HStack(spacing: 20) {
                            ForEach(Array(previewApps.enumerated()), id: \.offset) { index, appName in
                                VStack(spacing: 8) {
                                    // App icon
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(getAppColor(for: appName))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: getAppIcon(for: appName))
                                                .font(.title2)
                                                .foregroundColor(.white)
                                        )
                                    
                                    // App name
                                    Text(appName)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .frame(maxWidth: 50)
                                }
                            }
                            
                            // Arrow at the end
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    } else {
                        // Show selected apps
                        HStack(spacing: 20) {
                            ForEach(Array(familyActivitySelection.applicationTokens.prefix(4)), id: \.self) { token in
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "app.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            if familyActivitySelection.applicationTokens.count > 4 {
                                Text("+\(familyActivitySelection.applicationTokens.count - 4)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(8)
                            }
                            
                            // Arrow at the end
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(PlainButtonStyle())
            
            // Confirmation text
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text("We'll help you limit time spent on these apps")
                    .font(.subheadline)
                    .foregroundColor(.green)
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
            // Load existing selected apps from the store
            selectedApps = appMonitoringStore.selectedApps
            // Load recent apps for preview
            loadRecentApps()
        }
        .onChange(of: familyActivitySelection) { newSelection in
            // Convert FamilyActivitySelection to app names for storage
            let appNames = newSelection.applicationTokens.map { token in
                // Store the token hash as a unique identifier
                // In a real app, you'd use the token for monitoring
                "App_\(token.hashValue)"
            }
            selectedApps = Set(appNames)
            appMonitoringStore.updateSelectedApps(selectedApps)
        }
        .familyActivityPicker(isPresented: $showAppSelection, selection: $familyActivitySelection)
    }
    
    // MARK: - Helper Functions
    
    /// Load recently used social apps for preview
    private func loadRecentApps() {
        // For now, we'll use a predefined list of popular social apps
        // In a real implementation, you'd query the system for recently used apps
        recentApps = ["Instagram", "TikTok", "YouTube", "Facebook", "Snapchat", "Twitter"]
    }
    
    /// Get app color based on app name
    private func getAppColor(for appName: String) -> Color {
        switch appName.lowercased() {
        case "instagram":
            return .purple
        case "tiktok":
            return .black
        case "youtube":
            return .red
        case "facebook":
            return .blue
        case "snapchat":
            return .yellow
        case "twitter":
            return .blue.opacity(0.8)
        default:
            return .blue
        }
    }
    
    /// Get app icon based on app name
    private func getAppIcon(for appName: String) -> String {
        switch appName.lowercased() {
        case "instagram":
            return "camera.fill"
        case "tiktok":
            return "music.note"
        case "youtube":
            return "play.rectangle.fill"
        case "facebook":
            return "person.2.fill"
        case "snapchat":
            return "camera.circle.fill"
        case "twitter":
            return "bird.fill"
        default:
            return "app.fill"
        }
    }
}

#Preview {
    OnboardingAppSelection()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}