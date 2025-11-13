//
//  ExerciseTimerSheet.swift
//  ForwardNeckV1
//
//  Extracted from HomeView.swift for better MVVM organization
//

import SwiftUI

struct ExerciseTimerSheet: View {
    let exercise: Exercise
    let timeSlot: ExerciseTimeSlot? // Optional time slot to identify quick workout vs full workout
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    @State private var hasStarted = false
    @State private var timeRemaining: Int
    @StateObject private var timerHelper = TimerHelper()
    
    init(exercise: Exercise, timeSlot: ExerciseTimeSlot? = nil, onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.exercise = exercise
        self.timeSlot = timeSlot
        self.onComplete = onComplete
        self.onCancel = onCancel
        _timeRemaining = State(initialValue: exercise.durationSeconds)
    }
    
    var body: some View {
        ZStack {
            // Background gradient matching app theme
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with close button (matching full workout view)
                topBar
                
                Spacer()
                
                // Main content (centered vertically, matching full workout view)
                VStack(spacing: 24) {
                    // Exercise images at top (always visible, matching full workout view)
                    imagesSection
                        .frame(maxHeight: 240)
                    
                    // Exercise title (always visible)
                    Text(exercise.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    // Instructions below images and title (always visible, matching full workout view)
                    instructionsSection
                    
                    // Timer or Start Button below instructions (matching full workout view)
                    if hasStarted {
                        // Timer is running - show countdown with progress ring
                        ZStack {
                            // Circular progress ring
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 8)
                                .frame(width: 160, height: 160)
                            
                            // Progress circle
                            Circle()
                                .trim(from: 0, to: progress)
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
                                .animation(.linear(duration: 1), value: progress)
                            
                            // Timer number
                            Text("\(timeRemaining)")
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(.black)
                                .monospacedDigit()
                        }
                        .padding(.top, 8)
                    } else {
                        // Timer not running - show start button
                        startButton
                    }
                }
                .padding(.horizontal, 20)
                .offset(y: hasStarted ? -40 : 0) // Move content up slightly when timer starts
                .animation(.easeInOut(duration: 0.3), value: hasStarted)
                
                Spacer()
            }
        }
        .onAppear {
            Log.debug("ExerciseTimerSheet appeared for exercise: \(exercise.title)")
        }
        .onDisappear {
            // Clean up timer when view disappears
            timerHelper.stop()
        }
    }
    
    // MARK: - Top Bar
    
    /// Top bar with close button (matching full workout view)
    private var topBar: some View {
        HStack {
            Spacer()
            
            Button(action: {
                // Clean up timer before canceling
                timerHelper.stop()
                onCancel()
            }) {
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
        .padding(.horizontal, 20)
    }
    
    // MARK: - Header Section (removed - title now shown in main VStack)
    
    // MARK: - Images Section
    
    /// Section displaying instruction images side by side with arrow, center-aligned
    private var imagesSection: some View {
        HStack(spacing: 0) {
            // Leading spacer to center the content
            Spacer()
            
            // First instruction image
            Image(imageName1)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Arrow between images indicating progression
            Image(systemName: "arrow.right")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 16)
            
            // Second instruction image
            Image(imageName2)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Trailing spacer to center the content
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Instructions Section
    
    /// Section displaying step-by-step instructions (always visible, matching full workout view)
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Instructions list (matching full workout view - no section header)
            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                instructionRow(stepNumber: index + 1, instruction: instruction)
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    /// Individual instruction row with step number (matching full workout view style)
    private func instructionRow(stepNumber: Int, instruction: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // Step number badge - matching full workout view style
            Text("\(stepNumber)")
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
    
    // MARK: - Start Button
    
    /// Start button (matching full workout view style)
    private var startButton: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                hasStarted = true
            }
            // Start the countdown timer when button is pressed
            startTimer()
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
    
    // MARK: - Timer Methods
    
    /// Start the countdown timer
    private func startTimer() {
        // Use the timer helper to manage the countdown
        timerHelper.start(
            duration: exercise.durationSeconds,
            onTick: { remaining in
                timeRemaining = remaining
            },
            onComplete: {
                onComplete()
                Log.info("Exercise timer completed: \(exercise.title)")
            }
        )
        
        Log.info("Exercise timer started for \(exercise.durationSeconds) seconds")
    }
    
    // MARK: - Helpers
    
    /// Calculate progress for the countdown ring (0.0 to 1.0)
    private var progress: Double {
        guard exercise.durationSeconds > 0 else { return 0 }
        let elapsed = Double(exercise.durationSeconds - timeRemaining)
        return elapsed / Double(exercise.durationSeconds)
    }
    
    /// Color for difficulty badge
    private var difficultyColor: Color {
        switch exercise.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    /// Get first image name based on exercise title
    private var imageName1: String {
        let titleLower = exercise.title.lowercased()
        
        if titleLower.contains("chin") || titleLower.contains("tuck") {
            return "chintuck1"
        } else if titleLower == "neck tilts" || titleLower.contains("neck tilt") {
            return "necktilt1"
        } else if titleLower.contains("neck flexion") || (titleLower.contains("flexion") && !titleLower.contains("tilt")) {
            return "flexion1"
        } else if titleLower.contains("wall angel") || (titleLower.contains("wall") && titleLower.contains("angel")) {
            return "angel1"
        } else {
            return "flexion1" // Default fallback
        }
    }
    
    /// Get second image name based on exercise title
    private var imageName2: String {
        let titleLower = exercise.title.lowercased()
        
        if titleLower.contains("chin") || titleLower.contains("tuck") {
            return "chintuck2"
        } else if titleLower == "neck tilts" || titleLower.contains("neck tilt") {
            return "necktilt2"
        } else if titleLower.contains("neck flexion") || (titleLower.contains("flexion") && !titleLower.contains("tilt")) {
            return "flexion2"
        } else if titleLower.contains("wall angel") || (titleLower.contains("wall") && titleLower.contains("angel")) {
            return "angel2"
        } else {
            return "flexion2" // Default fallback
        }
    }
}

// MARK: - Timer Helper

/// Helper class to manage timer state without struct capture issues
@MainActor
class TimerHelper: ObservableObject {
    private var timer: Timer?
    private var currentTime: Int = 0
    private var onTick: ((Int) -> Void)?
    private var onComplete: (() -> Void)?
    
    func start(duration: Int, onTick: @escaping (Int) -> Void, onComplete: @escaping () -> Void) {
        // Stop any existing timer
        stop()
        
        // Store callbacks
        self.onTick = onTick
        self.onComplete = onComplete
        currentTime = duration
        
        // Start countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.currentTime > 0 {
                    self.currentTime -= 1
                    self.onTick?(self.currentTime)
                } else {
                    // Timer completed
                    self.stop()
                    self.onComplete?()
                }
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        onTick = nil
        onComplete = nil
    }
}

#Preview {
    ExerciseTimerSheet(
        exercise: Exercise(
            id: UUID(),
            title: "Neck Flexion",
            description: "Gentle neck stretch to relieve tension",
            instructions: [
                "Begin by sitting comfortably in a chair or on the floor.",
                "Tilt your head forward until you feel a gentle stretch at the back of your neck.",
                "Hold this position for 15-30 seconds.",
                "Repeat"
            ],
            durationSeconds: 30,
            iconSystemName: "person.fill.viewfinder",
            difficulty: .easy
        ),
        timeSlot: .morning, // Preview with quick workout to show animated ring
        onComplete: {},
        onCancel: {}
    )
}
