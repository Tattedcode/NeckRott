//
//  StreakLineChartView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

/// Streak line chart component for showing streak progression over time
/// Part of F-007: Charts & Analytics feature
struct StreakLineChartView: View {
    let streakData: StreakOverTime
    let isEmpty: Bool
    
    /// Animation state for line drawing
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Chart title and description
            VStack(alignment: .leading, spacing: 4) {
                Text("Streak Progress")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.85))
                
                Text("Your streak progression over time")
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
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }
    
    /// Empty state view when no data is available
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No Streak Data")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Build a streak by checking your posture daily!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
    
    /// Chart content view with line graph
    private var chartContentView: some View {
        VStack(spacing: 12) {
            // Stats row
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(streakData.currentStreak)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Max")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(streakData.maxStreak)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(Int(streakData.averageStreak))")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            // Line chart
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let maxValue = max(streakData.maxStreak, 1)
                
                ZStack {
                    // Grid lines
                    gridLines(width: width, height: height, maxValue: maxValue)
                    
                    // Line path
                    linePath(width: width, height: height, maxValue: maxValue)
                        .opacity(animationProgress)
                    
                    // Data points
                    dataPoints(width: width, height: height, maxValue: maxValue)
                }
            }
            .frame(height: 120)
        }
    }
    
    /// Grid lines for the chart
    /// - Parameters:
    ///   - width: Chart width
    ///   - height: Chart height
    ///   - maxValue: Maximum value for scaling
    /// - Returns: Grid lines view
    private func gridLines(width: CGFloat, height: CGFloat, maxValue: Int) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<5) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)
                    .offset(y: CGFloat(index) * height / 4)
            }
        }
    }
    
    /// Line path for the streak data
    /// - Parameters:
    ///   - width: Chart width
    ///   - height: Chart height
    ///   - maxValue: Maximum value for scaling
    /// - Returns: Line path view
    private func linePath(width: CGFloat, height: CGFloat, maxValue: Int) -> some View {
        Path { path in
            guard !streakData.streakData.isEmpty else { return }
            
            let stepX = width / CGFloat(streakData.streakData.count - 1)
            
            for (index, dataPoint) in streakData.streakData.enumerated() {
                let x = CGFloat(index) * stepX
                let y = height - (CGFloat(dataPoint.value) / CGFloat(maxValue)) * height
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    /// Data points for the chart
    /// - Parameters:
    ///   - width: Chart width
    ///   - height: Chart height
    ///   - maxValue: Maximum value for scaling
    /// - Returns: Data points view
    private func dataPoints(width: CGFloat, height: CGFloat, maxValue: Int) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(streakData.streakData.enumerated()), id: \.offset) { index, dataPoint in
                let stepX = width / CGFloat(streakData.streakData.count - 1)
                let x = CGFloat(index) * stepX
                let y = height - (CGFloat(dataPoint.value) / CGFloat(maxValue)) * height
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 4, height: 4)
                    )
                    .position(x: x, y: y)
                    .opacity(animationProgress)
                    .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.05), value: animationProgress)
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        
        VStack {
            // Preview with data
            StreakLineChartView(
                streakData: StreakOverTime(
                    streakData: [
                        ChartDataPoint(date: Date(), value: 5, label: "Mon"),
                        ChartDataPoint(date: Date(), value: 7, label: "Tue"),
                        ChartDataPoint(date: Date(), value: 3, label: "Wed"),
                        ChartDataPoint(date: Date(), value: 8, label: "Thu"),
                        ChartDataPoint(date: Date(), value: 6, label: "Fri")
                    ],
                    maxStreak: 8,
                    currentStreak: 6,
                    averageStreak: 5.8
                ),
                isEmpty: false
            )
            
            // Preview empty state
            StreakLineChartView(
                streakData: StreakOverTime(streakData: [], maxStreak: 0, currentStreak: 0, averageStreak: 0.0),
                isEmpty: true
            )
        }
        .padding()
    }
}
