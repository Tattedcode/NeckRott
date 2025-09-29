//
//  OnboardingScreenTimeMath.swift
//  ForwardNeckV1
//
//  Screen time math calculations view
//

import SwiftUI

struct OnboardingScreenTimeMath: View {
    let selectedScreenTime: Int
    @State private var showCards = false
    @State private var bounceText = false
    
    // Calculate values based on selected screen time (0-8 for 1-9+ hours)
    private var dailyHours: Int {
        return selectedScreenTime + 1 // Convert 0-8 to 1-9
    }
    
    private var weeklyHours: Int {
        return dailyHours * 7
    }
    
    private var monthlyHours: Int {
        return dailyHours * 30 // Approximate month
    }
    
    private var yearlyHours: Int {
        return dailyHours * 365
    }
    
    private var weeklyDays: Int {
        return weeklyHours / 24
    }
    
    private var weeklyRemainingHours: Int {
        return weeklyHours % 24
    }
    
    private var monthlyWeeks: Int {
        return monthlyHours / (24 * 7)
    }
    
    private var monthlyDays: Int {
        return (monthlyHours % (24 * 7)) / 24
    }
    
    private var yearlyMonths: Int {
        return yearlyHours / (24 * 30)
    }
    
    private var mascotImage: String {
        switch selectedScreenTime {
        case 0, 1:
            return "mascot4"
        case 2, 3:
            return "mascot3"
        case 4, 5:
            return "mascot2"
        case 6, 7, 8:
            return "mascot1"
        default:
            return "mascot4"
        }
    }
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Brain mascot image - moved up to fill gap above
            Image(MascotAssetProvider.resolvedMascotName(for: mascotImage))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.top, -40) // Move image up to fill gap above
                .animation(.easeInOut(duration: 0.3), value: mascotImage)
            
            // Title underneath image
            Text("This adds up quickly...")
                .font(.title.bold())
                .foregroundColor(Theme.primaryText)
                .multilineTextAlignment(.center)
            
            // Calculation cards
            VStack(spacing: 8) {
                // Daily card
                CalculationCard(
                    label: "daily",
                    value: "\(dailyHours) hours",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.0), value: showCards)
                
                // Weekly card
                CalculationCard(
                    label: "weekly",
                    value: weeklyRemainingHours > 0 ? "\(weeklyDays) days, \(weeklyRemainingHours) hours" : "\(weeklyDays) days",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: showCards)
                
                // Monthly card
                CalculationCard(
                    label: "monthly",
                    value: monthlyDays > 0 ? "\(monthlyWeeks) weeks, \(monthlyDays) days" : "\(monthlyWeeks) weeks",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showCards)
                
                // Yearly card
                CalculationCard(
                    label: "yearly",
                    value: "\(yearlyMonths) months",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showCards)
                
            }
            
                // Warning message
            Text("That is a big part of your life spent on your phone")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .opacity(showCards ? 1 : 0)
                    .offset(y: showCards ? 0 : 20)
                    .scaleEffect(bounceText ? 1.05 : 1.0)
                    .animation(.easeOut(duration: 0.6).delay(0.8), value: showCards)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: bounceText)
            
            Spacer()
                .frame(height: 20)
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
            // Trigger animations with 0.5 second delay between each card (same as Did you know screen)
            let delays = [0.0, 0.5, 1.0, 1.5, 2.0] // 0.5 second intervals for each card
            
            for (index, delay) in delays.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    if index == 0 {
                        // Only trigger the main animation once
                        withAnimation {
                            showCards = true
                        }
                    }
                    // Add haptic feedback for each card appearance
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            
            // Trigger bounce animation for the warning text after it appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    bounceText = true
                }
            }
        }
    }
}

// MARK: - Calculation Card Component

struct CalculationCard: View {
    let label: String
    let value: String
    let isHighlighted: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(isHighlighted ? .red : .white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.body.bold())
                .foregroundColor(isHighlighted ? .red : .white)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? Color.red.opacity(0.1) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHighlighted ? Color.red : Color.clear, lineWidth: 1)
                )
        )
    }
}

#Preview {
    OnboardingScreenTimeMath(selectedScreenTime: 4) // 5 hours
}
