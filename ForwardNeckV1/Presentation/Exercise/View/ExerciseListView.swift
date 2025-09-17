//
//  ExerciseListView.swift
//  ForwardNeckV1
//
//  Shows list of available exercises with navigation to detail screens.
//

import SwiftUI

struct ExerciseListView: View {
    @StateObject private var store = ExerciseStore.shared
    @State private var exercises: [Exercise] = []
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            
            if exercises.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "figure.strengthtraining.functional")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    Text("Loading exercises...")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(exercises) { exercise in
                            NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                ExerciseRowView(exercise: exercise)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Exercises")
        .onAppear {
            Task { await loadExercises() }
        }
    }
    
    private func loadExercises() async {
        exercises = store.allExercises()
        Log.info("Loaded \(exercises.count) exercises")
    }
}

// Reusable row component for exercise list
struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 16) {
            // Exercise icon with difficulty color
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(difficultyColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: exercise.iconSystemName)
                    .font(.title2)
                    .foregroundColor(difficultyColor)
            }
            
            // Exercise info
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                Text(exercise.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(exercise.durationLabel)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    // Difficulty
                    HStack(spacing: 4) {
                        Circle()
                            .fill(difficultyColor)
                            .frame(width: 6, height: 6)
                        Text(exercise.difficulty.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var difficultyColor: Color {
        switch exercise.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
}
