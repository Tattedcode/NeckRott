//
//  PreviousDayCardView.swift
//  ForwardNeckV1
//
//  Extracted from HomeView.swift for better MVVM organization
//

import SwiftUI

struct PreviousDayCardView: View {
    let card: PreviousDaySummary

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let mascotSize = height * 0.72
            let percentageFont = height * 0.3
            let dateFont = height * 0.11
            let valueOnly = card.percentageText.replacingOccurrences(of: "%", with: "")

            HStack(alignment: .center, spacing: 8) {
                // Mascot sits on the left and gets as much space as possible
                Image(card.mascotAssetName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: -1, y: 1)
                    .frame(width: mascotSize, height: mascotSize)
                    .accessibilityHidden(true)

                // Percentage is huge, with the date tucked underneath
                VStack(alignment: .trailing, spacing: 4) {
                    ZStack(alignment: .trailing) {
                        Text("%")
                            .font(.system(size: percentageFont, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .opacity(0)
                        
                        HStack(spacing: 0) {
                            Spacer()
                            Text(valueOnly)
                                .font(.system(size: percentageFont, weight: .heavy, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("%")
                                .font(.system(size: percentageFont, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }

                    Text(card.label)
                        .font(.system(size: dateFont, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
                .padding(.trailing, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(width: 180, height: 96)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.label) \(card.percentageText)")
        .onAppear {
            Log.debug("PreviousDayCardView displayed for \(card.label)")
        }
    }
}

#Preview {
    PreviousDayCardView(
        card: PreviousDaySummary(
            date: Date(),
            label: "Today",
            completionCount: 3,
            goal: 5,
            percentage: 60,
            mascotAssetName: "mascot3"
        )
    )
    .background(Color.black)
}

