//
//  WorkoutFlowView.swift
//  ForwardNeckV1
//
//  Full workout flow with exercises and breaks.
//

import SwiftUI

struct WorkoutFlowView: View {
    let exercises: [Exercise]
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @StateObject private var viewModel: WorkoutFlowViewModel
    
    init(exercises: [Exercise], onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.exercises = exercises
        self.onComplete = onComplete
        self.onCancel = onCancel
        _viewModel = StateObject(wrappedValue: WorkoutFlowViewModel(exercises: exercises))
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with close button
                topBar
                
                Spacer()
                
                // Main content
                if viewModel.isBreak {
                    breakView
                } else {
                    exerciseView
                }
                
                Spacer()
                
                // Progress indicators at bottom
                progressSection
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            viewModel.start()
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                onComplete()
            }
        }
    }
    
    // MARK: - Top Bar
    
    private var topBar: some View {
        HStack {
            Spacer()
            
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Exercise View
    
    private var exerciseView: some View {
        VStack(spacing: 32) {
            // Exercise emoji/icon
            if let currentExercise = viewModel.currentExercise {
                Text(exerciseEmoji(for: currentExercise.title))
                    .font(.system(size: 120))
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Exercise name
                Text(currentExercise.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Timer
                Text("\(viewModel.timeRemaining)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(currentExercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1).")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(instruction)
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Break View
    
    private var breakView: some View {
        VStack(spacing: 32) {
            // Rest icon
            Text("☕️")
                .font(.system(size: 120))
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // "Rest" text
            Text("Rest")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            // Countdown
            Text("\(viewModel.timeRemaining)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.orange)
                .monospacedDigit()
            
            // Next exercise preview
            if let nextExercise = viewModel.nextExercise {
                VStack(spacing: 8) {
                    Text("Next up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(nextExercise.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            // Progress text
            Text("Exercise \(viewModel.currentExerciseIndex + 1) of \(exercises.count)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.5, blue: 1.0),
                                    Color(red: 0.1, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.progress, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Helpers
    
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
        } else if lowercased.contains("wall") || lowercased.contains("angel") {
            return "🪽"
        } else {
            return "🏃‍♂️"
        }
    }
}

// MARK: - Preview

#Preview {
    WorkoutFlowView(
        exercises: [
            Exercise(
                title: "Chin Tucks",
                description: "Strengthen deep neck flexors",
                instructions: ["Sit with back straight", "Gently pull chin back"],
                durationSeconds: 30,
                iconSystemName: "face.smiling"
            )
        ],
        onComplete: {},
        onCancel: {}
    )
}

