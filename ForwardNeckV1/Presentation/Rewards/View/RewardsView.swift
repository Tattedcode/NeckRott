//
//  RewardsView.swift
//  NeckRotV1
//
//  Contains shared level-related UI components.
//

import SwiftUI

/// Details for a specific level, reused across the app.
struct LevelDetailSheet: View {
    let currentLevel: Level?
    let nextLevel: Level?
    let progressToNextLevel: Double
    let userProgress: UserProgress

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if let level = currentLevel {
                            VStack(spacing: 12) {
                                Image(levelImageName(for: level.number))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)

                                Text("Level \(level.number): \(level.title)")
                                    .font(.title.bold())
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)

                                Text(level.description)
                                    .font(.body)
                                    .foregroundColor(.black.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                            .padding()
                            .background(Theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current XP")
                                .font(.headline)
                                .foregroundColor(.black)

                            HStack {
                                ProgressView(value: clampedProgressToNextLevel)
                                .tint(.green)

                                Text("\(userProgress.xp) XP")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.black)
                            }

                            if let nextLevel {
                                let currentLevelXP = max(0, userProgress.xp - (currentLevel?.xpRequired ?? 0))
                                let xpNeeded = max(0, nextLevel.xpRequired - (currentLevel?.xpRequired ?? 0))

                                Text("Progress to Level \(nextLevel.number): \(currentLevelXP)/\(xpNeeded) XP")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.7))
                            }
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Level Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var clampedProgressToNextLevel: Double {
        min(max(progressToNextLevel, 0), 1)
    }
}

/// Generate level image name based on level number
private func levelImageName(for level: Int) -> String {
    // Ensure level is within valid range (1-20)
    let clampedLevel = max(1, min(level, 20))
    return "level\(clampedLevel)"
}

#Preview {
    LevelDetailSheet(
        currentLevel: Level(
            id: 1,
            number: 1,
            xpRequired: 0,
            title: "Neck Rookie",
            description: "Just getting started",
            iconSystemName: "figure.walk",
            colorHex: "#8E8E93"
        ),
        nextLevel: Level(
            id: 2,
            number: 2,
            xpRequired: 100,
            title: "Posture Learner",
            description: "Finding your rhythm",
            iconSystemName: "lightbulb",
            colorHex: "#60A5FA"
        ),
        progressToNextLevel: 0.6,
        userProgress: UserProgress(xp: 60, level: 1, totalXpEarned: 120)
    )
}
