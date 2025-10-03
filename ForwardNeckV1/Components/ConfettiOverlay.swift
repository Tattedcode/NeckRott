//
//  ConfettiOverlay.swift
//  ForwardNeckV1
//
//  Extracted from HomeView.swift for better MVVM organization
//

import SwiftUI

struct ConfettiOverlay: View {
    @Binding var isActive: Bool
    @State private var pieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiPieceView(
                        piece: piece,
                        containerSize: proxy.size,
                        isActive: $isActive
                    )
                }
            }
            .onChange(of: isActive) {
                if isActive {
                    pieces = ConfettiPiece.generate(count: 36, height: proxy.size.height)
                } else {
                    pieces.removeAll()
                }
            }
            .onAppear {
                if isActive {
                    pieces = ConfettiPiece.generate(count: 36, height: proxy.size.height)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let isLeft: Bool
    let startY: CGFloat
    let delay: Double
    let duration: Double
    let size: CGFloat
    let color: Color

    static func generate(count: Int, height: CGFloat) -> [ConfettiPiece] {
        let colors: [Color] = [.pink, .purple, .blue, .yellow, .orange, .green]
        return (0..<count).map { index in
            let isLeft = index.isMultiple(of: 2)
            return ConfettiPiece(
                isLeft: isLeft,
                startY: CGFloat.random(in: 20...(height * 0.5).clamped(to: 20...height)),
                delay: Double.random(in: 0...0.8),
                duration: Double.random(in: 2.6...4.2),
                size: CGFloat.random(in: 8...16),
                color: colors.randomElement() ?? .white
            )
        }
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let containerSize: CGSize
    @Binding var isActive: Bool
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 0.35)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear { startAnimation() }
            .onChange(of: isActive) {
                if isActive {
                    startAnimation()
                } else {
                    opacity = 0
                }
            }
    }

    private func startAnimation() {
        guard isActive else { return }
        let startX = piece.isLeft ? -60.0 : containerSize.width + 60.0
        let endX = piece.isLeft ? containerSize.width + 60.0 : -60.0
        position = CGPoint(x: startX, y: piece.startY)
        rotation = 0
        opacity = 0

        withAnimation(.easeOut(duration: piece.duration).delay(piece.delay)) {
            position = CGPoint(x: endX, y: piece.startY + containerSize.height * 0.85)
        }

        withAnimation(.linear(duration: piece.duration).repeatForever(autoreverses: false).delay(piece.delay)) {
            rotation = piece.isLeft ? 720 : -720
        }

        withAnimation(.easeIn(duration: 0.2).delay(piece.delay)) {
            opacity = 1
        }

        let fadeDelay = piece.delay + max(0, piece.duration - 0.6)
        withAnimation(.easeOut(duration: 0.6).delay(fadeDelay)) {
            opacity = 0
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ConfettiOverlay(isActive: .constant(true))
    }
}

