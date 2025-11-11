//
//  RootTabView.swift
//  ForwardNeckV1
//
//  Bottom navigation with 5 tabs. Center tab opens ProgressTrackingView.
//

import SwiftUI

enum RootTab: String, CaseIterable, Hashable {
    case home = "Home"
    case plan = "Plan"
    case leaderboard = "Leaderboard"
    case stats = "Stats"
    case settings = "Settings"
    
    var id: String { rawValue }
}

struct RootTabView: View {
    @State private var selection: RootTab = .home
    @StateObject private var levelUpManager = LevelUpManager.shared

    var body: some View {
        TabView(selection: $selection) {
            // Home Tab - Main dashboard
            NavigationStack { 
                HomeView(selectedTab: $selection)
                    .navigationBarHidden(true) 
            }
            .tabItem { 
                Label("Home", systemImage: "house.fill") 
            }
            .tag(RootTab.home)

            // Plan Tab - Daily neck workout circuit
            NavigationStack { 
                PlanView()
                    .navigationBarHidden(true) 
            }
            .tabItem { 
                Label("Plan", systemImage: "dumbbell.fill") 
            }
            .tag(RootTab.plan)

            // Leaderboard Tab - Global rankings (Center position, blue tint)
            NavigationStack {
                LeaderboardView()
            }
            .tabItem {
                Label("Leaderboard", systemImage: "chart.bar.fill")
            }
            .tag(RootTab.leaderboard)

            // Stats Tab - Calendar-based progress tracking
            NavigationStack { 
                ProgressTrackingView()
                    .navigationBarHidden(true)
            }
            .tabItem { 
                Label("Stats", systemImage: "calendar") 
            }
            .tag(RootTab.stats)

            // Settings Tab - App settings and preferences
            NavigationStack { 
                SettingsView()
            }
            .tabItem { 
                Label("Settings", systemImage: "gearshape.fill") 
            }
            .tag(RootTab.settings)
        }
        .tint(.black)
        .onAppear {
            // Configure tab bar appearance
            configureTabBarAppearance()
            Log.info("RootTabView appeared with \(RootTab.allCases.count) tabs")
        }
        .onChange(of: selection) { oldValue, newValue in
            // Log tab changes for debugging
            Log.info("Tab changed from \(oldValue.rawValue) to \(newValue.rawValue)")
        }
        .sheet(isPresented: $levelUpManager.showLevelUpSheet) {
            if let level = levelUpManager.currentLevelUp {
                LevelUpSheet(level: level) {
                    levelUpManager.dismissLevelUpSheet()
                }
                .presentationDetents([.fraction(0.8)])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    /// Configure tab bar appearance for better visual design
    /// Part of B-008: Connect all screens with bottom tab bar
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Use different configuration based on iOS version for better compatibility
        if #available(iOS 15.0, *) {
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            appearance.shadowColor = UIColor.clear
        } else {
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        }
        
        // Configure normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.black.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.black.withAlphaComponent(0.6)
        ]
        
        // Configure selected state - default behavior
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Custom color for leaderboard tab only - this won't work as expected, need different approach
        // We'll use a custom modifier on the tab item itself
        
        // Apply shadow for better visibility on older iOS versions
        if !ProcessInfo.processInfo.isiOSAppOnMac {
            UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
            UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -2)
            UITabBar.appearance().layer.shadowRadius = 8
            UITabBar.appearance().layer.shadowOpacity = 0.3
            UITabBar.appearance().clipsToBounds = false
        }
    }
}

// All placeholder views have been replaced with real implementations
// - Exercises: ExerciseListView (B-003)
// - Rewards: RewardsView (B-005) 
// - Settings: ReminderSettingsView (B-002)

#Preview {
    RootTabView()
}
