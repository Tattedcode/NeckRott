//
//  ContentView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

private enum OnboardingKeys {
    static let hasCompleted = "hasCompletedOnboarding"
}

struct ContentView: View {
    @AppStorage(OnboardingKeys.hasCompleted) private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                RootTabView()
            } else {
                OnboardingContainer {
                    hasCompletedOnboarding = true
                }
            }
        }
        .animation(.easeInOut, value: hasCompletedOnboarding)
        .onAppear {
            // Force start from home view
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    ContentView()
}
