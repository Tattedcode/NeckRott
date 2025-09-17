//
//  NextExerciseView.swift
//  ForwardNeckV1
//
//  Reusable component that displays the next exercise to do with a start button.
//  Shows a random exercise and handles completion to move it from the home view.
//

import SwiftUI

struct NextExerciseView: View {
    // Input values for the exercise to display
    let exercise: Exercise?
    let onStartExercise: () -> Void
    let onCompleteExercise: () -> Void
    
    // Animation state for the exercise card
    @State private var isAnimating: Bool = false
    @State private var showCompletionAnimation: Bool = false
    @State private var showTimer: Bool = false
    @State private var isTimerPaused: Bool = false
    
    init(exercise: Exercise?, onStartExercise: @escaping () -> Void, onCompleteExercise: @escaping () -> Void) {
        self.exercise = exercise
        self.onStartExercise = onStartExercise
        self.onCompleteExercise = onCompleteExercise
    }
    
    var body: some View {
        if let exercise = exercise {
            if showTimer {
                // Timer view - completely replace the exercise card
                VStack(spacing: 20) {
                    // Exercise title
                    Text(exercise.title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Large circular countdown timer
                    ExerciseCountdownTimer(
                        durationSeconds: exercise.durationSeconds,
                        autoStart: true, // Automatically start the timer when it appears
                        onComplete: {
                            Log.info("Exercise timer completed: \(exercise.title)")
                            onCompleteExercise()
                            showTimer = false
                        },
                        onCancel: {
                            Log.info("Exercise timer cancelled: \(exercise.title)")
                            showTimer = false
                        }
                    )
                    
        

                }
                .padding(20)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                // Exercise card view - original layout
                VStack(alignment: .leading, spacing: 12) {
                    // Header with title and icon
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "figure.strengthtraining.functional")
                            .foregroundColor(.orange)
                            .font(.title2)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Text("Next Exercise to Do")
                            .font(.headline)
                            .foregroundColor(Theme.primaryText)
                        
                        Spacer()
                    }
                    
                    // Exercise details
                    HStack(alignment: .center, spacing: 16) {
                        // Exercise icon with difficulty color
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(difficultyColor.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: exercise.iconSystemName)
                                .foregroundColor(difficultyColor)
                                .font(.title2)
                        }
                        
                        // Exercise information
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(exercise.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(2)
                            
                            HStack(spacing: 8) {
                                // Duration
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                    Text(exercise.durationLabel)
                                        .font(.caption)
                                }
                                .foregroundColor(.white.opacity(0.7))
                                
                                // Difficulty
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                    Text(exercise.difficulty.rawValue.capitalized)
                                        .font(.caption)
                                }
                                .foregroundColor(difficultyColor)
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Start button
                    Button(action: {
                        Log.info("Start exercise button tapped: \(exercise.title)")
                        showTimer = true
                        onStartExercise()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [difficultyColor, difficultyColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(showCompletionAnimation ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: showCompletionAnimation)
                }
                .padding(16)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .onAppear {
                    // Start the subtle animation
                    isAnimating = true
                }
                .onDisappear {
                    // Stop animation when view disappears
                    isAnimating = false
                }
            }
        } else {
            // Empty state when no exercise is available
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title)
                
                Text("All Done for Now!")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Great job! Check back later for your next exercise.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(16)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Helper Properties
    
    private var difficultyColor: Color {
        guard let exercise = exercise else { return .gray }
        
        switch exercise.difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}

#Preview {
    ZStack { 
        Theme.backgroundGradient.ignoresSafeArea() 
        VStack(spacing: 16) {
            // Preview with exercise
            NextExerciseView(
                exercise: Exercise(
                    title: "Neck Stretch",
                    description: "Gentle neck stretches to relieve tension",
                    instructions: ["Sit up straight", "Slowly tilt head to right", "Hold for 10 seconds"],
                    durationSeconds: 120,
                    iconSystemName: "figure.flexibility",
                    difficulty: .easy
                ),
                onStartExercise: { print("Start exercise") },
                onCompleteExercise: { print("Complete exercise") }
            )
            
            // Preview empty state
            NextExerciseView(
                exercise: nil,
                onStartExercise: { print("Start exercise") },
                onCompleteExercise: { print("Complete exercise") }
            )
        }
        .padding()
    }
}
