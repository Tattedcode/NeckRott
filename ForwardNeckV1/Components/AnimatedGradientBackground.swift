//
//  AnimatedGradientBackground.swift
//  ForwardNeckV1
//
//  A lightweight, reusable animated gradient used for onboarding screens only.
//

import SwiftUI

struct AnimatedGradientBackground: View {
    var body: some View {
        // Static shared gradient (no animation)
        Theme.backgroundGradient
    }
}

#Preview {
	AnimatedGradientBackground().ignoresSafeArea()
}


