//
//  RewardsView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

/// Rewards and Levels screen showing gamification progress
/// Part of S-006: Rewards/Levels Screen
struct AchievementsView: View {
    /// ViewModel for managing rewards data
    @StateObject private var viewModel: RewardsViewModel = RewardsViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    currentLevelSection
                    monthlyAchievementsSection

                    Button {
                        Log.info("Testing button tapped -> adding 25 XP for previewing level flow")
                        viewModel.addXP(25, source: "Testing button")
                    } label: {
                        Text("Add 25 XP (Test)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 12)
                    .accessibilityIdentifier("testAddXpButton")
                    .overlay(
                        Text("Temporary testing button for XP flow")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 4), alignment: .bottom
                    )

                }
                .padding(16)
            }
        }
        .onAppear {
            viewModel.loadData()
            Task { await homeViewModel.onAppear() }
            Log.info("AchievementsView appeared")
            viewModel.startObserving()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// Current level section showing level progress
    private var currentLevelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Level icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.blue, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    
                    Text("\(viewModel.userProgress.level)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.currentLevel?.title ?? "Unknown")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text(viewModel.currentLevel?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Progress to next level
                    if let nextLevel = viewModel.nextLevel {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress to Level \(nextLevel.number)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            
                            ProgressView(value: viewModel.progressToNextLevel)
                                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                    } else {
                        Text("Max Level Reached!")
                            .font(.caption.bold())
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private extension AchievementsView {
    var monthlyAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Achievements")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 14) {
                ForEach(homeViewModel.monthlyAchievements) { achievement in
                    let imageName = achievement.isUnlocked ? achievement.kind.unlockedImageName : achievement.kind.lockedImageName

                    VStack {
                        Group {
                            if achievement.kind.usesSystemImage {
                                Image(systemName: imageName)
                                    .resizable()
                            } else {
                                Image(imageName)
                                    .resizable()
                            }
                        }
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .padding(4)
                        .opacity(achievement.isUnlocked ? 1 : 0.3)
                        .grayscale(achievement.isUnlocked ? 0 : 1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
}
