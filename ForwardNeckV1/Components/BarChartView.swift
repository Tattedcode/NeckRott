//
//  BarChartView.swift
//  ForwardNeckV1
//
//  Lightweight 7-day bar chart. Designed for small data sets and simple visuals.
//

import SwiftUI

public struct BarDatum: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double
    public init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

public struct BarChartView: View {
    public let data: [BarDatum]
    public let maxValue: Double
    public let showValues: Bool

    @State private var animated: Bool = false

    public init(data: [BarDatum], showValues: Bool = true) {
        self.data = data
        self.maxValue = max(data.map { $0.value }.max() ?? 1, 1)
        self.showValues = showValues
    }

    public var body: some View {
        GeometryReader { proxy in
            let columnWidth = max(18, (proxy.size.width - 12 * CGFloat(max(data.count - 1, 0))) / CGFloat(max(data.count, 1)))

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(data) { item in
                    VStack(spacing: 6) {
                        if showValues {
                            Text("\(Int(item.value))")
                                .font(.caption2.bold())
                                .foregroundColor(.white.opacity(0.9))
                                .frame(height: 12)
                        }
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(colors: [Color.blue, Color.pink], startPoint: .top, endPoint: .bottom))
                            .frame(width: columnWidth, height: animated ? barHeight(for: item.value) : 8)
                            .animation(.easeOut(duration: 0.8).delay(Double(index(of: item)) * 0.05), value: animated)
                        Text(item.label)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(height: 10)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 180)
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear { animated = true }
    }

    private func barHeight(for value: Double) -> CGFloat {
        let normalized = value / maxValue
        return max(8, 130 * normalized)
    }

    private func index(of item: BarDatum) -> Int {
        data.firstIndex(where: { $0.id == item.id }) ?? 0
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        BarChartView(data: [
            .init(label: "Mon", value: 2), .init(label: "Tue", value: 4), .init(label: "Wed", value: 3),
            .init(label: "Thu", value: 5), .init(label: "Fri", value: 1), .init(label: "Sat", value: 4), .init(label: "Sun", value: 3)
        ]).padding()
    }
}


