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
    @State private var showingLevelSheet = false
    
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
                            .foregroundColor(.black)
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
                            .foregroundColor(.black.opacity(0.6))
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
        .sheet(isPresented: $showingLevelSheet) {
            LevelDetailSheet(currentLevel: viewModel.currentLevel, userProgress: viewModel.userProgress)
        }
    }
    
    /// Current level section showing level progress
    private var currentLevelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Level icon - clickable level image
                Button(action: {
                    showingLevelSheet = true
                }) {
                    Image(levelImageName(for: viewModel.userProgress.level))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.currentLevel?.title ?? "Unknown")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    
                    Text(viewModel.currentLevel?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Progress to next level
                    if let nextLevel = viewModel.nextLevel {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Progress to Level \(nextLevel.number)")
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.7))
                            
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
                .foregroundColor(.black)

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

/// Sheet showing detailed level information
struct LevelDetailSheet: View {
    let currentLevel: Level?
    let userProgress: UserProgress
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Header - reduced spacing
                    VStack(spacing: 8) {
                        Text(currentLevel?.title ?? "Unknown Level")
                            .font(.title.bold()) // Reduced from largeTitle
                            .foregroundColor(.black)
                        
                        Text(currentLevel?.description ?? "")
                            .font(.body) // Reduced from title3
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer().frame(height: 8) // Reduced from 20
                    
                    Image(levelImageName(for: userProgress.level))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160) // Reduced from 180
                    
                    Spacer().frame(height: 8) // Added small spacer
                    
                    // Level details
                    VStack(spacing: 12) {
                        HStack {
                            Text("Current Level")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(userProgress.level)")
                                .font(.title.bold())
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Text("Total XP")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(userProgress.xp)")
                                .font(.title.bold())
                                .foregroundColor(.black)
                        }
                    }
                    .padding(16) // Reduced from 20
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20) // Reduced horizontal padding
                .padding(.top, 16) // Reduced top padding
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Helper Functions

/// Generate level image name based on level number
private func levelImageName(for level: Int) -> String {
    // Ensure level is within valid range (1-20)
    let clampedLevel = max(1, min(level, 20))
    return "level\(clampedLevel)"
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
}
