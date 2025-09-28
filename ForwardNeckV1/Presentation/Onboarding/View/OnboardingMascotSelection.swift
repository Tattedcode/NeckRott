//
//  OnboardingMascotSelection.swift
//  ForwardNeckV1
//
//  Lets the kid pick between the classic buddy and the spooky skeleton buddy.
//

import SwiftUI

struct OnboardingMascotSelection: View {
    @Binding var currentSelection: String
    @Binding var hasSelectedMascot: Bool
    let onSelectionChanged: (String) -> Void
    @State private var showFeedback = false

    private let choices: [MascotChoice] = [
        MascotChoice(prefix: "", imageName: "mascot4", title: "Original", subtitle: "Bright & friendly coach"),
        MascotChoice(prefix: "skele", imageName: "skelemascot4", title: "Skeleton", subtitle: "Edgy spooky motivator"),
        MascotChoice(prefix: "girl", imageName: "girlmascot4", title: "Girl Power", subtitle: "Confident queen energy"),
        MascotChoice(prefix: "hero", imageName: "supermascot4", title: "Superhero", subtitle: "Heroic and inspiring") // hero = shared prefix for themed assets
    ]

    var body: some View {
        VStack(spacing: 24) {
            Text("Pick the buddy who helps you stay on track")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Theme.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 20) {
                ForEach(choices) { choice in
                    MascotSelectionCard(
                        choice: choice,
                        isSelected: isSelected(choice: choice),
                        onTap: { select(choice: choice) }
                    )
                }
            }
            .padding(.horizontal, 4)

            if showFeedback {
                Text(feedbackText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            Log.info("OnboardingMascotSelection appeared with selection=\(currentSelection.isEmpty ? "default" : currentSelection)")
            hasSelectedMascot = !currentSelection.isEmpty
        }
    }

    private func select(choice: MascotChoice) {
        withAnimation(.spring(duration: 0.3)) {
            currentSelection = choice.prefix
            hasSelectedMascot = true
            showFeedback = true
        }

        onSelectionChanged(choice.prefix)

        let selectionLabel = choice.prefix.isEmpty ? "default" : choice.prefix
        Log.info("OnboardingMascotSelection user picked mascot prefix=\(selectionLabel)")
    }

    private func isSelected(choice: MascotChoice) -> Bool {
        currentSelection == choice.prefix
    }

    private var feedbackText: String {
        switch currentSelection {
        case "":
            return "Sticking with the bright mascot. Let's keep things cheerful!"
        case "skele":
            return "Skeleton buddy locked in. Lets fix that neck"
        case "girl":
            return "Girl power activated. Let’s glow up that posture!"
        case "super":
            return "Superhero mode engaged. Time to save your neck!"
        default:
            return "Awesome choice! Your buddy is ready to cheer you on."
        }
    }
}

private struct MascotChoice: Identifiable {
    let prefix: String
    let imageName: String
    let title: String
    let subtitle: String

    var id: String { prefix.isEmpty ? "default" : prefix }
}

private struct MascotSelectionCard: View {
    let choice: MascotChoice
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: handleTap) {
            VStack(spacing: 12) {
                Image(choice.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 6)

                VStack(spacing: 4) {
                    Text(choice.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.primaryText)

                    Text(choice.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 160)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.green, lineWidth: 3)
                    .opacity(isSelected ? 1 : 0) // Show the green outline only on the outer card when picked
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(duration: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func handleTap() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onTap()
    }

    private var accessibilityLabel: String {
        switch choice.prefix {
        case "":
            return isSelected ? "Original mascot selected" : "Pick original mascot"
        case "skele":
            return isSelected ? "Skeleton mascot selected" : "Pick skeleton mascot"
        case "girl":
            return isSelected ? "Girl mascot selected" : "Pick girl mascot"
        case "super":
            return isSelected ? "Superhero mascot selected" : "Pick superhero mascot"
        default:
            return "Choose mascot"
        }
    }
}

#Preview {
    OnboardingMascotSelection(
        currentSelection: .constant(""),
        hasSelectedMascot: .constant(false),
        onSelectionChanged: { _ in }
    )
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black)
}

