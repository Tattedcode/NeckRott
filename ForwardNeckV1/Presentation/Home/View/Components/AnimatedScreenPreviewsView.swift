import SwiftUI
import Combine

/// Wrapper so we can feed different screen previews into the animated carousel
struct ScreenPreviewItem: Identifiable {
    let id: String
    let title: String
    let buildView: () -> AnyView

    init(id: String, title: String, @ViewBuilder content: @escaping () -> some View) {
        self.id = id
        self.title = title
        self.buildView = { AnyView(content()) }
    }
}

/// Animated carousel that cycles through screen previews to replace the mascot hero
struct AnimatedScreenPreviewsView: View {
    let items: [ScreenPreviewItem]
    let autoPlayInterval: TimeInterval

    @State private var currentIndex: Int = 0
    @State private var autoPlayCancellable: AnyCancellable?

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                item.buildView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 32)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            let titles = items.map { $0.title }
            Log.info("AnimatedScreenPreviewsView appeared with items=\(titles)")
            startAutoPlayIfNeeded()
        }
        .onDisappear {
            Log.info("AnimatedScreenPreviewsView disappeared, cancelling autoplay")
            autoPlayCancellable?.cancel()
            autoPlayCancellable = nil
        }
    }

    /// Auto-advance the carousel so it feels alive
    private func startAutoPlayIfNeeded() {
        autoPlayCancellable?.cancel()
        guard items.count > 1 else {
            Log.info("AnimatedScreenPreviewsView autoplay skipped because items count=\(items.count)")
            return
        }

        autoPlayCancellable = Timer.publish(every: autoPlayInterval, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                withAnimation(.easeInOut(duration: 0.6)) {
                    currentIndex = (currentIndex + 1) % items.count
                }
            }
    }
}
