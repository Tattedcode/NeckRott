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
//Test 
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
            // Reset onboarding for testing - remove this line when done
            hasCompletedOnboarding = false
        }
    }
}

#Preview {
    ContentView()
}
