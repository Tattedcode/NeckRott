//
//  MascotSelectionView.swift
//  NeckRotV1
//
//  Mascot selection screen where user chooses between male and female mascot
//

import SwiftUI

struct MascotSelectionView: View {
    @Binding var selectedMascotType: MascotPreferenceManager.MascotType
    @State private var localSelection: MascotPreferenceManager.MascotType
    
    init(selectedMascotType: Binding<MascotPreferenceManager.MascotType>) {
        self._selectedMascotType = selectedMascotType
        self._localSelection = State(initialValue: selectedMascotType.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            Text("Choose Your Mascot")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.top, 20)
            
            // Subtitle
            Text("Select the mascot that represents you")
                .font(.system(size: 16))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
            
            // Mascot selection cards
            HStack(spacing: 24) {
                // Male mascot option
                mascotCard(
                    mascotName: "mascot4",
                    label: "Male",
                    isSelected: localSelection == .male
                ) {
                    selectMascot(.male)
                }
                
                // Female mascot option
                mascotCard(
                    mascotName: "femalemascot4",
                    label: "Female",
                    isSelected: localSelection == .female
                ) {
                    selectMascot(.female)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Log.info("MascotSelectionView appeared with current selection: \(localSelection.rawValue)")
        }
    }
    
    // MARK: - Mascot Card
    
    private func mascotCard(
        mascotName: String,
        label: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            action()
        }) {
            VStack(spacing: 16) {
                // Mascot image (no outline on image itself)
                Image(mascotName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                
                // Label
                Text(label)
                    .font(.system(size: 18, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .blue : .black.opacity(0.7))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Selection Handler
    
    private func selectMascot(_ type: MascotPreferenceManager.MascotType) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            localSelection = type
        }
        
        // Update the binding and save preference
        selectedMascotType = type
        MascotPreferenceManager.selectedMascotType = type
        
        Log.info("MascotSelectionView: User selected \(type.rawValue) mascot")
    }
}

#Preview {
    MascotSelectionView(selectedMascotType: .constant(.male))
}

