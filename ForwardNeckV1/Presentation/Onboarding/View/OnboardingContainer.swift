//
//  OnboardingContainer.swift
//  ForwardNeckV1
//
//  Hosts the onboarding flow and delegates logic to the view model.
//

import SwiftUI

struct OnboardingContainer: View {
    @StateObject var viewModel: OnboardingFlowViewModel
    let onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        _viewModel = StateObject(wrappedValue: OnboardingFlowViewModel())
    }

    var body: some View {
        ZStack {
            AnimatedGradientBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                scrollableContent
                footer
            }
        }
    }
}

#Preview {
    OnboardingContainer(onComplete: { print("Onboarding completed") })
}
