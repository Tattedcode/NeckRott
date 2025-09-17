//
//  CurrentStreakView.swift
//  ForwardNeckV1
//
//  Reusable component that displays the current streak with animation.
//  Shows as a separate card above the daily progress.
//

import SwiftUI

public struct CurrentStreakView: View {
    // Input value for the current streak count
    public let currentStreak: Int
    
    // Animation state for streak count
    @State private var animatedStreakCount: Int = 0
    @State private var isAnimating: Bool = false
    
    public init(currentStreak: Int) {
        self.currentStreak = currentStreak
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Animated flame icon
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.title)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
            
            // Streak information
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(animatedStreakCount) days")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .contentTransition(.numericText())
            }
            
            Spacer()
            
            // Optional: Add a small achievement indicator if streak is high
            if currentStreak >= 7 {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                    .opacity(isAnimating ? 1.0 : 0.7)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .onAppear {
            // Start the flame animation
            isAnimating = true
            
            // Animate the streak count from 0 to current value
            withAnimation(.easeOut(duration: 1.5)) {
                animatedStreakCount = currentStreak
            }
        }
        .onChange(of: currentStreak) { oldValue, newValue in
            // Animate streak count changes
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedStreakCount = newValue
            }
        }
    }
}

#Preview {
    ZStack { 
        Theme.backgroundGradient.ignoresSafeArea() 
        VStack(spacing: 16) {
            CurrentStreakView(currentStreak: 7)
            CurrentStreakView(currentStreak: 0)
        }
        .padding()
    }
}

