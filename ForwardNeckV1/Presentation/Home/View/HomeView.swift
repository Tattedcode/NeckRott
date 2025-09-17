//
//  HomeView.swift
//  ForwardNeckV1
//
//  Creates the Dashboard screen UI with two tabs: Overview (default) and Exercises.
//  Follows MVVM. This file contains only SwiftUI view code.
//

import SwiftUI

/// Simple enum for Dashboard tabs
private enum HomeTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case exercises = "Exercises"

    var id: String { rawValue }
}

struct HomeView: View {
    // ViewModel is reference type shared across child views
    @State private var selectedTab: HomeTab = .overview
    @State private var username: String = "Derek Doyle" // Placeholder until auth/profile exists
    @State private var isDarkMode: Bool = true // For preview feel only; actual theme via Settings later
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()

    var body: some View {
        ZStack {
            // Background gradient centralized in Theme
            Theme.backgroundGradient
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    tabSelector
                    content
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Debug log: track lifecycle
            print("[HomeView] onAppear – loading dashboard data")
            Task { await viewModel.loadDashboard() }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dashboard")
                .font(.headline)
                .foregroundColor(Color.white.opacity(0.7))

            // Greeting line like mockup: "Hello, Derek Doyle 👋"
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("Hello, \(username)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                Text("👋")
                    .font(.system(size: 28))
            }
        }
    }

    private var tabSelector: some View {
        // Segmented style pill buttons matching mockup
        HStack(spacing: 8) {
            ForEach(HomeTab.allCases) { tab in
                Button(action: {
                    selectedTab = tab
                    Log.info("Switched Home tab to: \(tab.rawValue)")
                }) {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(selectedTab == tab ? Theme.pillSelected : Theme.pillUnselected)
                        .foregroundColor(selectedTab == tab ? Theme.primaryText : Theme.secondaryText)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .overview:
            OverviewTabView(viewModel: viewModel)
        case .exercises:
            ExercisesTabView(viewModel: viewModel)
        }
    }
}

// MARK: - Overview Tab

private struct OverviewTabView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Current streak with animations
            CurrentStreakView(currentStreak: viewModel.currentStreakDays)
            
            // Longest streak with animations
            LongestStreakView(longestStreak: viewModel.longestStreakDays)

            // Daily progress card
            DailyStreakCard(
                completed: viewModel.completedRemindersToday,
                total: viewModel.dailyReminderTarget
            )

            // Next exercise to do - shows random exercise with start button
            NextExerciseView(
                exercise: viewModel.nextExercise,
                onStartExercise: {
                    viewModel.startNextExercise()
                },
                onCompleteExercise: {
                    viewModel.completeNextExercise()
                }
            )

            // Two metric cards in a vertical stack like mockup
            VStack(spacing: 12) {
                MetricRowCard(
                    title: "Posture Check-Ins",
                    systemImage: "figure.walk",
                    color: Color.orange,
                    value: viewModel.weeklyPostureCheckins
                )
                MetricRowCard(
                    title: "Exercises Done",
                    systemImage: "dumbbell",
                    color: Color.green,
                    value: viewModel.weeklyExercisesDone
                )
            }
        }
    }
}

// MARK: - Exercises Tab (list-only for now)

private struct ExercisesTabView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.exercises) { exercise in
                HStack(spacing: 12) {
                    Image(systemName: exercise.iconSystemName)
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.blue.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.title)
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(exercise.durationLabel)
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline)
                    }
                    Spacer()

                    // Placeholder action; actual navigation will be added in Exercise Detail feature
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(14)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    Log.info("Tapped exercise: \(exercise.title)")
                }
            }
        }
    }
}

// Components moved to `Components/` folder for reuse

// MARK: - Preview

#Preview {
    HomeView()
}
