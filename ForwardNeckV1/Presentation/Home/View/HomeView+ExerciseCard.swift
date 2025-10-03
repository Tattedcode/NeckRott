//
//  HomeView+ExerciseCard.swift
//  ForwardNeckV1
//
//  Exercise card rendering and helpers.
//

import SwiftUI

extension HomeView {
    @ViewBuilder
    func exerciseCard(for exercise: Exercise) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(exercise.description)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                exerciseMeta(for: exercise)

                DisclosureGroup(isExpanded: $isInstructionsExpanded) {
                    instructionList(for: exercise)
                } label: {
                    HStack(spacing: 6) {
                        Text("Instructions")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isInstructionsExpanded ? 90 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isInstructionsExpanded)
                    }
                }
                .tint(.white)
            }

            Spacer(minLength: 16)

            VStack(spacing: 8) {
                Button(action: { isShowingExerciseTimer = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 72, height: 72)
                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Start \(exercise.title)")

                Text("Start")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 90, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func exerciseMeta(for exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            Label(exercise.durationLabel, systemImage: "clock")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.8))

            Label(exercise.difficulty.rawValue.capitalized, systemImage: "flame")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color(for: exercise.difficulty))
        }
    }

    @ViewBuilder
    func instructionList(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                Text("\(index + 1). \(instruction)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(.top, 6)
    }

    func color(for difficulty: ExerciseDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
}
