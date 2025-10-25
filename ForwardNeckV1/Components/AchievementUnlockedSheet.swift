//
//  AchievementUnlockedSheet.swift
//  ForwardNeckV1
//
//  Extracted from HomeView.swift for better MVVM organization
//

import SwiftUI

struct AchievementUnlockedSheet: View {
    let achievement: MonthlyAchievement
    let isCelebrating: Bool
    let onDismiss: () -> Void

    @State private var animateOverlay = false
    @State private var confettiActive = false

    // Brighter gradient for the action button so the sheet feels celebratory and light
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.62, blue: 0.98),
                Color(red: 0.72, green: 0.52, blue: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // Light purplish gradient so the sheet feels bright but readable
    private var sheetGradient: LinearGradient { Theme.backgroundGradient }

    var body: some View {
        ZStack {
            // Light purplish gradient (brighter than HomeView's background)
            sheetGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    achievementArtwork
                        .frame(width: 190, height: 190)

                    Circle()
                        .stroke(Color.white.opacity(0.55), lineWidth: 3)
                        .frame(width: 210, height: 210)
                        .scaleEffect(animateOverlay ? 1.08 : 0.92)
                        .opacity(animateOverlay ? 0.25 : 0.4)

                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 230, height: 230)
                        .scaleEffect(animateOverlay ? 1.15 : 0.85)
                        .opacity(animateOverlay ? 0.12 : 0.26)
                }
                .frame(height: 210)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                        animateOverlay = true
                    }
                }

                VStack(spacing: 8) {
                    Text(achievement.isUnlocked ? "Achievement Unlocked!" : "Achievement Goal")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)

                    Text(achievement.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                }

                Button(action: onDismiss) {
                    Text(achievement.isUnlocked ? "Good Job!" : "Got it")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)
            .padding(.bottom, 36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(
            ConfettiOverlay(isActive: $confettiActive)
        )
        .ignoresSafeArea()
        .onAppear {
            Log.debug("AchievementUnlockedSheet bright styling applied for \(achievement.title)")
            if isCelebrating {
                confettiActive = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    confettiActive = false
                }
            }
        }
        .onDisappear {
            confettiActive = false
        }
    }

    @ViewBuilder
    private var achievementArtwork: some View {
        Group {
            if achievement.kind.usesSystemImage {
                Image(systemName: achievement.kind.unlockedImageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
            } else {
                Image(achievement.kind.unlockedImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .opacity(achievement.isUnlocked ? 1 : 0.35)
        .grayscale(achievement.isUnlocked ? 0 : 1)
    }
}

#Preview {
    AchievementUnlockedSheet(
        achievement: MonthlyAchievement(kind: .firstExercise, isUnlocked: true),
        isCelebrating: true,
        onDismiss: {}
    )
}

