//
//  ExerciseCountdownTimer.swift
//  ForwardNeckV1
//
//  Reusable countdown timer component for exercises with circular progress.
//

import SwiftUI

struct ExerciseCountdownTimer: View {
    // Timer state
    @State private var timeRemaining: Int
    @State private var isRunning: Bool = false
    @State private var isPaused: Bool = false
    @State private var isCompleted: Bool = false
    @State private var timer: Timer?
    
    // Callbacks
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    // Visual properties
    private let totalDuration: Int
    private let lineWidth: CGFloat = 8
    private let size: CGFloat = 120
    
    // Auto-start option
    private let autoStart: Bool
    
    init(durationSeconds: Int, autoStart: Bool = false, onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.totalDuration = durationSeconds
        self.timeRemaining = durationSeconds
        self.autoStart = autoStart
        self.onComplete = onComplete
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Circular progress timer
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
                    .frame(width: size, height: size)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: progress)
                
                // Time remaining text
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.title.bold())
                        .foregroundColor(.black)
                    
                    Text("remaining")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                }
            }
            
            // Control buttons
            VStack(spacing: 12) {
                if !isRunning && !isCompleted {
                    // Start button
                    Button(action: startTimer) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start")
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .clipShape(Capsule())
                    }
                } else if isRunning || isPaused {
                    // Running/Paused state buttons - vertical layout
                    VStack(spacing: 8) {
                        // Pause/Resume button
                        Button(action: togglePause) {
                            HStack {
                                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                Text(isPaused ? "Resume" : "Pause")
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .clipShape(Capsule())
                        }
                        
                        // Reset button
                        Button(action: resetTimer) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset")
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .clipShape(Capsule())
                        }
                        
                        // Cancel button
                        Button(action: cancelTimer) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Cancel")
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .clipShape(Capsule())
                        }
                    }
                // Removed completion state - goes directly back to home view
                }
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .onAppear {
            Log.info("ExerciseCountdownTimer appeared - Duration: \(totalDuration) seconds")
            if autoStart {
                startTimer()
            }
        }
        .onDisappear {
            // Clean up timer when view disappears
            timer?.invalidate()
        }
    }
    
    // MARK: - Computed Properties
    
    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        isRunning = true
        isPaused = false
        isCompleted = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeTimer()
            }
        }
        
        Log.info("Exercise timer started for \(totalDuration) seconds")
    }
    
    private func togglePause() {
        if isPaused {
            // Resume timer
            isPaused = false
            isRunning = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    completeTimer()
                }
            }
            
            Log.info("Exercise timer resumed")
        } else {
            // Pause timer
            isPaused = true
            isRunning = false
            timer?.invalidate()
            timer = nil
            
            Log.info("Exercise timer paused")
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        isCompleted = false
        timeRemaining = totalDuration
        
        Log.info("Exercise timer reset")

        // Immediately restart to avoid leaving the timer idle on the reset screen
        startTimer()
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        isCompleted = false
        timeRemaining = totalDuration
        
        onCancel()
        Log.info("Exercise timer cancelled")
    }
    
    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        // Don't set isCompleted = true, go directly back to home view
        
        onComplete()
        Log.info("Exercise timer completed")
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Preview with 30 seconds
            ExerciseCountdownTimer(
                durationSeconds: 30,
                onComplete: { print("Exercise completed!") },
                onCancel: { print("Exercise cancelled!") }
            )
            
            // Preview with 2 minutes
            ExerciseCountdownTimer(
                durationSeconds: 120,
                onComplete: { print("Exercise completed!") },
                onCancel: { print("Exercise cancelled!") }
            )
        }
        .padding()
    }
}
