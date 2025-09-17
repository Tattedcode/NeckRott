//
//  LongestStreakView.swift
//  ForwardNeckV1
//
//  A reusable component to display the longest streak with animations.
//  Shows the user's best streak achievement with a trophy icon.
//

import SwiftUI

struct LongestStreakView: View {
    public let longestStreak: Int
    
    @State private var animatedStreakCount: Int = 0
    @State private var isAnimating: Bool = false // For trophy icon animation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Longest Streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(animatedStreakCount) days")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                // Optional crown for very high streaks
                if longestStreak >= 30 {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .onAppear {
            isAnimating = true // Start trophy animation
            withAnimation(.easeOut(duration: 1.5)) {
                animatedStreakCount = longestStreak // Animate count up
            }
        }
        .onChange(of: longestStreak) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedStreakCount = newValue // Animate count changes
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        VStack(spacing: 20) {
            LongestStreakView(longestStreak: 15)
            LongestStreakView(longestStreak: 45)
        }
        .padding()
    }
}

