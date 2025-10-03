//
//  GoalCard.swift
//  ForwardNeckV1
//
//  Displays a single goal summary.
//

import SwiftUI

struct GoalCard: View {
    let goal: CustomGoal
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            progressSection
            actionButtons
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(goal.isActive ? Color(hex: goal.type.color) ?? .clear : .clear, lineWidth: 2)
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { goal.isActive },
                set: { _ in onToggle() }
            ))
            .toggleStyle(SwitchToggleStyle(tint: .green))
        }
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                Text("\(goal.currentProgress)/\(goal.targetValue)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }

            ProgressView(value: goal.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: goal.type.color) ?? .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)

            HStack {
                Text(goal.timePeriod.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                if goal.isCompleted {
                    Label("Completed!", systemImage: "checkmark.circle.fill")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                } else {
                    Text("\(Int(goal.progressPercentage * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}
