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
    @State private var selectedAchievement: MonthlyAchievement?
    
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
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement)
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
        }
    }
    
    /// Current level section showing level progress
    private var currentLevelSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Level icon - clickable level image
                Button(action: {
                    showingLevelSheet = true
                }) {
                    Image(levelImageName(for: viewModel.userProgress.level))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.currentLevel?.title ?? "Unknown")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    
                    Text(viewModel.currentLevel?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Progress to next level
                    if let nextLevel = viewModel.nextLevel {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Progress to Level \(nextLevel.number)")
                                .font(.caption)
                                .foregroundColor(.black.opacity(0.7))
                            
                            ProgressView(value: viewModel.progressToNextLevel)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
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
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

private extension AchievementsView {
    var monthlyAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Achievements")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 14) {
                ForEach(homeViewModel.monthlyAchievements) { achievement in
                    let imageName = achievement.isUnlocked ? achievement.kind.unlockedImageName : achievement.kind.lockedImageName

                    Button(action: {
                        Log.info("Achievement tapped: \(achievement.kind.title)")
                        selectedAchievement = achievement
                    }) {
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
                    .buttonStyle(.plain)
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
                        .frame(width: 200, height: 200)
                    
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

/// Sheet showing detailed achievement information
struct AchievementDetailSheet: View {
    let achievement: MonthlyAchievement
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Text(achievement.kind.title)
                            .font(.title.bold())
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text(achievementDescription(for: achievement.kind))
                            .font(.body)
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    // Achievement image
                    let imageName = achievement.isUnlocked ? achievement.kind.unlockedImageName : achievement.kind.lockedImageName
                    
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
                    .frame(width: 160, height: 160)
                    .opacity(achievement.isUnlocked ? 1 : 0.3)
                    .grayscale(achievement.isUnlocked ? 0 : 1)
                    
                    // Status section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Status")
                                .font(.headline)
                                .foregroundColor(.black)
                            Spacer()
                            Text(achievement.isUnlocked ? "Completed" : "Locked")
                                .font(.title2.bold())
                                .foregroundColor(achievement.isUnlocked ? .green : .red)
                        }
                    }
                    .padding(20)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Additional info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(achievementDetails(for: achievement.kind))
                            .font(.body)
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(20)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helper Functions
    
    private func achievementDescription(for kind: MonthlyAchievementKind) -> String {
        switch kind {
        case .firstExercise:
            return "Complete your first exercise this month"
        case .extraExercises:
            return "Complete more exercises than your daily goal"
        case .tenCompleted:
            return "Complete 10 exercises total"
        case .twentyCompleted:
            return "Complete 20 exercises total"
        case .dailyStreakStarted:
            return "Start a daily exercise streak"
        case .fifteenDayStreak:
            return "Maintain a 15-day exercise streak"
        case .fullMonthStreak:
            return "Maintain a 30-day exercise streak"
        case .weeklyStreak:
            return "Maintain a 7-day exercise streak"
        }
    }
    
    private func achievementRequirement(for kind: MonthlyAchievementKind) -> String {
        switch kind {
        case .firstExercise:
            return "Complete 1 exercise this month"
        case .extraExercises:
            return "Exceed your daily goal"
        case .tenCompleted:
            return "Complete 10 exercises"
        case .twentyCompleted:
            return "Complete 20 exercises"
        case .dailyStreakStarted:
            return "Complete exercises for 1 day"
        case .fifteenDayStreak:
            return "Complete exercises for 15 days in a row"
        case .fullMonthStreak:
            return "Complete exercises for 30 days in a row"
        case .weeklyStreak:
            return "Complete exercises for 7 days in a row"
        }
    }
    
    private func achievementDetails(for kind: MonthlyAchievementKind) -> String {
        switch kind {
        case .firstExercise:
            return "Well done on taking your first step this month towards better neck health. Working on your neck now will save it in the future"
        case .extraExercises:
            return "Going above and beyond your daily goal shows dedication and commitment to your neck health journey."
        case .tenCompleted:
            return "You've completed 10 exercises! This milestone shows you're building a consistent habit of caring for your neck."
        case .twentyCompleted:
            return "Amazing! 20 exercises completed shows serious dedication to improving your neck posture and health."
        case .dailyStreakStarted:
            return "Starting a daily streak is the foundation of building lasting habits. Keep it up to unlock more achievements!"
        case .fifteenDayStreak:
            return "15 days in a row is impressive! You're well on your way to building a strong, healthy habit for your neck."
        case .fullMonthStreak:
            return "A full month of consistent exercise is incredible! You've truly mastered the art of daily neck care."
        case .weeklyStreak:
            return "One week of consistent exercise is a great start! This achievement marks your commitment to daily neck health."
        }
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
