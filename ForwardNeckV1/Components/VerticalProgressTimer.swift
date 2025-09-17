//
//  VerticalProgressTimer.swift
//  ForwardNeckV1
//
//  A vertical progress bar timer that fills up as time progresses.
//  Shows time remaining and progress with a modern vertical bar design.
//

import SwiftUI

struct VerticalProgressTimer: View {
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
    private let barWidth: CGFloat = 10
    private let barHeight: CGFloat = 60
    
    init(durationSeconds: Int, isPaused: Bool = false, onComplete: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.totalDuration = durationSeconds
        _timeRemaining = State(initialValue: durationSeconds)
        self.isPaused = isPaused
        self.onComplete = onComplete
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Time display
            VStack(spacing: 1) {
                Text(timeString)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Text(isRunning ? "left" : (isPaused ? "paused" : (isCompleted ? "done" : "ready")))
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Vertical progress bar
            ZStack(alignment: .bottom) {
                // Background bar
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: barWidth, height: barHeight)
                
                // Progress bar
                RoundedRectangle(cornerRadius: 6)
                    .fill(progressColor)
                    .frame(width: barWidth, height: progressHeight)
                    .animation(.linear(duration: 1), value: progressHeight)
            }
        }
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
    
    private var progressHeight: CGFloat {
        return barHeight * progress
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
        
        Log.info("Vertical timer started for \(totalDuration) seconds")
    }
    
    private func completeTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isCompleted = true
        
        onComplete()
        Log.info("Vertical timer completed")
    }
    
    // Public methods for external control
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        Log.info("Vertical timer paused")
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
        Log.info("Vertical timer resumed")
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isCompleted = false
        timeRemaining = totalDuration
        Log.info("Vertical timer reset")
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isCompleted = false
        timeRemaining = totalDuration
        
        onCancel()
        Log.info("Vertical timer cancelled")
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        HStack(spacing: 20) {
            VerticalProgressTimer(
                durationSeconds: 90,
                isPaused: false,
                onComplete: { print("Timer completed!") },
                onCancel: { print("Timer cancelled!") }
            )
            
            VerticalProgressTimer(
                durationSeconds: 10,
                isPaused: true,
                onComplete: { print("Timer completed!") },
                onCancel: { print("Timer cancelled!") }
            )
        }
    }
}
