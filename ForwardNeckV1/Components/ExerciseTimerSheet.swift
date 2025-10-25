//
//  ExerciseTimerSheet.swift
//  ForwardNeckV1
//
//  Extracted from HomeView.swift for better MVVM organization
//

import SwiftUI

struct ExerciseTimerSheet: View {
    let exercise: Exercise
    let onComplete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.title)
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    Text(exercise.description)
                        .font(.body.bold())
                        .foregroundColor(.black.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps")
                        .font(.headline)
                        .foregroundColor(.black)
                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        Text("\(index + 1). \(instruction)")
                            .foregroundColor(.black.opacity(0.85))
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
        .onAppear {
            Log.debug("ExerciseTimerSheet appeared for exercise: \(exercise.title)")
        }
    }
}

#Preview {
    ExerciseTimerSheet(
        exercise: Exercise(
            id: UUID(),
            title: "Sample Exercise",
            description: "A sample exercise for preview",
            instructions: ["Step 1", "Step 2", "Step 3"],
            durationSeconds: 30,
            iconSystemName: "figure.strengthtraining.traditional",
            difficulty: .easy
        ),
        onComplete: {},
        onCancel: {}
    )
}


