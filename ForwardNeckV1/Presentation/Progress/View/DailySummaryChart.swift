//
//  DailySummaryChart.swift
//  ForwardNeckV1
//
//  Bar chart summarising the last seven days.
//

import SwiftUI

struct DailySummaryChart: View {
    let entries: [DailyActivity]
    let goal: Int

    private var maxValue: Int {
        max(goal, entries.map { $0.count }.max() ?? 0, 1)
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let labelHeight: CGFloat = 20
            let verticalSpacing: CGFloat = 10
            let barHeight = max(0, totalHeight - (labelHeight * 2) - (verticalSpacing * 2))
            let barWidth = max(16, (geometry.size.width - CGFloat(entries.count - 1) * 12) / CGFloat(entries.count))

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(entries) { entry in
                    VStack(alignment: .center, spacing: verticalSpacing) {
                        Text("\(entry.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(height: labelHeight)

                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.12))
                                .frame(width: barWidth, height: barHeight)

                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.85)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: barWidth, height: max(6, CGFloat(entry.count) / CGFloat(maxValue) * barHeight))
                        }

                        Text(entry.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(height: labelHeight)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }
}
