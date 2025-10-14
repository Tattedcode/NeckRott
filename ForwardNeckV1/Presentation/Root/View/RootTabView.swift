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
    case stats = "Stats"
    case rewards = "Achievements"
    case settings = "Settings"
    
    var id: String { rawValue }
}

struct RootTabView: View {
    @State private var selection: RootTab = .home

    var body: some View {
        TabView(selection: $selection) {
            // Home Tab - Main dashboard
            NavigationStack { 
                HomeView()
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

            // Stats Tab - Calendar-based progress tracking
            NavigationStack { 
                ProgressTrackingView()
                    .navigationBarHidden(true)
            }
            .tabItem { 
                Label("Stats", systemImage: "calendar") 
            }
            .tag(RootTab.stats)

            // Achievements Tab - Gamification and progress
            NavigationStack { 
                AchievementsView()
                    .navigationTitle("Achievements")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { 
                Label("Achievements", systemImage: "rosette") 
            }
            .tag(RootTab.rewards)

            // Settings Tab - App settings and preferences
            NavigationStack { 
                SettingsView()
            }
            .tabItem { 
                Label("Settings", systemImage: "gearshape.fill") 
            }
            .tag(RootTab.settings)
        }
        .tint(.white)
        .onAppear {
            // Configure tab bar appearance
            configureTabBarAppearance()
            Log.info("RootTabView appeared with \(RootTab.allCases.count) tabs")
        }
        .onChange(of: selection) { oldValue, newValue in
            // Log tab changes for debugging
            Log.info("Tab changed from \(oldValue.rawValue) to \(newValue.rawValue)")
        }
    }
    
    /// Configure tab bar appearance for better visual design
    /// Part of B-008: Connect all screens with bottom tab bar
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        // Configure normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        
        // Configure selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// All placeholder views have been replaced with real implementations
// - Exercises: ExerciseListView (B-003)
// - Rewards: RewardsView (B-005) 
// - Settings: ReminderSettingsView (B-002)

#Preview {
    RootTabView()
}
