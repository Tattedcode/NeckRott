//
//  DailySummaryChart.swift
//  ForwardNeckV1
//
//  Line chart summarising the last seven days.
//

import SwiftUI

struct DailySummaryChart: View {
    let entries: [DailyActivity]
    let goal: Int

    private var maxValue: Int {
        let maxEntryValue = entries.map { $0.count }.max() ?? 0
        return max(maxEntryValue, 1) // Remove goal cap, only use actual data max
    }
    
    private var chartData: [(x: CGFloat, y: CGFloat)] {
        let width: CGFloat = 1.0
        return entries.enumerated().map { index, entry in
            let x = CGFloat(index) / CGFloat(entries.count - 1) * width
            let y = CGFloat(entry.count) / CGFloat(maxValue)
            return (x: x, y: y)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let labelHeight: CGFloat = 20
            let verticalSpacing: CGFloat = 10
            let chartHeight = max(0, totalHeight - (labelHeight * 2) - (verticalSpacing * 2))
            let chartWidth = geometry.size.width - 32 // Account for padding

            VStack(spacing: verticalSpacing) {
                // Value labels at top
                HStack {
                    ForEach(entries) { entry in
                        Text("\(entry.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black.opacity(0.85))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: labelHeight)
                
                // Line chart area
                ZStack {
                    // Background grid lines
                    ForEach(0..<5) { i in
                        let y = CGFloat(i) / 4.0
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 1)
                            .offset(y: (y - 0.5) * chartHeight)
                    }
                    
                    // Line chart path with area fill
                    Path { path in
                        guard !chartData.isEmpty else { return }
                        
                        let width = chartWidth
                        let height = chartHeight
                        
                        // Create the line path
                        path.move(to: CGPoint(
                            x: chartData[0].x * width,
                            y: height - chartData[0].y * height
                        ))
                        
                        for i in 1..<chartData.count {
                            path.addLine(to: CGPoint(
                                x: chartData[i].x * width,
                                y: height - chartData[i].y * height
                            ))
                        }
                        
                        // Close the path to create area fill
                        path.addLine(to: CGPoint(x: chartData.last!.x * width, y: height))
                        path.addLine(to: CGPoint(x: chartData[0].x * width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Line stroke on top
                    Path { path in
                        guard !chartData.isEmpty else { return }
                        
                        let width = chartWidth
                        let height = chartHeight
                        
                        path.move(to: CGPoint(
                            x: chartData[0].x * width,
                            y: height - chartData[0].y * height
                        ))
                        
                        for i in 1..<chartData.count {
                            path.addLine(to: CGPoint(
                                x: chartData[i].x * width,
                                y: height - chartData[i].y * height
                            ))
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Data points - REMOVED
                    // ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                    //     Circle()
                    //         .fill(Color.purple.opacity(0.9))
                    //         .frame(width: 8, height: 8)
                    //         .offset(
                    //             x: point.x * chartWidth - 4,
                    //             y: chartHeight - point.y * chartHeight - 4
                    //         )
                    // }
                }
                .frame(height: chartHeight)
                
                // Day labels at bottom
                HStack {
                    ForEach(entries) { entry in
                        Text(entry.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: labelHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }
}
