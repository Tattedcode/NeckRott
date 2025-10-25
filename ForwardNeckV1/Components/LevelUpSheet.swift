//
//  LevelUpSheet.swift
//  ForwardNeckV1
//
//  Level up celebration sheet with social sharing
//

import SwiftUI

struct LevelUpSheet: View {
    let level: Level
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var showShareSheet = false
    @State private var shareText = ""
    
    var body: some View {
        ZStack {
            // Background
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Level Icon with Animation
                ZStack {
                    Circle()
                        .fill(level.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showConfetti ? 1.1 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)
                    
                    Image(systemName: level.iconSystemName)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(level.color)
                        .scaleEffect(showConfetti ? 1.2 : 1.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)
                }
                
                // Level Information
                VStack(spacing: 12) {
                    Text("Level Up!")
                        .font(.largeTitle.bold())
                        .foregroundColor(Theme.primaryText)
                    
                    Text("Level \(level.number)")
                        .font(.title.bold())
                        .foregroundColor(level.color)
                    
                    Text(level.title)
                        .font(.title2.bold())
                        .foregroundColor(Theme.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text(level.description)
                        .font(.body)
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Share Button
                    Button(action: {
                        prepareShareText()
                        showShareSheet = true
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                            
                            Text("Share Your Achievement")
                                .font(.headline.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [level.color, level.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    
                    // Continue Button
                    Button(action: {
                        onDismiss()
                        
                        // Add haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Text("Continue")
                            .font(.headline.bold())
                            .foregroundColor(Theme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            
            // Confetti Overlay
            if showConfetti {
                ConfettiOverlay(isActive: $showConfetti)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            // Start confetti animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    showConfetti = true
                }
            }
            
            // Add celebration haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
    }
    
    private func prepareShareText() {
        shareText = """
        🎉 Level Up! 🎉
        
        I just reached Level \(level.number) - \(level.title) in Neckrot! 
        
        \(level.description)
        
        Join me in building better neck health habits! 💪
        
        #Neckrot #LevelUp #NeckHealth #Fitness
        """
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    LevelUpSheet(
        level: Level(
            id: 5,
            number: 5,
            xpRequired: 400,
            title: "Neck Warrior",
            description: "You've completed 5 levels of neck strengthening exercises! Your dedication is paying off.",
            iconSystemName: "shield.fill",
            colorHex: "#FF6B6B"
        ),
        onDismiss: {}
    )
}
