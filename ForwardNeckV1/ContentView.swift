//
//  ContentView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var showOnboarding = false
    
    var body: some View {
        if showOnboarding {
            OnboardingContainer {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOnboarding = false
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
