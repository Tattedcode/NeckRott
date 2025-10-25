import SwiftUI

struct SettingsHeroPreview: View {
    var body: some View {
        ZStack {
            Theme.cardBackground
                .overlay(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.5), Color.red.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 16) {
                Text("Settings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    settingsRow(icon: "bell.fill", title: "Reminders", value: "8:00 AM")
                    settingsRow(icon: "target", title: "Daily Goal", value: "3 exercises")
                    settingsRow(icon: "person.crop.circle", title: "Profile", value: "Edit")
                    settingsRow(icon: "gearshape", title: "Advanced", value: "Open")
                }
                .padding(16)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(24)
        }
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.white.opacity(0.8))
        }
        .padding(.vertical, 6)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
                .offset(y: 16)
                .opacity(title == "Advanced" ? 0 : 1)
            , alignment: .bottom
        )
    }
}

