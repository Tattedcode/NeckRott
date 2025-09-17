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
        // Cap progress at 100% to prevent UI stretching
        return min(1.0, Double(completed) / Double(total))
    }
    
    private var progressText: String {
        if completed >= total {
            return "🎉 Goal achieved! You've completed \(completed) exercises today"
        } else {
            return "You've completed \(completed)/\(total) exercises today"
        }
    }
    
    private var percentageText: String {
        if completed >= total {
            return "100%"
        } else {
            return String(format: "%0.0f%%", progress * 100)
        }
    }

    public init(completed: Int, total: Int) {
        self.completed = completed
        self.total = total
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Daily Progress")
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

            Text(progressText)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.18))
                    .frame(height: 10)
                RoundedRectangle(cornerRadius: 8)
                    .fill(completed >= total ? Color.green : Color.white) // Green when goal achieved
                    .frame(width: max(8, min(progressWidth, 240)), height: 10) // Cap width at 240
            }

            HStack {
                Spacer()
                Text(percentageText)
                    .font(.caption.bold())
                    .foregroundColor(completed >= total ? .green : .white.opacity(0.9))
            }
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.blue.opacity(0.6), Color.pink.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
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


