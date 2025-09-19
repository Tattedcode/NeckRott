//
//  OnboardingThree.swift
//  ForwardNeckV1
//
//  Third onboarding screen for ForwardNeck info
//

import SwiftUI

struct OnboardingThree: View {
    @State private var showCards = Array(repeating: false, count: 4)
    @State private var showMotivationalMessage = false
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // "Did you know?" title
            Text("Did you know?")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Information cards
            VStack(spacing: 12) {
                InfoCard(
                    icon: "hourglass",
                    text: "the average person spends over 4 hours a day on their phone"
                )
                .opacity(showCards[0] ? 1 : 0)
                .offset(y: showCards[0] ? 0 : 20)
                .animation(.easeOut(duration: 0.4), value: showCards[0])
                
                InfoCard(
                    icon: "iphone",
                    text: "most of us check our phones 58 times per day without realizing"
                )
                .opacity(showCards[1] ? 1 : 0)
                .offset(y: showCards[1] ? 0 : 20)
                .animation(.easeOut(duration: 0.4), value: showCards[1])
                
                InfoCard(
                    icon: "mascot1",
                    text: "too much screen time messes with your memory, focus, and sleep"
                )
                .opacity(showCards[2] ? 1 : 0)
                .offset(y: showCards[2] ? 0 : 20)
                .animation(.easeOut(duration: 0.4), value: showCards[2])
                
                InfoCard(
                    icon: "eye",
                    text: "7 out of 10 people get tired, dry eyes from staring at screens"
                )
                .opacity(showCards[3] ? 1 : 0)
                .offset(y: showCards[3] ? 0 : 20)
                .animation(.easeOut(duration: 0.4), value: showCards[3])
            }
            
            // Motivational message
            Text("we're here to help you be more mindful of these habits")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .opacity(showMotivationalMessage ? 1 : 0)
                .offset(y: showMotivationalMessage ? 0 : 20)
                .animation(.easeOut(duration: 0.4), value: showMotivationalMessage)
        }
        
        // Parent container that centers the grouped content vertically
        VStack(spacing: 0) {
            Spacer(minLength: 60) // Add space at the top
            content
                .padding(.horizontal, 24)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            // Show cards with 0.5 second delay between each
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showCards[i] = true
                    }
                    // Add haptic feedback for each card appearance
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            
            // Show motivational message after all cards
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(showCards.count) * 0.5 + 0.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showMotivationalMessage = true
                }
            }
        }
    }
}

// MARK: - Info Card Component

struct InfoCard: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Check if it's a system icon or asset image
            if icon.hasPrefix("mascot") {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    OnboardingThree()
}

