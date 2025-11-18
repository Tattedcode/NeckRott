//
//  HomeView.swift
//  NeckRotV1
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
    @State var flamePulse = false
    @State var isShowingConnect4 = false
    
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
                        VStack(spacing: 0) {
                            mascotSection
                            statisticsSection
                        }
                        .padding(.horizontal, 20)
                        nextExerciseSection
                            .padding(.horizontal, 20)
                        previousDatesSection
                            // No horizontal padding - let it extend to screen edges
                        Spacer(minLength: 60)
                    }
                }
            }

        }
        .task { await viewModel.onAppear() }
        .fullScreenCover(isPresented: $isShowingExerciseTimer) {
            exerciseTimerSheet
        }
        .fullScreenCover(isPresented: $isShowingConnect4) {
            connect4Sheet
        }
        .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $viewModel.activitySelection)
        .alert("Exercise Locked", isPresented: $viewModel.showTimeSlotLockedAlert) {
            Button("OK", role: .cancel) {
                viewModel.showTimeSlotLockedAlert = false
            }
        } message: {
            Text(viewModel.lockedAlertMessage)
        }
        .onChange(of: isShowingConnect4) { _, newValue in
            if newValue == false {
                viewModel.updateStreaks()
                viewModel.updateNeckFixes(for: viewModel.selectedNeckFixDate)
                viewModel.updateTimeSlotStatuses()
                viewModel.updateNextExercise()
            }
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
            if let exercise = viewModel.dailyUnrotExercise ?? viewModel.nextExercise {
                ExerciseTimerSheet(
                    exercise: exercise,
                    timeSlot: viewModel.currentTimeSlot, // Pass the current time slot to identify quick workout
                    onComplete: {
                        Task { @MainActor in
                            Log.info("ExerciseTimerSheet onComplete called - completing exercise")
                            await viewModel.completeCurrentExercise()
                            Log.info("Exercise completed - dismissing timer sheet")
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
    
    private var connect4Sheet: some View {
        Group {
            // Prefer showing the active/finished game if it exists, even after completion,
            // so the completion sheet can be shown before leaving.
            if Connect4MatchStore.shared.currentGame != nil ||
                (Connect4MatchStore.shared.currentMatch?.isReady ?? false) {
                NavigationStack {
                    Connect4GameView(onExit: {
                        Connect4MatchStore.shared.stopMatch()
                        isShowingConnect4 = false
                    })
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") {
                                    Connect4MatchStore.shared.stopMatch()
                                    isShowingConnect4 = false
                                }
                                .foregroundColor(.black)
                            }
                        }
                }
            } else {
                // Show matchmaking view
                NavigationStack {
                    Connect4MatchmakingView()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    Connect4MatchStore.shared.stopMatch()
                                    isShowingConnect4 = false
                                }
                                .foregroundColor(.black)
                            }
                        }
                        .onChange(of: Connect4MatchStore.shared.currentMatch) { oldValue, newValue in
                            // When match becomes ready, the view will automatically update
                            if let match = newValue, match.isReady {
                                // Match found - view will automatically switch to game view
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
}
