//
//  ProgressRingView.swift
//  ForwardNeckV1
//
//  Reusable circular progress ring using theme colors.
//

import SwiftUI

public struct ProgressRingView: View {
    public let progress: Double // 0...1
    public let size: CGFloat
    public let lineWidth: CGFloat

    @State private var animatedProgress: Double = 0

    public init(progress: Double, size: CGFloat = 140, lineWidth: CGFloat = 14) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(AngularGradient(gradient: Gradient(colors: [Color.blue, Color.pink]), center: .center), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(String(format: "%0.0f%%", animatedProgress * 100))
                .font(.title2.bold())
                .foregroundColor(.white)
                .monospacedDigit()
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

#Preview {
    ZStack {
        Theme.backgroundGradient.ignoresSafeArea()
        ProgressRingView(progress: 0.68)
    }
}


