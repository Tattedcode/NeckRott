//
//  SummaryCard.swift
//  ForwardNeckV1
//
//  Compact stats card used on the progress screen.
//

import SwiftUI

struct SummaryCard: View {
    let title: String
    let value: String
    let systemIcon: String
    let accentColor: Color

    private var textPrimary: Color { .black }
    private var secondaryText: Color { .black.opacity(0.7) }

    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 12)
                .fill(accentColor.opacity(0.35))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: systemIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                )
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(secondaryText)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(textPrimary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.clear)
    }
}
