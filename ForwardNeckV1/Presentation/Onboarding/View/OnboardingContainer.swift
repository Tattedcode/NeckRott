//
//  OnboardingContainer.swift
//  NeckRotV1
//
//  Hosts the onboarding flow and delegates logic to the view model.
//

import SwiftUI

struct OnboardingContainer: View {
    @StateObject var viewModel: OnboardingFlowViewModel
    let onComplete: () -> Void
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        // Start from first onboarding screen (index 0)
        _viewModel = StateObject(wrappedValue: OnboardingFlowViewModel(initialScreen: 0))
    }
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerBar
                scrollableContent
            }
        }
        .safeAreaInset(edge: .bottom) {
            footer
        }
    }
}

#Preview {
    OnboardingContainer(onComplete: { print("Onboarding completed") })
}
