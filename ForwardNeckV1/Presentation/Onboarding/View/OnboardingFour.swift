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
        // Group the image, title, and options into a single content stack
        let content = VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title underneath image
            Text("you're here for a reason")
                .font(.title.bold())
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
                            hasReasonSelected = !selectedReasons.isEmpty
                        }
                    )
                    .opacity(showCards[index] ? 1 : 0)
                    .offset(y: showCards[index] ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.08), value: showCards[index])
                }
            }
        }
        
        // Parent container that centers the grouped content vertically
        VStack(spacing: 0) {
            Spacer(minLength: 60) // Increased from 0 to 60 to push content down
            content
                .padding(.horizontal, 24) // keep consistent side padding with container
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
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
                
                // Tick mark instead of circle
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .green : .blue)
            }
            .padding(12)
            .background(isSelected ? Color.green.opacity(0.2) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingFour(hasReasonSelected: .constant(false))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
}
