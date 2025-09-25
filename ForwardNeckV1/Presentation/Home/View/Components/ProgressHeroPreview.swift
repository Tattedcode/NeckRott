import SwiftUI

struct ProgressHeroPreview: View {
    var body: some View {
        ZStack {
            Theme.cardBackground
                .overlay(
                    LinearGradient(
                        colors: [Color.green.opacity(0.4), Color.cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 16) {
                Text("Progress Tracker")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    progressRow(label: "Mon", value: "90%", color: .green)
                    progressRow(label: "Tue", value: "65%", color: .yellow)
                    progressRow(label: "Wed", value: "40%", color: .orange)
                    progressRow(label: "Thu", value: "100%", color: .green)
                    progressRow(label: "Fri", value: "70%", color: .yellow)
                }
                .padding(16)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(20)
        }
    }

    private func progressRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
        .overlay(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.4))
                    .frame(width: geometry.size.width * CGFloat(Double(value.dropLast()) ?? 0) / 100.0)
            }
                .allowsHitTesting(false)
        )
    }
}

