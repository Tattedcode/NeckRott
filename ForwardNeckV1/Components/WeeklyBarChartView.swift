//
//  WeeklyBarChartView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

/// Weekly bar chart component for showing posture checks vs misses
/// Part of F-007: Charts & Analytics feature
struct WeeklyBarChartView: View {
    let data: [WeeklyAnalytics]
    let isEmpty: Bool
    
    /// Animation state for bar growth
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart title and description
            VStack(alignment: .leading, spacing: 4) {
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                
                Text("Posture checks vs misses this week")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            if isEmpty {
                // Empty state
                emptyStateView
            } else {
                // Chart content
                chartContentView
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    /// Empty state view when no data is available
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Data Yet")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Start checking your posture to see your weekly progress!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    /// Chart content view with bars
    private var chartContentView: some View {
        VStack(spacing: 12) {
            // Chart bars
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, week in
                    VStack(spacing: 8) {
                        // Bar for posture checks
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue)
                                .frame(width: 30, height: max(4, CGFloat(week.postureChecks) * 4))
                                .scaleEffect(y: animationProgress)
                                .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1), value: animationProgress)
                            
                            Text("\(week.postureChecks)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        
                        // Bar for misses
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 30, height: max(4, CGFloat(week.postureMisses) * 4))
                                .scaleEffect(y: animationProgress)
                                .animation(.easeInOut(duration: 0.8).delay(Double(index) * 0.1 + 0.2), value: animationProgress)
                            
                            Text("\(week.postureMisses)")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Week label
                        Text("W\(index + 1)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Checks")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 8, height: 8)
                    Text("Misses")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        
        VStack {
            // Preview with data
            WeeklyBarChartView(
                data: [
                    WeeklyAnalytics(
                        weekStart: Date(),
                        weekEnd: Date(),
                        postureChecks: 25,
                        postureMisses: 10,
                        exercisesCompleted: 12,
                        exercisesMissed: 2,
                        currentStreak: 5,
                        dailyBreakdown: []
                    )
                ],
                isEmpty: false
            )
            
            // Preview empty state
            WeeklyBarChartView(data: [], isEmpty: true)
        }
        .padding()
    }
}
