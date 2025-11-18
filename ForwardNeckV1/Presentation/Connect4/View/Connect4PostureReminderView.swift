//
//  Connect4PostureReminderView.swift
//  NeckRotV1
//
//  Posture reminder label for Connect 4 game.
//

import SwiftUI

struct Connect4PostureReminderView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.stand")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
            
            Text("Sit up straight with a straight back")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

#Preview {
    Connect4PostureReminderView()
        .padding()
        .background(Theme.backgroundGradient)
}

