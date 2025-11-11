//
//  LeaderboardView.swift
//  ForwardNeckV1
//
//  Global monthly leaderboard showing user rankings with tabs for Leaderboard, Level, and Achievements
//

import SwiftUI

/// Main leaderboard view showing global rankings with tabs for Leaderboard, Level, and Achievements
struct LeaderboardView: View {
    @State private var viewModel = LeaderboardViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var rewardsViewModel: RewardsViewModel = RewardsViewModel()
    @State private var showingLevelSheet = false
    @State private var showingUsernameSheet = false
    @State private var selectedAchievement: MonthlyAchievement?
    
    enum LeaderboardTab: String, CaseIterable {
        case leaderboard = "Leaderboard"
        case level = "Level"
        case achievements = "Achievements"
    }
    
    @State private var selectedTab: LeaderboardTab = .leaderboard
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title section
                VStack(spacing: 0) {
                    Text("Leaderboard")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    
                // Tab selector with pill-shaped selected background
                HStack(spacing: 12) {
                    ForEach(LeaderboardTab.allCases, id: \.self) { tab in
                        Button(action: {
                            selectedTab = tab
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedTab == tab ? .black : .black.opacity(0.6))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    Group {
                                        if selectedTab == tab {
                                            if #available(iOS 15.0, *) {
                                                // Glass blur effect for iOS 15+
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .fill(.ultraThinMaterial)
                                                    
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                                }
                                            } else {
                                                // Solid background for older iOS
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.green.opacity(0.15))
                                            }
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(selectedTab == tab ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Content based on selected tab
                        if selectedTab == .leaderboard {
                            leaderboardContent
                        } else if selectedTab == .level {
                            levelContent
                        } else {
                            achievementsContent
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .refreshable {
                await viewModel.refreshLeaderboard()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.onAppear()
        }
        .onAppear {
            rewardsViewModel.loadData()
            Task { await homeViewModel.onAppear() }
            rewardsViewModel.startObserving()
        }
        .sheet(isPresented: $showingUsernameSheet) {
            SetUsernameSheet(
                currentCountryCode: viewModel.userProfile.countryCode
            ) { username, countryCode in
                Task {
                    await viewModel.saveUsername(username, countryCode: countryCode)
                }
            }
        }
        .sheet(isPresented: $showingLevelSheet) {
            LevelDetailSheet(
                currentLevel: rewardsViewModel.currentLevel,
                userProgress: rewardsViewModel.userProgress
            )
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailSheet(achievement: achievement)
                .presentationDetents([.fraction(0.75)])
                .presentationDragIndicator(.visible)
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error occurred")
        }
        .alert("Reset Status", isPresented: $viewModel.showingResetAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.resetStatusMessage)
        }
    }
    
    // MARK: - Content Sections
    
    private var leaderboardContent: some View {
        VStack(spacing: 20) {
            // Header section
            leaderboardHeader
            
            // Join prompt if not opted in
            if !viewModel.hasJoinedLeaderboard {
                joinPromptSection
            } else {
                // User's rank card
                if let rank = viewModel.currentUserRank {
                    userRankCard(rank: rank)
                }
                
                // Leaderboard list
                leaderboardList
            }
            
            // Last updated text
            Text(viewModel.lastRefreshText)
                .font(.caption)
                .foregroundColor(.black.opacity(0.5))
                .padding(.top, 8)
            
            // TESTING: Reset button
            Button(action: {
                Task {
                    await viewModel.resetLeaderboard()
                }
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset Leaderboard (All Users)")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, 20)
        }
    }
    
    private var levelContent: some View {
        VStack(spacing: 16) {
            levelSection
        }
        .padding(.top, 8)
    }
    
    private var achievementsContent: some View {
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
            
            // TESTING: Button to unlock next achievement
            Button(action: {
                homeViewModel.unlockNextAchievement()
            }) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Unlock Next Achievement (Test)")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Leaderboard Components
    
    private var leaderboardHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.yellow)
                
                Text("Global Monthly Ranking")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
            }
            
            Text("Compete with users worldwide")
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.7))
            
            // Current month badge
            Text(currentMonthText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green)
                .clipShape(Capsule())
        }
        .padding(.top, 8)
    }
    
    private var joinPromptSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.black.opacity(0.3))
            
            Text("Join the Competition")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Text("Set your display name to appear on the global leaderboard and compete with users worldwide!")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                showingUsernameSheet = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("Join Leaderboard")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func userRankCard(rank: Int) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Your Rank")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Rank
                Text("#\(rank)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // User info
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(viewModel.userProfile.flagEmoji)
                            .font(.system(size: 24))
                        Text(viewModel.userProfile.username ?? "You")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Text("\(monthlySessionCount) sessions")
                        .font(.system(size: 14))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow, lineWidth: 2)
        )
    }
    
    private var leaderboardList: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Text("Top Users")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.bottom, 12)
            
            // Leaderboard rows
            if viewModel.leaderboardUsers.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.leaderboardUsers) { user in
                    leaderboardRow(for: user)
                }
            }
        }
    }
    
    private func leaderboardRow(for user: LeaderboardUser) -> some View {
        let isCurrentUser = viewModel.isCurrentUser(user)
        
        return HStack(spacing: 12) {
            // Rank with medal
            ZStack {
                if let medal = user.medalEmoji {
                    Text(medal)
                        .font(.system(size: 32))
                } else {
                    Text("#\(user.rank ?? 0)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(width: 40)
                }
            }
            .frame(width: 50)
            
            // Country flag
            Text(user.flagEmoji)
                .font(.system(size: 28))
            
            // Username
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(user.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                
                Text("\(user.totalSessions) sessions")
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.6))
            }
            
            Spacer()
        }
        .padding()
        .background(
            isCurrentUser
                ? Color.green.opacity(0.1)
                : Theme.cardBackground
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isCurrentUser ? Color.green : Color.clear,
                    lineWidth: isCurrentUser ? 2 : 0
                )
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.black.opacity(0.3))
            
            Text("No Rankings Yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Text("Be the first to join and complete exercises!")
                .font(.system(size: 14))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Level Components
    
    private var levelSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    // Level icon - clickable level image
                    Button(action: {
                        showingLevelSheet = true
                    }) {
                        Image(levelImageName(for: rewardsViewModel.userProgress.level))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(rewardsViewModel.currentLevel?.title ?? "Unknown")
                            .font(.title2.bold())
                            .foregroundColor(.black)
                        
                        Text(rewardsViewModel.currentLevel?.description ?? "")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                        
                        // Progress to next level
                        if let nextLevel = rewardsViewModel.nextLevel {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Progress to Level \(nextLevel.number)")
                                    .font(.caption)
                                    .foregroundColor(.black.opacity(0.7))
                                
                                ProgressView(value: rewardsViewModel.progressToNextLevel)
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
            
            // Roadmap to next level
            if rewardsViewModel.nextLevel != nil {
                LevelRoadmapView(
                    currentLevel: rewardsViewModel.currentLevel,
                    nextLevel: rewardsViewModel.nextLevel,
                    userProgress: rewardsViewModel.userProgress
                )
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currentMonthText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var monthlySessionCount: Int {
        let calendar = Calendar.current
        let now = Date()
        
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
            return 0
        }
        
        return ExerciseStore.shared.completions.filter { completion in
            completion.completedAt >= monthStart && completion.completedAt <= now
        }.count
    }
}

// MARK: - Helper Extension

extension UserProfile {
    var flagEmoji: String {
        guard let countryCode = countryCode else { return "🌍" }
        return countryCode.unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }
}

/// Generate level image name based on level number
private func levelImageName(for level: Int) -> String {
    // Ensure level is within valid range (1-20)
    let clampedLevel = max(1, min(level, 20))
    return "level\(clampedLevel)"
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
