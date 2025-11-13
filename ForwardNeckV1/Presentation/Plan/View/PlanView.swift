//
//  PlanView.swift
//  ForwardNeckV1
//
//  Daily neck workout plan view showing workout details and exercises in a card.
//

import SwiftUI

struct PlanView: View {
    // MARK: - Properties
    
    /// Binding to control tab selection (for navigation after workout completion)
    @Binding var selectedTab: RootTab?
    
    /// View model managing workout circuit data
    @StateObject var viewModel = PlanViewModel()
    
    /// State for showing workout flow
    @State private var isShowingWorkoutFlow = false
    
    /// State for showing chin tuck instruction view
    @State private var selectedExercise: Exercise? = nil
    
    /// Initialize with optional tab binding (defaults to nil for previews)
    init(selectedTab: Binding<RootTab?> = .constant(nil)) {
        self._selectedTab = selectedTab
    }
    
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
                        
                        // Cancel Full Daily Workout notifications after completion
                        await NotificationManager.shared.cancelFullDailyWorkoutNotifications()
                        Log.info("Cancelled Full Daily Workout notifications after completion")
                        
                        // Refresh completion status to update button
                        viewModel.refreshCompletionStatus()
                        
                        // Navigate to home view after workout completion
                        selectedTab = .home
                    }
                },
                onCancel: {
                    isShowingWorkoutFlow = false
                }
            )
        }
        .sheet(item: $selectedExercise) { exercise in
            let titleLower = exercise.title.lowercased()
            
            // Show chin tuck instruction view when chin tucks is selected
            if titleLower.contains("chin") || titleLower.contains("tuck") {
                NavigationStack {
                    ChinTuckInstructionView(exercise: exercise) {
                        selectedExercise = nil
                    }
                }
            } else if titleLower.contains("neck flexion") || (titleLower.contains("flexion") && !titleLower.contains("tilt")) {
                // Show neck flexion instruction view when neck flexion is selected (but not neck tilt)
                NavigationStack {
                    NeckFlexionInstructionView(exercise: exercise) {
                        selectedExercise = nil
                    }
                }
            } else if titleLower == "neck tilts" || titleLower.contains("neck tilt") {
                // Show neck tilt instruction view when neck tilts is selected
                NavigationStack {
                    NeckTiltInstructionView(exercise: exercise) {
                        selectedExercise = nil
                    }
                }
            } else if titleLower.contains("wall angel") || (titleLower.contains("wall") && titleLower.contains("angel")) {
                // Show wall angel instruction view when wall angel is selected
                NavigationStack {
                    WallAngelInstructionView(exercise: exercise) {
                        selectedExercise = nil
                    }
                }
            } else {
                // For other exercises, show standard detail view
                NavigationStack {
                    ExerciseDetailView(exercise: exercise)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    selectedExercise = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.black.opacity(0.7))
                                }
                            }
                        }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    /// Header with title and "Free Week" badge
    private var headerSection: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Circuit")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
                
                HStack(spacing: 8) {
                    Text("GET FIT")
                        .font(.system(size: 14, weight: .bold))
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
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.black.opacity(0.1) : Color.clear)
                )
            
            // Status tick below (green if completed, red if missed)
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
                    // Angel icon
                    Image("angel1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Full Daily Workout")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(currentDayName)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                
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
    
    /// Individual exercise row with emoji/icon and name - now clickable
    private func exerciseRow(exercise: Exercise) -> some View {
        Button(action: {
            // When exercise is clicked, show instruction view
            Log.info("Exercise tapped: \(exercise.title)")
            selectedExercise = exercise
        }) {
            HStack(spacing: 16) {
                // Exercise icon/emoji - use chintuck1.png for Chin Tucks, flexion1.png for Neck Flexion, necktilt1.png for Neck Tilts, angel1.png for Wall Angel
                let titleLower = exercise.title.lowercased()
                
                if titleLower.contains("chin") || titleLower.contains("tuck") {
                    Image("chintuck1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if titleLower == "neck tilts" || titleLower.contains("neck tilt") {
                    Image("necktilt1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if titleLower.contains("neck flexion") || (titleLower.contains("flexion") && !titleLower.contains("tilt")) {
                    Image("flexion1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if titleLower.contains("wall angel") || (titleLower.contains("wall") && titleLower.contains("angel")) {
                    Image("angel1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text(exerciseEmoji(for: exercise.title))
                        .font(.system(size: 32))
                }
                
                // Exercise name
                Text(exercise.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Chevron indicator to show it's clickable
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain) // Remove default button styling
    }
    
    // MARK: - Helpers
    
    /// Get current day name (Monday, Tuesday, etc.)
    private var currentDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
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


