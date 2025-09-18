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
    
    private var lifeImpactYears: Double {
        // Assuming 80 year lifespan, 16 hours awake per day
        let awakeHoursPerYear = 16 * 365
        let totalAwakeHours = awakeHoursPerYear * 80
        let screenTimeHours = Double(yearlyHours) * 80
        return screenTimeHours / Double(awakeHoursPerYear)
    }
    
    private var lifePercentage: Double {
        let awakeHoursPerYear = 16 * 365
        return (Double(yearlyHours) / Double(awakeHoursPerYear)) * 100
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
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Brain mascot image
            Image("mascot1") // Using brain mascot
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title underneath image
            Text("this adds up quickly...")
                .font(.title.bold())
                .foregroundColor(.white)
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
                .animation(.easeOut(duration: 0.4).delay(0.0), value: showCards)
                
                // Weekly card
                CalculationCard(
                    label: "weekly",
                    value: weeklyRemainingHours > 0 ? "\(weeklyDays) days, \(weeklyRemainingHours) hours" : "\(weeklyDays) days",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: showCards)
                
                // Monthly card
                CalculationCard(
                    label: "monthly",
                    value: monthlyDays > 0 ? "\(monthlyWeeks) weeks, \(monthlyDays) days" : "\(monthlyWeeks) weeks",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: showCards)
                
                // Yearly card
                CalculationCard(
                    label: "yearly",
                    value: "\(yearlyMonths) months",
                    isHighlighted: false
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showCards)
                
                // Life impact card (highlighted in red)
                CalculationCard(
                    label: "life impact",
                    value: String(format: "%.1f years lost", lifeImpactYears),
                    isHighlighted: true
                )
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.4), value: showCards)
            }
            
            // Warning message
            Text("that's \(String(format: "%.1f", lifePercentage))% of your waking life each year...")
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .opacity(showCards ? 1 : 0)
                .offset(y: showCards ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showCards)
            
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
            // Trigger animations after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    showCards = true
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
                .font(.subheadline)
                .foregroundColor(isHighlighted ? .red : .white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
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
