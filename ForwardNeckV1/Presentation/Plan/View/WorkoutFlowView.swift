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
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.1))
                    )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Exercise View
    
    private var exerciseView: some View {
        VStack(spacing: 24) {
            if let currentExercise = viewModel.currentExercise {
                // Exercise images at top
                exerciseImages(for: currentExercise)
                    .frame(maxHeight: 180)
                
                // Exercise name
                Text(currentExercise.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                // Instructions below images and title
                VStack(alignment: .leading, spacing: 16) {
                    // Instructions list
                    ForEach(Array(currentExercise.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .center, spacing: 16) {
                            // Step number badge - matching instruction view style
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(
                                    LinearGradient(
                                        colors: [Theme.gradientBrightPink, Theme.gradientBrightBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                            
                            // Instruction text
                            Text(instruction)
                                .font(.system(size: 16))
                                .foregroundColor(.black.opacity(0.9))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                    }
                }
                .padding(20)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Timer or Start Button below instructions
                if viewModel.isTimerRunning {
                    // Timer is running - show countdown with progress ring
                    ZStack {
                        // Circular progress ring
                        Circle()
                            .stroke(Color.black.opacity(0.1), lineWidth: 8)
                            .frame(width: 160, height: 160)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: timerProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [Theme.gradientBrightPink, Theme.gradientBrightBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timerProgress)
                        
                        // Timer number
                        Text("\(viewModel.timeRemaining)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.black)
                            .monospacedDigit()
                    }
                    .padding(.top, 8)
                } else {
                    // Timer not running - show start button
                    Button(action: {
                        viewModel.startExerciseTimer()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 24, weight: .bold))
                            Text("Start")
                                .font(.system(size: 28, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 60)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.5, blue: 1.0),
                                    Color(red: 0.1, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    // MARK: - Exercise Images Helper
    
    /// Get exercise images based on exercise title
    private func exerciseImages(for exercise: Exercise) -> some View {
        let titleLower = exercise.title.lowercased()
        
        if titleLower.contains("chin") || titleLower.contains("tuck") {
            return AnyView(
                HStack(spacing: 0) {
                    Spacer()
                    Image("chintuck1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal, 16)
                    
                    Image("chintuck2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Spacer()
                }
            )
        } else if titleLower == "neck tilts" || titleLower.contains("neck tilt") {
            return AnyView(
                HStack(spacing: 0) {
                    Spacer()
                    Image("necktilt1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal, 16)
                    
                    Image("necktilt2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Spacer()
                }
            )
        } else if titleLower.contains("neck flexion") || (titleLower.contains("flexion") && !titleLower.contains("tilt")) {
            return AnyView(
                HStack(spacing: 0) {
                    Spacer()
                    Image("flexion1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal, 16)
                    
                    Image("flexion2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Spacer()
                }
            )
        } else if titleLower.contains("wall angel") || (titleLower.contains("wall") && titleLower.contains("angel")) {
            return AnyView(
                HStack(spacing: 0) {
                    Spacer()
                    Image("angel1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.horizontal, 16)
                    
                    Image("angel2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Spacer()
                }
            )
        } else {
            // Fallback to emoji
            return AnyView(
                Text(exerciseEmoji(for: exercise.title))
                    .font(.system(size: 120))
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
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
                .foregroundColor(.black)
            
            // Countdown
            Text("\(viewModel.timeRemaining)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.black)
                .monospacedDigit()
            
            // Next exercise preview
            if let nextExercise = viewModel.nextExercise {
                VStack(spacing: 8) {
                    Text("Next up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Text(nextExercise.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
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
                .foregroundColor(.black.opacity(0.8))
            
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
    
    /// Calculate progress for the countdown ring (0.0 to 1.0)
    private var timerProgress: Double {
        guard let currentExercise = viewModel.currentExercise else { return 0 }
        let totalDuration = currentExercise.durationSeconds
        guard totalDuration > 0 else { return 0 }
        let elapsed = Double(totalDuration - viewModel.timeRemaining)
        return elapsed / Double(totalDuration)
    }
    
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

