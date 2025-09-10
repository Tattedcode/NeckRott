//
//  DailyStreakCard.swift
//  ForwardNeckV1
//
//  Reusable component that shows daily reminder/streak progress.
//

import SwiftUI

public struct DailyStreakCard: View {
    // Input values so the card can be reused in different screens
    public let completed: Int
    public let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    public init(completed: Int, total: Int) {
        self.completed = completed
        self.total = total
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Daily Streak Progress")
                    .font(.headline)
                    .foregroundColor(Theme.primaryText)
                Spacer()
                Button(action: { Log.info("DailyStreakCard close tapped") }) {
                    Image(systemName: "xmark")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                        .padding(6)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Text("You’ve checked your posture \(completed)/\(total) times today")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: max(8, progressWidth), height: 10)
            }

            HStack {
                Spacer()
                Text(String(format: "%0.0f%%", progress * 100))
                    .font(.caption.bold())
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.lightBlue.opacity(0.6), Color.lightPink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 8)
    }

    private var progressWidth: CGFloat {
        let pct = CGFloat(progress)
        return 240 * pct
    }
}

#Preview {
    ZStack { Theme.backgroundGradient.ignoresSafeArea() ; DailyStreakCard(completed: 3, total: 5).padding() }
}


