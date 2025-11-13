//
//  RootTabView.swift
//  ForwardNeckV1
//
//  Bottom navigation with 5 tabs. Center tab opens ProgressTrackingView.
//

import SwiftUI

enum RootTab: String, CaseIterable, Hashable {
    case home = "Home"
    case circuit = "Circuit"
    case leaderboard = "Ranking"
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

            // Circuit Tab - Daily neck workout circuit
            NavigationStack { 
                PlanView(selectedTab: Binding(
                    get: { selection },
                    set: { newValue in
                        if let newValue = newValue {
                            selection = newValue
                        }
                    }
                ))
                    .navigationBarHidden(true)
            }
            .tabItem { 
                Label("Circuit", systemImage: "dumbbell.fill") 
            }
            .tag(RootTab.circuit)

            // Ranking Tab - Global rankings (Center position, blue tint)
            NavigationStack {
                LeaderboardView()
            }
            .tabItem {
                Label("Ranking", systemImage: "chart.bar.fill")
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
    /// Only customize for iOS versions below iOS 16 - keep default appearance for iOS 16+
    private func configureTabBarAppearance() {
        // iOS 16+ uses default system appearance - no customization needed
        if #available(iOS 16.0, *) {
            // Let iOS handle the tab bar appearance natively
            return
        }
        
        // Only customize for iOS versions below 16 - make it clean and visible
        let appearance = UITabBarAppearance()
        
        if #available(iOS 15.0, *) {
            // iOS 15: use transparent background with light, clean appearance
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.98)
            appearance.shadowColor = UIColor.clear
        } else {
            // iOS 14 and below: use opaque background with light appearance
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
        }
        
        // Configure normal state - use a more visible gray (not too faint)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]
        
        // Configure selected state - use black for clear visibility
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.label
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        // Apply appearance
        UITabBar.appearance().standardAppearance = appearance
        
        // iOS 15+ supports scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Ensure tab bar is always visible
        UITabBar.appearance().isHidden = false
    }
}

// All placeholder views have been replaced with real implementations
// - Exercises: ExerciseListView (B-003)
// - Rewards: RewardsView (B-005) 
// - Settings: ReminderSettingsView (B-002)

#Preview {
    RootTabView()
}
