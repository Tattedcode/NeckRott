import SwiftUI

struct HomeHeroPreview: View {
    var body: some View {
        ZStack {
            Theme.cardBackground
                .overlay(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 16) {
                Text("ForwardNeck")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("neck health")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                        Text("87%")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    let baseMascot = "mascot3"
                    let resolvedMascot = MascotAssetProvider.resolvedMascotName(for: baseMascot)
                    Image(resolvedMascot)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                }

                Divider().background(Color.white.opacity(0.1))

                HStack(spacing: 16) {
                    summaryTile(title: "xp", value: "2540")
                    summaryTile(title: "level", value: "6")
                }
            }
            .padding(20)
        }
    }

    private func summaryTile(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

