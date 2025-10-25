//
//  OnboardingOne.swift
//  ForwardNeckV1
//
//  First onboarding screen with typewriter animation
//

import SwiftUI

struct OnboardingOne: View {
    var body: some View {
        VStack(spacing: 8) {
            // Title with typewriter animation
        TypewriterTextView(
            text: "Welcome To Neckrot",
                onComplete: {
                    // Start showing subtitle after title completes
                    withAnimation(.easeInOut(duration: 0.5)) {
                        // This will be handled by the parent view
                    }
                }
            )
            .font(.largeTitle.bold())
            .foregroundColor(Theme.primaryText)
            .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Typewriter Text View

struct TypewriterTextView: View {
    let text: String
    let onComplete: () -> Void
    
    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTyping()
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    private func startTyping() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { _ in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1
                
                // Enhanced haptic feedback for each character
                let character = String(text[index])
                
                // Different haptic feedback based on character type
                if character == " " {
                    // Light tap for spaces
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                } else if character.lowercased().rangeOfCharacter(from: .letters) != nil {
                    // Medium tap for letters
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                } else {
                    // Light tap for punctuation
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            } else {
                timer?.invalidate()
                // Final haptic feedback when typing completes
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                onComplete()
            }
        }
    }
}

// MARK: - First Screen Typewriter View

struct FirstScreenTypewriterView: View {
    @State private var showSubtitle = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Title with typewriter animation
            TypewriterTextView(
                text: "Welcome To Neckrot",
                onComplete: {
                    // Start showing subtitle after title completes
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSubtitle = true
                    }
                }
            )
            .font(.largeTitle.bold())
            .foregroundColor(Theme.primaryText)
            .multilineTextAlignment(.center)
            
            // Subtitle that appears after title completes
            if showSubtitle {
                // Updated subtitle copy and layout so the full sentence fits in one line
                TypewriterTextView(
                    text: "Using your phone alot makes your neck rot.\nLet's save it",
                    onComplete: {
                        // Animation complete
                    }
                )
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
    }
}

// MARK: - Phone Mockup View

struct PhoneMockupView: View {
    var body: some View {
        Image(MascotAssetProvider.resolvedMascotName(for: "mascot1"))
            .resizable()
            .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Legal Text

struct LegalText: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("by continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    // Handle terms action
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Button("Privacy Policy") {
                    // Handle privacy action
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

#Preview {
    OnboardingOne()
}
