//
//  PlanView.swift
//  ForwardNeckV1
//
//  Daily neck workout plan view showing workout details and exercises in a card.
//

import SwiftUI

struct PlanView: View {
    // MARK: - Properties
    
    /// View model managing workout circuit data
    @StateObject var viewModel = PlanViewModel()
    
    /// State for showing full description
    @State private var isDescriptionExpanded = false
    
    /// State for showing workout flow
    @State private var isShowingWorkoutFlow = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background gradient matching HomeView theme
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header section
                    headerSection
                    
                    // Day selector
                    daySelector
                    
                    // Main workout card containing everything
                    workoutCard
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            Task { await viewModel.onAppear() }
        }
        .fullScreenCover(isPresented: $isShowingWorkoutFlow) {
            WorkoutFlowView(
                exercises: viewModel.exercises,
                onComplete: {
                    isShowingWorkoutFlow = false
                    // Record completion for Full Daily Workout slot
                    Task {
                        await ExerciseStore.shared.recordCompletion(
                            exerciseId: UUID(), // Workout session ID
                            durationSeconds: viewModel.totalDuration,
                            timeSlot: .afternoon
                        )
                        Log.info("Full Daily Workout completed and recorded")
                        
                        // Refresh completion status to update button
                        viewModel.refreshCompletionStatus()
                    }
                },
                onCancel: {
                    isShowingWorkoutFlow = false
                }
            )
        }
    }
    
    // MARK: - Header Section
    
    /// Header with title and "Free Week" badge
    private var headerSection: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Plan")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Text("GET FIT")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // MARK: - Day Selector
    
    /// Horizontal day selector with status ticks below each day
    private var daySelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { dayIndex in
                dayButton(for: dayIndex)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
    }
    
    /// Individual day button with letter and dot indicator
    private func dayButton(for dayIndex: Int) -> some View {
        let dayLetters = ["M", "T", "W", "T", "F", "S", "S"]
        let isSelected = dayIndex == viewModel.selectedDayIndex
        
        return VStack(spacing: 8) {
            // Day letter
            Text(dayLetters[dayIndex])
                .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.3) : Color.clear)
                )
            
            // Status tick below (green if completed, gray if missed)
            let date = viewModel.dateForDayIndex(dayIndex)
            let completed = viewModel.fullWorkoutCompleted(on: date)
            Image(systemName: "checkmark")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(completed ? Color.green : Color.red)
                .frame(height: 6)
        }
    }
    
    // MARK: - Workout Card
    
    /// Main dark card containing workout info, button, and exercises
    private var workoutCard: some View {
        VStack(spacing: 0) {
            // Top section: Icon, title, description, and Start button
            VStack(spacing: 16) {
                // Icon and title row
                HStack(spacing: 16) {
                    // Body icon
                    Image(systemName: "figure.stand")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(Theme.gradientBrightPink)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Full Body")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Monday")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Menu button (three dots)
                    Button(action: {
                        Log.debug("Menu button tapped")
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Theme.gradientBrightPink)
                            .rotationEffect(.degrees(90))
                    }
                }
                
                // Description with "more" button
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scientifically proven to provide the best results in the shortest possible time. This HIIT classic ha")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(isDescriptionExpanded ? nil : 2)
                    
                    Button(action: {
                        isDescriptionExpanded.toggle()
                    }) {
                        Text(isDescriptionExpanded ? "less" : "more")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Start Workout button (blue) or Completed button (green)
                if viewModel.isWorkoutCompletedToday {
                    // Completed state - Green button (non-interactive)
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("Today Workout Completed")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.8, blue: 0.4),   // bright green
                                        Color(red: 0.1, green: 0.6, blue: 0.3)    // deeper green
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                } else {
                    // Available state - Blue button (interactive)
                    Button(action: {
                        Log.info("Start Workout button tapped")
                        isShowingWorkoutFlow = true
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("Start Workout")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.5, blue: 1.0),   // bright blue
                                            Color(red: 0.1, green: 0.3, blue: 0.8)    // deeper blue
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                }
            }
            .padding(24)
            
            // Exercises section
            VStack(alignment: .leading, spacing: 16) {
                // "Exercises" header
                Text("Exercises")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                
                // Exercise list
                VStack(spacing: 12) {
                    ForEach(viewModel.exercises) { exercise in
                        exerciseRow(exercise: exercise)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
        )
    }
    
    // MARK: - Exercise Row
    
    /// Individual exercise row with emoji/icon and name
    private func exerciseRow(exercise: Exercise) -> some View {
        HStack(spacing: 16) {
            // Exercise icon/emoji
            Text(exerciseEmoji(for: exercise.title))
                .font(.system(size: 32))
            
            // Exercise name
            Text(exercise.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Helpers
    
    /// Get emoji for exercise based on title (matching image style)
    private func exerciseEmoji(for title: String) -> String {
        let lowercased = title.lowercased()
        
        if lowercased.contains("chin") || lowercased.contains("tuck") {
            return "🧘‍♂️"
        } else if lowercased.contains("neck stretch") || lowercased.contains("stretch") {
            return "🤸‍♂️"
        } else if lowercased.contains("shoulder") {
            return "💪"
        } else if lowercased.contains("rotation") || lowercased.contains("turn") {
            return "🔄"
        } else if lowercased.contains("nod") || lowercased.contains("up down") {
            return "👆"
        } else {
            return "🏃‍♂️"
        }
    }
}

// MARK: - Preview

#Preview {
    PlanView()
}


