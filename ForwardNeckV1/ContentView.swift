//
//  ContentView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true // TEMPORARILY SKIP ONBOARDING FOR TESTING
    
    var body: some View {
        if showOnboarding && !hasCompletedOnboarding {
            OnboardingContainer {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOnboarding = false
                    hasCompletedOnboarding = true
                }
            }
        } else {
            RootTabView()
        }
    }
}

#Preview {
    ContentView()
}
