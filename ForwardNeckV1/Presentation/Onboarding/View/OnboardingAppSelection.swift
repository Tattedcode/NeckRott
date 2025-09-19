//
//  OnboardingAppSelection.swift
//  ForwardNeckV1
//
//  App selection onboarding screen for choosing apps to limit
//

import SwiftUI

struct OnboardingAppSelection: View {
    @State private var selectedApps: Set<String> = []
    @State private var showAppSelection = false
    
    // Default social media apps - these would be replaced with actual detected apps
    private let defaultApps = [
        AppInfo(name: "TikTok", icon: "tiktok", color: Color.black),
        AppInfo(name: "Instagram", icon: "instagram", color: Color.purple),
        AppInfo(name: "YouTube", icon: "youtube", color: Color.red),
        AppInfo(name: "Facebook", icon: "facebook", color: Color.blue)
    ]
    
    var body: some View {
        // Group the content into a single stack
        let content = VStack(spacing: 20) {
            // Mascot image
            Image("mascot1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Title
            Text("select brainrot apps")
                .font(.title.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            // Subtitle
            Text("choose the apps you want to track and reduce usage of")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Additional note
            Text("(you can update this later)")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
            
            // App selection card
            VStack(spacing: 16) {
                // App selection header
                HStack {
                    Text("select apps to limit")
                        .font(.headline.bold())
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // App icons row
                HStack(spacing: 20) {
                    ForEach(defaultApps, id: \.name) { app in
                        VStack(spacing: 8) {
                            // App icon
                            RoundedRectangle(cornerRadius: 12)
                                .fill(app.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "app.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                )
                            
                            // App name
                            Text(app.name)
                                .font(.caption)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Confirmation text
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
                
                Text("we'll help you limit time spent on these apps")
                    .font(.subheadline)
                    .foregroundColor(.green)
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
        .onTapGesture {
            // Handle app selection card tap
            showAppSelection = true
        }
        .sheet(isPresented: $showAppSelection) {
            // This would open a detailed app selection view
            AppSelectionDetailView(selectedApps: $selectedApps)
        }
    }
}

// MARK: - App Info Model

struct AppInfo {
    let name: String
    let icon: String
    let color: Color
}

// MARK: - App Selection Detail View (Placeholder)

struct AppSelectionDetailView: View {
    @Binding var selectedApps: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("App Selection Detail")
                    .font(.title)
                    .padding()
                
                Text("This would show a detailed list of all apps")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingAppSelection()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
