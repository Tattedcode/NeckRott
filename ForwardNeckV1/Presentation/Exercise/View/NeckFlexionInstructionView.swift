//
//  NeckFlexionInstructionView.swift
//  ForwardNeckV1
//
//  Detailed instruction view for Neck Flexion exercise with images.
//

import SwiftUI

struct NeckFlexionInstructionView: View {
    // MARK: - Properties
    
    /// The neck flexion exercise being displayed
    let exercise: Exercise
    
    /// Closure called when user dismisses the view
    let onDismiss: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background gradient matching app theme
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Header section with title
                    headerSection
                    
                    // Instruction images section
                    imagesSection
                    
                    // Instructions list section
                    instructionsSection
                    
                    // Spacer at bottom
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    onDismiss?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black.opacity(0.7))
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    /// Header with exercise title (no icon, no description)
    private var headerSection: some View {
        VStack(spacing: 8) {
            // Exercise title
            Text("Neck Flexion")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            // Difficulty badge
            HStack(spacing: 6) {
                Circle()
                    .fill(difficultyColor)
                    .frame(width: 8, height: 8)
                Text(exercise.difficulty.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.cardBackground)
            .clipShape(Capsule())
        }
        .padding(.bottom, 4)
    }
    
    // MARK: - Images Section
    
    /// Section displaying instruction images side by side with arrow, center-aligned
    private var imagesSection: some View {
        HStack(spacing: 0) {
            // Leading spacer to center the content
            Spacer()
            
            // First instruction image - flexion1.png
            Image("flexion1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Arrow between images indicating progression
            Image(systemName: "arrow.right")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
                .padding(.horizontal, 16)
            
            // Second instruction image - flexion2.png
            Image("flexion2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Trailing spacer to center the content
            Spacer()
        }
        .padding(.vertical, 8)
        // Uses parent's 20pt horizontal padding for equal spacing on both sides
    }
    
    // MARK: - Instructions Section
    
    /// Section displaying step-by-step instructions
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Instructions list
            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                instructionRow(stepNumber: index + 1, instruction: instruction)
            }
        }
        .padding(20)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    /// Individual instruction row with step number
    private func instructionRow(stepNumber: Int, instruction: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            // Step number badge
            Text("\(stepNumber)")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    LinearGradient(
                        colors: [Theme.gradientBrightPink, Theme.gradientBrightBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
            
            // Instruction text
            Text(instruction)
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.9))
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    /// Color for difficulty badge
    private var difficultyColor: Color {
        switch exercise.difficulty {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NeckFlexionInstructionView(
            exercise: Exercise(
                title: "Neck Flexion",
                description: "Gentle neck stretch to relieve tension",
                instructions: [
                    "Begin by sitting comfortably in a chair or on the floor.",
                    "Tilt your head forward until you feel a gentle stretch at the back of your neck.",
                    "Hold this position for 15-30 seconds.",
                    "Repeat"
                ],
                durationSeconds: 10,
                iconSystemName: "person.fill.viewfinder",
                difficulty: .easy
            ),
            onDismiss: nil
        )
    }
}

