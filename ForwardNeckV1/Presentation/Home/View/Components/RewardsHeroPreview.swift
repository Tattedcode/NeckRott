import SwiftUI

struct RewardsHeroPreview: View {
    var body: some View {
        ZStack {
            Theme.cardBackground
                .overlay(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.45), Color.blue.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 16) {
                Text("Level 6 Rewards")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    rewardBadge(title: "Coins", value: "+150", color: .yellow)
                    rewardBadge(title: "Skin", value: "Neon", color: .pink)
                    rewardBadge(title: "Badge", value: "Focus", color: .blue)
                }

                VStack(spacing: 12) {
                    progressMeter(title: "To Level 7", progress: 0.75)
                    progressMeter(title: "Streak Boost", progress: 0.45)
                }
            }
            .padding(24)
        }
    }

    private func rewardBadge(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(color.opacity(0.35))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(value.prefix(1)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                )
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.75))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func progressMeter(title: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 16)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.6))
                    .frame(width: 200 * progress, height: 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

