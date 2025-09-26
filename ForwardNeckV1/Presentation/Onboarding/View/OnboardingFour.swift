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
    @State private var shakeReasons = false // Controls shake animation when validation fails
    @Binding var hasReasonSelected: Bool
    @Binding var triggerValidation: Bool
    
    private let reasons = [
        "Fix Neckrot",
        "Spend Less Time Scrolling",
        "Sleep Better",
        "Be More Confident",
        "Look Better",
        "Just Curious"
    ]
    
    var body: some View {
        // Group the image, title, and options into a single content stack
        let content = VStack(spacing: 20) {
            // Mascot image
            Image(MascotAssetProvider.resolvedMascotName(for: "mascot1"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title underneath image
            Text("You're here for a reason")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle explaining the purpose
            Text("How can we help you?")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Reason options with animation
            VStack(spacing: 8) {
                ForEach(Array(reasons.enumerated()), id: \.element) { index, reason in
                    ReasonOption(
                        text: reason,
                        isSelected: selectedReasons.contains(reason),
                                onTap: {
                                    // Add haptic feedback for reason selection
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    
                                    if selectedReasons.contains(reason) {
                                        selectedReasons.remove(reason)
                                    } else {
                                        selectedReasons.insert(reason)
                                    }
                                    hasReasonSelected = !selectedReasons.isEmpty
                                }
                    )
                }
            }
            .offset(x: shakeReasons ? -10 : 0)
            .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shakeReasons)
        }
        .onChange(of: triggerValidation) { shouldValidate in
            if shouldValidate {
                Log.info("OnboardingFour validation triggered")
                validateSelection()
                triggerValidation = false
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
            // Show all cards instantly without animation or haptic feedback
            for i in 0..<showCards.count {
                showCards[i] = true
            }
        }
    }

    private func validateSelection() {
        guard hasReasonSelected else {
            Log.info("OnboardingFour no reason selected, triggering shake")
            triggerReasonShake()
            return
        }
        Log.info("OnboardingFour reason already selected, skipping shake")
    }

    private func triggerReasonShake() {
        withAnimation {
            shakeReasons = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeReasons = false
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
    OnboardingFour(hasReasonSelected: .constant(false), triggerValidation: .constant(false))
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
}
