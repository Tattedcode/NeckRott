//
//  HomeView.swift
//  ForwardNeckV1
//
//  Entry point for the home dashboard.
//

import FamilyControls
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: RootTab
    @StateObject var viewModel = HomeViewModel()
    @State var isShowingExerciseTimer = false
    @State var isInstructionsExpanded = false
    @State var isAppPickerPresented = false
    @State var presentedAchievement: MonthlyAchievement?
    @State var shouldCelebrate = false
    @State var lastPresentedAchievement: MonthlyAchievement?
    @State var flamePulse = false
    
    // Timer to update countdown display every 10 seconds
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        headerTitle
                            .padding(.horizontal, 20)
                        mascotSection
                            .padding(.horizontal, 20)
                        statisticsSection
                            .padding(.horizontal, 20)
                        nextExerciseSection
                            .padding(.horizontal, 20)
                        previousDatesSection
                            // No horizontal padding - let it extend to screen edges
                        Spacer(minLength: 60)
                    }
                }
            }

            if presentedAchievement != nil {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .task { await viewModel.onAppear() }
        .fullScreenCover(isPresented: $isShowingExerciseTimer) {
            exerciseTimerSheet
        }
        .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $viewModel.activitySelection)
        .onChange(of: viewModel.recentlyUnlockedAchievement) { _, achievement in
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
        .alert("Exercise Locked", isPresented: $viewModel.showTimeSlotLockedAlert) {
            Button("OK", role: .cancel) {
                viewModel.showTimeSlotLockedAlert = false
            }
        } message: {
            Text(viewModel.lockedAlertMessage)
        }
        .onReceive(timer) { _ in
            // Update time slot statuses to refresh countdown timer display
            viewModel.updateTimeSlotStatuses()
        }
    }

    private var headerTitle: some View {
        Text("Neckrot")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.black)
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
    HomeView(selectedTab: .constant(.home))
}
