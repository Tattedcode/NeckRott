//
//  MetricRowCard.swift
//  ForwardNeckV1
//
//  Reusable row card for a labeled metric with icon and value.
//

import SwiftUI

public struct MetricRowCard: View {
    public let title: String
    public let systemImage: String
    public let color: Color
    public let value: Int

    public init(title: String, systemImage: String, color: Color, value: Int) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.value = value
    }

    public var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.25))
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(Theme.primaryText)
                    .font(.subheadline)
                Text("\(value)")
                    .foregroundColor(Theme.primaryText)
                    .font(.title3.bold())
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        VStack(spacing: 12) {
            MetricRowCard(title: "Posture Check-Ins", systemImage: "figure.walk", color: .orange, value: 12)
            MetricRowCard(title: "Exercises Done", systemImage: "dumbbell", color: .green, value: 5)
        }.padding()
    }
}


