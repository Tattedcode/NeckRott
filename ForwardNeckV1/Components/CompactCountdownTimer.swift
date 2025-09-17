//
//  CompactCountdownTimer.swift
//  ForwardNeckV1
//
//  A compact circular countdown timer for displaying next to exercise information.
//  Shows time remaining in a small circle with progress indication.
//

import SwiftUI

struct CompactCountdownTimer: View {
    // Timer state
    @State private var timeRemaining: Int
    @State private var isRunning: Bool = false
    @State private var isCompleted: Bool = false
    @State private var timer: Timer?
    
    // External pause state
    let isPaused: Bool
    
    // Callbacks
    let onComplete: () -> Void
    let onCancel: () -> Void
    
    // Visual properties
    private let totalDuration: Int
    private let lineWidth: CGFloat = 6
    private let size: CGFloat = 100
    
    init(durationSeconds: Int, isPaused: Bool = false, onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.totalDuration = durationSeconds
        _timeRemaining = State(initialValue: durationSeconds)
        self.isPaused = isPaused
        self.onComplete = onComplete
        self.onCancel = onCancel
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)
            
            // Time text
            VStack(spacing: 2) {
                Text(timeString)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(isRunning ? "left" : (isPaused ? "paused" : (isCompleted ? "done" : "ready")))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            // Auto-start the timer when it appears
            startTimer()
        }
        .onChange(of: isPaused) { oldValue, newValue in
            if newValue {
                pauseTimer()
            } else {
                resumeTimer()
            }
        }
    }
    
    private var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    private var progressColor: Color {
        if isCompleted { return .green }
        if isPaused { return .orange }
        return .blue
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Timer Methods
    
    private func startTimer() {
        isRunning = true
        isCompleted = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeTimer()
            }
        }
        
        Log.info("Compact timer started for \(totalDuration) seconds")
    }
    
    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isCompleted = true
        
        onComplete()
        Log.info("Compact timer completed")
    }
    
    // Public methods for external control
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        Log.info("Compact timer paused")
    }
    
    func resumeTimer() {
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeTimer()
            }
        }
        Log.info("Compact timer resumed")
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isCompleted = false
        timeRemaining = totalDuration
        Log.info("Compact timer reset")
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isCompleted = false
        timeRemaining = totalDuration
        
        onCancel()
        Log.info("Compact timer cancelled")
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        HStack(spacing: 20) {
            CompactCountdownTimer(
                durationSeconds: 90,
                isPaused: false,
                onComplete: { print("Timer completed!") },
                onCancel: { print("Timer cancelled!") }
            )
            
            CompactCountdownTimer(
                durationSeconds: 10,
                isPaused: true,
                onComplete: { print("Timer completed!") },
                onCancel: { print("Timer cancelled!") }
            )
        }
    }
}
