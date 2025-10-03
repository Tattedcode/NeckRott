//
//  OnboardingContainer+Mockups.swift
//  ForwardNeckV1
//
//  Placeholder content for legacy mockup steps.
//

import SwiftUI

extension OnboardingContainer {
    var progressChartMockup: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground)
                .frame(width: 200, height: 300)

            VStack(spacing: 16) {
                Text("Progress Tracking")
                    .font(.headline)
                    .foregroundColor(.white)

                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(0..<7) { _ in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.blue)
                                .frame(width: 20, height: CGFloat.random(in: 20...100))
                        }
                    }

                    Text("Weekly Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    var rewardsMockup: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground)
                .frame(width: 200, height: 300)

            VStack(spacing: 16) {
                Text("Rewards")
                    .font(.headline)
                    .foregroundColor(.white)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)

                Text("Earn points for healthy habits")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
}
