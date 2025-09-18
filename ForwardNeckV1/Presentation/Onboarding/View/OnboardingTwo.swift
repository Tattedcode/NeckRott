//
//  OnboardingTwo.swift
//  ForwardNeckV1
//
//  Second onboarding screen for screen time selection
//

import SwiftUI

struct OnboardingTwo: View {
    @Binding var selectedScreenTime: Int // 0-8 for 1-9+ hours
    @State private var selectedOption: Int = 0 // Local state for UI
    
    private let options = ["1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "6 hours", "7 hours", "8 hours", "9+ hours"]
    
    private var screenTimeText: String {
        return options[selectedOption]
    }
    
    private var warningMessage: (text: String, color: Color)? {
        switch selectedOption {
        case 0...1: // 1-2 hours
            return ("perfectly normal", .green)
        case 2...5: // 3-6 hours
            return ("this is a significant percentage of your life", .orange)
        case 6...8: // 7-9+ hours
            return ("Extremely dangerous and unhealthy", .red)
        default:
            return nil
        }
    }
    
    private var mascotImage: String {
        switch selectedOption {
        case 0...1: // 1-2 hours
            return "mascot3"
        case 2...5: // 3-6 hours
            return "mascot2"
        case 6...8: // 7-9+ hours
            return "mascot1"
        default:
            return "mascot1"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Mascot image
            Image(mascotImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.3), value: mascotImage)
            
            // Screen time display
            Text(screenTimeText)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            // Slider with 3 discrete options
            VStack(spacing: 8) {
                // Custom slider with 3 positions
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue.opacity(0.3))
                            .frame(height: 8)
                        
                        // Progress track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(selectedOption) / 8.0, height: 8)
                        
                        // Slider thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(radius: 2)
                            .offset(x: (geometry.size.width - 24) * CGFloat(selectedOption) / 8.0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let progress = max(0, min(1, value.location.x / geometry.size.width))
                                        let newOption = Int(round(progress * 8))
                                        
                                        if newOption != selectedOption {
                                            // Haptic feedback when slider position changes
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                            
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedOption = newOption
                                            }
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 24)
            }
            .frame(maxWidth: 280) // Smaller width as requested
                
            // Warning message
            if let warning = warningMessage {
                Text(warning.text)
                    .font(.caption)
                    .foregroundColor(warning.color)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            // Initialize local state from binding
            selectedOption = selectedScreenTime
        }
        .onChange(of: selectedOption) { newValue in
            // Update binding when local state changes
            selectedScreenTime = newValue
        }
    }
}

#Preview {
    OnboardingTwo(selectedScreenTime: .constant(0))
}
