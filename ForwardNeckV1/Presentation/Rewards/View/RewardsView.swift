//
//  RewardsView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

/// Rewards and Levels screen showing gamification progress
/// Part of S-006: Rewards/Levels Screen
struct RewardsView: View {
    /// ViewModel for managing rewards data
    @StateObject private var viewModel: RewardsViewModel = RewardsViewModel()
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with current level and progress
                    currentLevelSection
                    
                    // XP and Coins display
                    statsSection
                    
                    // Achievements section
                    achievementsSection
                    
                    // Rewards shop section
                    rewardsSection
                }
                .padding(16)
            }
        }
        .onAppear {
            viewModel.loadData()
            Log.info("RewardsView appeared")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// Current level section showing level progress
    private var currentLevelSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Level")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            
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
    
    /// Stats section showing XP and coins
    private var statsSection: some View {
        HStack(spacing: 16) {
            // XP display
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("XP")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text("\(viewModel.userProgress.xp)")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Total: \(viewModel.userProgress.totalXpEarned)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Coins display
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)
                    Text("Coins")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text("\(viewModel.userProgress.coins)")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Total: \(viewModel.userProgress.totalCoinsEarned)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    /// Achievements section
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
        }
    }
    
    /// Rewards shop section
    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rewards Shop")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.rewards) { reward in
                    RewardCard(reward: reward, onPurchase: {
                        viewModel.purchaseReward(reward.id)
                    })
                }
            }
        }
    }
}

/// Card component for displaying achievements
/// Part of S-006: Rewards/Levels Screen
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            // Achievement icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.iconSystemName)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
            }
            
            // Achievement details
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline.bold())
                    .foregroundColor(achievement.isUnlocked ? .white : .gray)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(achievement.isUnlocked ? .white.opacity(0.8) : .gray)
                    .multilineTextAlignment(.center)
                
                if achievement.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("+\(achievement.xpReward) XP")
                            .font(.caption.bold())
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .padding(12)
        .background(achievement.isUnlocked ? Theme.cardBackground : Theme.cardBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? achievement.color : Color.clear, lineWidth: 2)
        )
    }
}

/// Card component for displaying rewards
/// Part of S-006: Rewards/Levels Screen
struct RewardCard: View {
    let reward: Reward
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Reward icon
            ZStack {
                Circle()
                    .fill(reward.isPurchased ? reward.color : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: reward.iconSystemName)
                    .font(.title2)
                    .foregroundColor(reward.isPurchased ? .white : .gray)
            }
            
            // Reward details
            VStack(spacing: 4) {
                Text(reward.title)
                    .font(.subheadline.bold())
                    .foregroundColor(reward.isPurchased ? .white : .gray)
                    .multilineTextAlignment(.center)
                
                Text(reward.description)
                    .font(.caption)
                    .foregroundColor(reward.isPurchased ? .white.opacity(0.8) : .gray)
                    .multilineTextAlignment(.center)
                
                if !reward.isPurchased {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("\(reward.coinsCost) coins")
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Purchased")
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Purchase button
            if !reward.isPurchased {
                Button(action: onPurchase) {
                    Text("Buy")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(reward.color)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(reward.isPurchased ? Theme.cardBackground : Theme.cardBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(reward.isPurchased ? reward.color : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        RewardsView()
    }
}
