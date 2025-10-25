import SwiftUI

/// Renders a single mocked screen preview with debug logging so we know when it appears
struct ScreenPreviewMock<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Backing gradient so the phone frame pops
                LinearGradient(
                    colors: [Color.black.opacity(0.25), Color.black.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

                // Phone bezel with actual content inside
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.black.opacity(0.6))
                            .padding(4)
                            .overlay(
                                content
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .padding(10)
                            )
                    )
                    .padding(4)
            }
            .aspectRatio(0.47, contentMode: .fit)
            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
            .onAppear { Log.info("ScreenPreviewMock appeared for \(title)") }

            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
                .kerning(1.2)
        }
        .frame(maxWidth: .infinity)
    }
}
