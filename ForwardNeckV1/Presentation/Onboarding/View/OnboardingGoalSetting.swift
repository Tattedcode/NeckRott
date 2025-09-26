//
//  OnboardingGoalSetting.swift
//  ForwardNeckV1
//
//  Screen time goal setting view
//

import SwiftUI

struct OnboardingGoalSetting: View {
    @Binding var selectedGoal: Int
    let currentScreenTime: Int // Current screen time from previous screen (0-8 for 1-9+ hours)
    @State private var localGoal: Int = 3 // Default to 3 hours
    @State private var showContent = false
    
    // Calculate time savings based on current usage vs goal
    private var dailySavings: Int {
        let currentHours = currentScreenTime + 1 // Convert 0-8 to 1-9+ hours
        return max(0, currentHours - localGoal) // How much they'll save by reducing to goal
    }
    
    private var weeklySavings: Int {
        return dailySavings * 7
    }
    
    private var feedbackMessage: String {
        let currentHours = currentScreenTime + 1 // Convert 0-8 to 1-9+ hours
        
        if dailySavings == 0 {
            if currentHours <= localGoal {
                return "you're already at a healthy level! keep it up"
            } else {
                return "that's \(currentHours) hours per day - let's reduce it"
            }
        } else if dailySavings <= 2 {
            return "good start! you'll save \(dailySavings) hours per day (\(weeklySavings) hours weekly)"
        } else if dailySavings <= 4 {
            return "great! you'll save \(dailySavings) hours per day (\(weeklySavings) hours weekly)"
        } else {
            return "excellent! you'll save \(dailySavings) hours per day (\(weeklySavings) hours weekly)"
        }
    }
    
    private var feedbackColor: Color {
        let currentHours = currentScreenTime + 1 // Convert 0-8 to 1-9+ hours
        
        if dailySavings == 0 {
            if currentHours <= localGoal {
                return .green // Already at healthy level
            } else {
                return .red // No savings, need to reduce
            }
        } else if dailySavings <= 2 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Brain mascot image
            Image(MascotAssetProvider.resolvedMascotName(for: "mascot1"))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title
            Text("set your screen time goal")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("what would be a healthy daily target for you?")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // Selected time display
            Text("\(localGoal) hours")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Slider component
            VStack(spacing: 8) {
                // Custom slider with 9 positions (0-8 hours)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)
                        
                        // Progress track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(localGoal) / 8.0, height: 8)
                        
                        // Slider thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(radius: 2)
                            .offset(x: (geometry.size.width - 24) * CGFloat(localGoal) / 8.0)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newProgress = (value.location.x / geometry.size.width)
                                        let newGoal = min(max(0, Int((newProgress * 8).rounded())), 8)
                                        if newGoal != localGoal {
                                            localGoal = newGoal
                                            // Add haptic feedback
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    }
                            )
                    }
                    .frame(height: 24)
                }
                .frame(height: 24)
                
                // Slider labels
                HStack {
                    Text("0h")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("8h")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: 280)
            
            // Feedback message
            Text(feedbackMessage)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(feedbackColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .opacity(showContent ? 1 : 0)
        .offset(y: showContent ? 0 : 20)
        .animation(.easeOut(duration: 0.6), value: showContent)
        
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
            localGoal = selectedGoal
            
            // Show content with animation
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .onChange(of: localGoal) { newValue in
            // Update binding when local state changes
            selectedGoal = newValue
        }
    }
}

#Preview {
    OnboardingGoalSetting(selectedGoal: .constant(3), currentScreenTime: 4) // 5 hours current usage
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
