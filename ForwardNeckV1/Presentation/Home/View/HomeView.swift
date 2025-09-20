//
//  HomeView.swift
//  ForwardNeckV1
//
//  Fresh home page design based on brainrot app screenshot
//  Clean, minimal design with mascot, health score, and statistics
//

import SwiftUI

struct HomeView: View {
    @State private var selectedDate = "today"
    @State private var healthScore = 100
    @State private var screenTime = "0m"
    @State private var dailyStreak = 7
    @State private var selectedTab = 0
    @StateObject private var screenTimeService = ScreenTimeService()
    
    var body: some View {
        ZStack {
            // Background gradient matching onboarding
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with date and help buttons
                topSection
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // App title
                        Text("ForwardNeck")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Mascot and health score
                        mascotSection
                        
                        // Statistics section
                        statisticsSection
                        
                        Spacer(minLength: 100) // Space for bottom nav
                    }
                    .padding(.horizontal, 20)
                }
                
                // Bottom navigation
                bottomNavigation
            }
        }
        .onAppear {
            Task {
                await loadScreenTime()
            }
        }
    }
    
    // MARK: - Screen Time Loading
    
    private func loadScreenTime() async {
        await screenTimeService.fetchScreenTime()
        screenTime = screenTimeService.formatScreenTime(screenTimeService.totalScreenTime)
    }
    
    // MARK: - Top Section
    
    private var topSection: some View {
        HStack {
            // Date selector
            Button(action: {
                // Handle date selection
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                    Text(selectedDate)
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Spacer()
            
            // Help button
            Button(action: {
                // Handle help action
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "questionmark")
                        .font(.system(size: 14))
                    Text("help")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Mascot Section
    
    private var mascotSection: some View {
        VStack(spacing: 16) {
            // Mascot image - made bigger
            Image("mascot3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            
            // Health score
            Text("\(healthScore)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            // Health bar
            VStack(spacing: 4) {
                // Progress bar - made smaller
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.green)
                            .frame(width: geometry.size.width, height: 6)
                    }
                }
                .frame(height: 6)
                
                // Health label
                HStack(spacing: 4) {
                    Text("health")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
            
            // Two column stats
            HStack(spacing: 40) {
                // Left column - Screen time
                VStack(alignment: .center, spacing: 4) {
                    Text("screen time")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    if screenTimeService.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Text(screenTime)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Right column - Daily Streak
                VStack(alignment: .center, spacing: 4) {
                    Text("daily streak")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(dailyStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
            
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tabIcon(for: index))
                                .font(.system(size: 20))
                                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                            
                            Text(tabTitle(for: index))
                                .font(.system(size: 10))
                                .foregroundColor(selectedTab == index ? .white : .white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .background(Color.clear)
    }
    
    // MARK: - Helper Functions
    
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "calendar"
        case 2: return "nosign"
        case 3: return "gearshape.fill"
        default: return "house.fill"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "home"
        case 1: return "stats"
        case 2: return "blocking"
        case 3: return "settings"
        default: return "home"
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
