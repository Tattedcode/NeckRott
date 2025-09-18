//
//  OnboardingTwo.swift
//  ForwardNeckV1
//
//  Second onboarding screen for screen time selection
//

import SwiftUI

struct OnboardingTwo: View {
    @State private var selectedOption: Int = 1 // 0 = 1-3h, 1 = 4-6h, 2 = 7-9+h
    
    private let options = ["1-3 hours", "4-6 hours", "7-9+ hours"]
    
    private var screenTimeText: String {
        return options[selectedOption]
    }
    
    private var warningMessage: (text: String, color: Color)? {
        switch selectedOption {
        case 0:
            return ("perfectly normal", .green)
        case 1:
            return ("this is a significant percentage of your life", .orange)
        case 2:
            return ("Extremely dangerous and unhealthy", .red)
        default:
            return nil
        }
    }
    
    private var mascotImage: String {
        switch selectedOption {
        case 0:
            return "mascot3" // 1-3 hours
        case 1:
            return "mascot2" // 4-6 hours
        case 2:
            return "mascot1" // 7-9+ hours
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
                            .frame(width: geometry.size.width * CGFloat(selectedOption) / 2.0, height: 8)
                        
                        // Slider thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(radius: 2)
                            .offset(x: (geometry.size.width - 24) * CGFloat(selectedOption) / 2.0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let progress = max(0, min(1, value.location.x / geometry.size.width))
                                        let newOption = Int(round(progress * 2))
                                        
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
    }
}

#Preview {
    OnboardingTwo()
}
