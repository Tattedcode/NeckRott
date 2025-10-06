//
//  HomeView.swift
//  ForwardNeckV1
//
//  Entry point for the home dashboard.
//

import FamilyControls
import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @State var isShowingExerciseTimer = false
    @State var isInstructionsExpanded = false
    @State var isAppPickerPresented = false
    @State var presentedAchievement: MonthlyAchievement?
    @State var shouldCelebrate = false
    @State var lastPresentedAchievement: MonthlyAchievement?
    @State var flamePulse = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        headerTitle
                        mascotSection
                        nextExerciseSection
                        statisticsSection
                        previousDatesSection
                        monthlyAchievementsSection
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }

            if presentedAchievement != nil {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            Task { await viewModel.onAppear() }
        }
        .fullScreenCover(isPresented: $isShowingExerciseTimer) {
            exerciseTimerSheet
        }
        .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $viewModel.activitySelection)
        .onChange(of: viewModel.recentlyUnlockedAchievement) { achievement in
            guard let achievement else { return }
            presentedAchievement = achievement
            lastPresentedAchievement = achievement
            shouldCelebrate = true
            viewModel.clearRecentlyUnlockedAchievement()
        }
        .sheet(item: $presentedAchievement, onDismiss: handleAchievementDismissal) { achievement in
            AchievementUnlockedSheet(
                achievement: achievement,
                isCelebrating: shouldCelebrate
            ) {
                presentedAchievement = nil
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.hidden)
        }
    }

    private var headerTitle: some View {
        Text("ForwardNeck")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .padding(.top, 20)
    }

    private var exerciseTimerSheet: some View {
        Group {
            if let exercise = viewModel.nextExercise {
                ExerciseTimerSheet(
                    exercise: exercise,
                    onComplete: {
                        Task { @MainActor in
                            await viewModel.completeCurrentExercise()
                            isShowingExerciseTimer = false
                        }
                    },
                    onCancel: {
                        isShowingExerciseTimer = false
                    }
                )
            } else {
                ZStack {
                    Theme.backgroundGradient.ignoresSafeArea()
                    Text("No exercise available")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }

    private func handleAchievementDismissal() {
            if shouldCelebrate, let last = lastPresentedAchievement {
                viewModel.markAchievementCelebrated(last)
            }
            shouldCelebrate = false
            lastPresentedAchievement = nil
    }
}

#Preview {
    HomeView()
}
