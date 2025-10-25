//
//  OnboardingVideoDemo.swift
//  ForwardNeckV1
//
//  Video demonstration screen for onboarding
//

import SwiftUI
import AVKit

struct OnboardingVideoDemo: View {
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var isLoading = true
    @State private var hasError = false
    @State private var showControls = true
    
    var body: some View {
        VStack(spacing: 20) {
            // Video Player Section
            ZStack {
                if hasError {
                    // Fallback UI when video fails to load
                    VStack(spacing: 16) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Video Preview")
                            .font(.title2.bold())
                            .foregroundColor(Theme.primaryText)
                        
                        Text("See Neckrot in action")
                            .font(.body)
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.1))
                    )
                } else {
                    // Video Player
                    VideoPlayer(player: player)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            // Custom controls overlay
                            VStack {
                                Spacer()
                                
                                if showControls {
                                    HStack {
                                        Button(action: togglePlayPause) {
                                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: replayVideo) {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .padding(12)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                                }
                            }
                            .opacity(showControls ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: showControls)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showControls.toggle()
                            }
                        }
                }
                
                // Loading indicator
                if isLoading && !hasError {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.blue)
                        
                        Text("Loading video...")
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.1))
                    )
                }
            }
            
            // Video Description
            VStack(spacing: 12) {
                Text("See Neckrot in Action")
                    .font(.title2.bold())
                    .foregroundColor(Theme.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("Watch how quick workouts help strengthen your neck and reduce pain in just 2 minutes")
                    .font(.body)
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .onAppear {
            setupVideoPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func setupVideoPlayer() {
        // For now, we'll use a placeholder approach
        // In production, you would load the actual video from Assets.xcassets
        
        // Simulate video loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            
            // Create a placeholder player for now
            // Replace this with actual video loading when you have the video file
            if let videoURL = Bundle.main.url(forResource: "app-demo-video", withExtension: "mp4") {
                player = AVPlayer(url: videoURL)
                player?.isMuted = true // Start muted for better UX
                player?.play()
                isPlaying = true
                
                // Auto-hide controls after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showControls = false
                    }
                }
            } else {
                // Video file not found, show fallback
                hasError = true
            }
        }
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func replayVideo() {
        guard let player = player else { return }
        
        player.seek(to: .zero)
        player.play()
        isPlaying = true
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    OnboardingVideoDemo()
        .background(Theme.backgroundGradient)
}
