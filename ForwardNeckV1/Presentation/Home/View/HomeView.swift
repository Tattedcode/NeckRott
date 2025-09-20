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
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingExerciseTimer = false
    @State private var isInstructionsExpanded = false
    
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
                        
                        // Next exercise prompt
                        nextExerciseSection

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }

            }
        }
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .sheet(isPresented: $isShowingExerciseTimer) {
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
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            } else {
                ZStack {
                    Theme.backgroundGradient
                        .ignoresSafeArea()
                    Text("No exercise available")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
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
            Text("\(viewModel.healthScore)")
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
            
            // Three column stats
            HStack(spacing: 40) {
                // Left column - Screen time
                VStack(alignment: .center, spacing: 4) {
                    Text("screen time")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    
                    if viewModel.isLoadingScreenTime {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading...")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Text(viewModel.screenTimeDisplay)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)

                // Middle column - Record Streak (longest)
                VStack(alignment: .center, spacing: 4) {
                    Text("record streak")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(viewModel.recordStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                // Right column - Daily Streak (current)
                VStack(alignment: .center, spacing: 4) {
                    Text("daily streak")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Next Exercise Section

    private var nextExerciseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time To Unrot Your Neck")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            
            Group {
                if let exercise = viewModel.nextExercise {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(exercise.title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .accessibilityAddTraits(.isHeader)
                            
                            Text(exercise.description)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(spacing: 12) {
                                Label(exercise.durationLabel, systemImage: "clock")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Label(exercise.difficulty.rawValue.capitalized, systemImage: "flame")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(color(for: exercise.difficulty))
                            }
                            
                            DisclosureGroup(isExpanded: $isInstructionsExpanded) {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                                        Text("\(index + 1). \(instruction)")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                }
                                .padding(.top, 6)
                            } label: {
                                Label("Instructions", systemImage: "list.bullet")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .tint(.white)
                        }
                        
                        Spacer(minLength: 16)
                        
                        VStack(spacing: 8) {
                            Spacer()
                            Button(action: {
                                isShowingExerciseTimer = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [color(for: exercise.difficulty), color(for: exercise.difficulty).opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 72, height: 72)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Start \(exercise.title)")
                            
                            Text("Start")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: viewModel.nextExercise?.id) { _ in
                        isInstructionsExpanded = false
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No exercises available right now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Check back later for a new move to keep your posture sharp.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private func color(for difficulty: ExerciseDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }

    private struct ExerciseTimerSheet: View {
        let exercise: Exercise
        let onComplete: () -> Void
        let onCancel: () -> Void

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(.white)
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                            Text("\(index + 1). \(instruction)")
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    
                    ExerciseCountdownTimer(
                        durationSeconds: exercise.durationSeconds,
                        autoStart: true,
                        onComplete: onComplete,
                        onCancel: onCancel
                    )
                }
                .padding(24)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
        }
    }

}

// MARK: - Preview

#Preview {
    HomeView()
}
