//
//  OnboardingFour.swift
//  ForwardNeckV1
//
//  Fourth onboarding screen for reason selection
//

import SwiftUI

struct OnboardingFour: View {
    @State private var selectedReasons: Set<String> = []
    @State private var showCards = Array(repeating: false, count: 6)
    @Binding var hasReasonSelected: Bool
    
    private let reasons = [
        "fix forward neck",
        "reduce mindless scrolling", 
        "sleep better",
        "be more confident",
        "be more productive",
        "just curious"
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title underneath image
            Text("you're here for a reason")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Reason options with animation
            VStack(spacing: 8) {
                ForEach(Array(reasons.enumerated()), id: \.element) { index, reason in
                    ReasonOption(
                        text: reason,
                        isSelected: selectedReasons.contains(reason),
                        onTap: {
                            if selectedReasons.contains(reason) {
                                selectedReasons.remove(reason)
                            } else {
                                selectedReasons.insert(reason)
                            }
                            // Update the binding to enable/disable continue button
                            hasReasonSelected = !selectedReasons.isEmpty
                        }
                    )
                    .opacity(showCards[index] ? 1 : 0)
                    .offset(y: showCards[index] ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: showCards[index])
                }
            }
        }
        .onAppear {
            // Trigger staggered animations for cards over 0.5 seconds faster (6 cards * 0.08s = 0.48s + 0.4s duration = 0.88s total)
            for i in 0..<showCards.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                    withAnimation {
                        showCards[i] = true
                    }
                }
            }
        }
    }
}

// MARK: - Reason Option Component

struct ReasonOption: View {
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .opacity(isSelected ? 1 : 0)
                    )
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingFour(hasReasonSelected: .constant(false))
}

