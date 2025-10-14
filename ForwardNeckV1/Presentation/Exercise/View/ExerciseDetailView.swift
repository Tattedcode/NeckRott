//
//  ExerciseDetailView.swift
//  ForwardNeckV1
//
//  Shows exercise instructions with timer and completion tracking.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @StateObject private var timer = ExerciseTimer()
    @State private var currentStep = 0
    @State private var isCompleted = false
    @State private var showingCompletion = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header with exercise info
                    VStack(spacing: 12) {
                        Image(systemName: exercise.iconSystemName)
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text(exercise.title)
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text(exercise.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        // Difficulty badge
                        HStack {
                            Circle()
                                .fill(difficultyColor)
                                .frame(width: 8, height: 8)
                            Text(exercise.difficulty.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.cardBackground)
                        .clipShape(Capsule())
                    }
                    
                    // Timer section
                    VStack(spacing: 16) {
                        Text("Timer")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: timer.progress)
                                .stroke(LinearGradient(colors: [Color.blue, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                            
                            VStack {
                                Text(timer.timeRemainingString)
                                    .font(.title.bold())
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                                Text("remaining")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Timer controls
                        HStack(spacing: 20) {
                            Button(action: timer.reset) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Theme.cardBackground)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: timer.isRunning ? timer.pause : timer.start) {
                                Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(LinearGradient(colors: [Color.blue, Color.pink], startPoint: .leading, endPoint: .trailing))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(20)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instructions")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Theme.pillSelected)
                                    .clipShape(Circle())
                                
                                Text(instruction)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Complete button
                    if timer.isCompleted && !isCompleted {
                        Button(action: completeExercise) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Mark as Complete")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [Color.blue, Color.pink], startPoint: .leading, endPoint: .trailing))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            timer.setup(duration: exercise.durationSeconds)
            Log.info("ExerciseDetailView appeared for: \(exercise.title)")
        }
        .alert("Exercise Complete!", isPresented: $showingCompletion) {
            Button("Great!") { }
        } message: {
            Text("You've completed \(exercise.title). Great job!")
        }
    }
    
    private var difficultyColor: Color {
        switch exercise.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    private func completeExercise() {
        Task { @MainActor in
            // Determine current time slot for this completion
            let timeSlot = ExerciseTimeSlot.currentTimeSlot() ?? .morning
            
            await ExerciseStore.shared.recordCompletion(exerciseId: exercise.id, durationSeconds: timer.elapsedSeconds, timeSlot: timeSlot)
            
            // Update streaks after exercise completion
            await updateStreaks()
            
            // Update custom goals progress so everything stays in sync
            let goalsStore = GoalsStore.shared
            goalsStore.updateAllGoalProgress()
            
            isCompleted = true
            showingCompletion = true
            Log.info("Exercise completed: \(exercise.title)")
        }
    }
    
    /// Update streak data after exercise completion
    /// Part of F-004: Streaks & Progress feature
    private func updateStreaks() async {
        let checkInStore = CheckInStore.shared
        let exerciseStore = ExerciseStore.shared
        let streakStore = StreakStore.shared
        
        let allCheckIns = checkInStore.all()
        let allExercises = exerciseStore.completions
        
        let checkInDates = allCheckIns.map { $0.timestamp }
        let exerciseDates = allExercises.map { $0.completedAt }
        
        streakStore.updateDailyStreaks(checkIns: checkInDates, exerciseCompletions: exerciseDates)
    }
}

// Timer helper for exercise timing
@MainActor
class ExerciseTimer: ObservableObject {
    @Published var timeRemaining: Int = 0
    @Published var isRunning: Bool = false
    @Published var isCompleted: Bool = false
    
    private var totalDuration: Int = 0
    private var timer: Timer?
    
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    var timeRemainingString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var elapsedSeconds: Int {
        totalDuration - timeRemaining
    }
    
    func setup(duration: Int) {
        totalDuration = duration
        timeRemaining = duration
        isCompleted = false
        isRunning = false
    }
    
    func start() {
        guard !isCompleted else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.complete()
                }
            }
        }
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeRemaining = totalDuration
        isCompleted = false
    }
    
    private func complete() {
        pause()
        isCompleted = true
        Log.info("Timer completed for exercise")
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: Exercise(
            title: "Neck Tilt Stretch",
            description: "Gentle neck stretch to relieve tension",
            instructions: ["Sit or stand with shoulders relaxed", "Slowly tilt your head to the right", "Hold for 15 seconds"],
            durationSeconds: 60,
            iconSystemName: "person.fill.viewfinder",
            difficulty: .easy
        ))
    }
}
