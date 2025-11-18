//
//  OnboardingTwo.swift
//  NeckRotV1
//
//  Second onboarding screen for screen time selection
//

import SwiftUI

struct OnboardingTwo: View {
    @Binding var selectedScreenTime: Int // 0-7 for 1-8 hours
    @State private var selectedOption: Int = 0 // Local state for UI
    
    private let options = ["1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "6 hours", "7 hours", "8 hours"]
    
    private var screenTimeDisplayText: String {
        return "\(options[selectedOption]) of phone use"
    }
    
    private var warningMessage: (text: String, color: Color)? {
        switch selectedOption {
        case 0...1: // 1-2 hours
            return ("This is normal for your neck", .green)
        case 2...5: // 3-6 hours
            return ("This could affect your neck later in life", .orange)
        case 6...7: // 7-8 hours
            return ("Extremely dangerous and unhealthy for your neck", .red)
        default:
            return nil
        }
    }
    
    private var mascotImage: String {
        // Map screen time to mascot: 1 hour = mascot4, 8 hours = mascot1
        // Inverse relationship: less time = higher mascot number (better health)
        switch selectedOption {
        case 0: // 1 hour
            return "mascot4"
        case 1: // 2 hours
            return "mascot4"
        case 2: // 3 hours
            return "mascot3"
        case 3: // 4 hours
            return "mascot3"
        case 4: // 5 hours
            return "mascot2"
        case 5: // 6 hours
            return "mascot2"
        case 6: // 7 hours
            return "mascot1"
        case 7: // 8 hours
            return "mascot1"
        default:
            return "mascot1"
        }
    }
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Mascot image - dynamically changes based on selected screen time (ignore user preference during onboarding)
            Image(MascotAssetProvider.resolvedMascotName(for: mascotImage, ignorePreference: true))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.3), value: mascotImage)
            
            // Screen time display
            Text(screenTimeDisplayText)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
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
                            .frame(width: geometry.size.width * CGFloat(selectedOption) / 7.0, height: 8)
                        
                        // Slider thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(radius: 2)
                            .offset(x: (geometry.size.width - 24) * CGFloat(selectedOption) / 7.0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let progress = max(0, min(1, value.location.x / geometry.size.width))
                                        let newOption = Int(round(progress * 7))
                                        
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
                    .fontWeight(.bold)
                    .foregroundColor(warning.color)
                    .multilineTextAlignment(.center)
            }
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
            // Initialize local state from binding
            selectedOption = selectedScreenTime
        }
        .onChange(of: selectedOption) { oldValue, newValue in
            // Update binding when local state changes
            selectedScreenTime = newValue
        }
    }
}

#Preview {
    OnboardingTwo(selectedScreenTime: .constant(0))
}
