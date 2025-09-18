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
    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var shakeNameField = false
    @State private var shakeAgeField = false
    let onNameAndAgeSelected: (String, String) -> Void
    
    private let ageOptions = ["18-24", "25-34", "35-44", "45-54", "55-64", "65+"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Name input field
            VStack(alignment: .leading, spacing: 8) {
                Text("what's your name?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("enter your name", text: $name)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                    )
                    .foregroundColor(.white)
                    .offset(x: shakeNameField ? -10 : 0)
                    .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shakeNameField)
            }
            
            // Age selection
            VStack(alignment: .leading, spacing: 8) {
                Text("what's your age?")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    ForEach(ageOptions, id: \.self) { age in
                        AgeOption(
                            text: age,
                            isSelected: selectedAge == age,
                            onTap: {
                                selectedAge = age
                            }
                        )
                    }
                }
                .offset(x: shakeAgeField ? -10 : 0)
                .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shakeAgeField)
            }
        }
        .onChange(of: triggerValidation) { shouldValidate in
            if shouldValidate {
                validateInput()
                triggerValidation = false
            }
        }
        .onChange(of: selectedAge) { _ in
            // When age is selected, check if we can proceed
            if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedAge != nil {
                onNameAndAgeSelected(name.trimmingCharacters(in: .whitespacesAndNewlines), selectedAge ?? "")
            }
        }
        .alert("Missing Information", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func validateInput() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            alertMessage = "Please enter your name to continue."
            triggerNameFieldShake()
            showingAlert = true
        } else if selectedAge == nil {
            alertMessage = "Please select your age to continue."
            triggerAgeFieldShake()
            showingAlert = true
        }
    }
    
    private func triggerNameFieldShake() {
        withAnimation {
            shakeNameField = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeNameField = false
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
            .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingSeven(
        triggerValidation: .constant(false),
        onNameAndAgeSelected: { name, age in
            print("Name: \(name), Age: \(age)")
        }
    )
}

