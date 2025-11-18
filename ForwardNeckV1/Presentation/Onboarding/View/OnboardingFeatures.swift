//
//  OnboardingFeatures.swift
//  NeckRotV1
//
//  Feature highlights screen for onboarding
//

import SwiftUI

struct OnboardingFeatures: View {
    @State private var currentFeatureIndex = 0
    @State private var showFeatures = false
    
    private let features = [
        FeatureItem(
            icon: "timer",
            title: "Neck Workouts",
            description: "Quick workouts designed by experts to fix forward neck posture",
            color: .blue
        ),
        FeatureItem(
            icon: "chart.line.uptrend.xyaxis",
            title: "World Wide Leaderboard",
            description: "Compete for 1st place world wide by completing neck exercises",
            color: .green
        ),
        FeatureItem(
            icon: "star.fill",
            title: "Earn Rewards",
            description: "Unlock achievements and level up as you build healthy habits",
            color: .orange
        ),
        FeatureItem(
            icon: "flame.fill",
            title: "Build Streaks",
            description: "Stay consistent with daily reminders and streak tracking",
            color: .red
        )
    ]
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                // Header - Title only, no subtitle
                Text("Why Choose Neckrot?")
                    .font(.title.bold())
                    .foregroundColor(Theme.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(showFeatures ? 1 : 0)
                    .offset(y: showFeatures ? 0 : -20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showFeatures)
                
                // Features List
                VStack(spacing: 20) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        FeatureCard(
                            feature: feature,
                            isVisible: showFeatures,
                            delay: Double(index) * 0.1
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.75, alignment: .center)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                showFeatures = true
            }
        }
    }
}

struct FeatureItem {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct FeatureCard: View {
    let feature: FeatureItem
    let isVisible: Bool
    let delay: Double
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(feature.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline.bold())
                    .foregroundColor(Theme.primaryText)
                
                Text(feature.description)
                    .font(.body)
                    .foregroundColor(Theme.secondaryText)
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(feature.color.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .animation(.easeOut(duration: 0.6).delay(delay), value: isVisible)
        .onTapGesture {
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

#Preview {
    OnboardingFeatures()
        .background(Theme.backgroundGradient)
}
