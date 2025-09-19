//
//  OnboardingSeven.swift
//  ForwardNeckV1
//
//  Seventh onboarding screen for age selection
//

import SwiftUI

struct OnboardingSeven: View {
    @Binding var triggerValidation: Bool
    @State private var selectedAge: String? = nil
    @State private var shakeAgeField = false
    @State private var showCards = Array(repeating: false, count: 6)
    let onAgeSelected: (String) -> Void
    
    private let ageOptions = ["18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    
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
            
            // Title underneath image
            Text("what's your age?")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle explaining why we need age
            Text("This will help us tailor our recommendations")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Age options with animation
            VStack(spacing: 8) {
                ForEach(Array(ageOptions.enumerated()), id: \.element) { index, age in
                            AgeOption(
                                text: age,
                                isSelected: selectedAge == age,
                                onTap: {
                                    // Add haptic feedback for age selection
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    selectedAge = age
                                }
                            )
                }
            }
            .offset(x: shakeAgeField ? -10 : 0)
            .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shakeAgeField)
        }
        .onChange(of: triggerValidation) { shouldValidate in
            if shouldValidate {
                validateInput()
                triggerValidation = false
            }
        }
        .onChange(of: selectedAge) { _ in
            // Just update the UI state, don't automatically proceed
            // The continue button will handle the navigation
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
            // Show all cards instantly without animation or haptic feedback
            for i in 0..<showCards.count {
                showCards[i] = true
            }
        }
    }
    
    private func validateInput() {
        if selectedAge == nil {
            // Just trigger shake animation, no alert
            triggerAgeFieldShake()
        } else {
            // Validation successful - save the data and let navigation continue
            onAgeSelected(selectedAge ?? "")
        }
    }
    
    private func triggerAgeFieldShake() {
        withAnimation {
            shakeAgeField = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeAgeField = false
        }
    }
}

// MARK: - Age Option Component

struct AgeOption: View {
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
    OnboardingSeven(
        triggerValidation: .constant(false),
        onAgeSelected: { age in
            print("Age: \(age)")
        }
    )
}

