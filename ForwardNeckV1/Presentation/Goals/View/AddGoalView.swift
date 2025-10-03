//
//  AddGoalView.swift
//  ForwardNeckV1
//
//  Sheet for creating a new custom goal.
//

import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (CustomGoal) -> Void

    @State private var selectedType: GoalType = .dailyPostureChecks
    @State private var targetValue: Int = 5
    @State private var selectedTimePeriod: GoalTimePeriod = .daily
    @State private var customTitle: String = ""
    @State private var customDescription: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        goalTypePicker
                        targetValuePicker
                        timePeriodPicker
                        customDetails
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveGoal)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
            }
        }
        .onAppear(perform: updateCustomFields)
    }

    private var goalTypePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Goal Type")
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(GoalType.allCases) { type in
                    GoalTypeCard(
                        type: type,
                        isSelected: selectedType == type
                    ) {
                        selectedType = type
                        selectedTimePeriod = type.suggestedTimePeriod
                        targetValue = type.defaultTarget
                        updateCustomFields()
                    }
                }
            }
        }
    }

    private var targetValuePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Value")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Stepper(value: $targetValue, in: 1...100) {
                    Text("\(targetValue)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                .foregroundColor(.white)

                Spacer()

                Text(selectedType.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(16)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var timePeriodPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Period")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 12) {
                ForEach(GoalTimePeriod.allCases) { period in
                    Button(action: { selectedTimePeriod = period }) {
                        Text(period.rawValue)
                            .font(.subheadline)
                            .foregroundColor(selectedTimePeriod == period ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTimePeriod == period ? Color.blue : Color.white.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var customDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Details")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                TextField("Goal title", text: $customTitle)
                    .textFieldStyle(GoalTextFieldStyle())

                TextField("Goal description", text: $customDescription, axis: .vertical)
                    .textFieldStyle(GoalTextFieldStyle())
            }
        }
    }

    private func updateCustomFields() {
        if customTitle.isEmpty { customTitle = selectedType.rawValue }
        if customDescription.isEmpty {
            customDescription = "Track your \(selectedType.rawValue.lowercased()) progress"
        }
    }

    private func saveGoal() {
        let newGoal = CustomGoal(
            type: selectedType,
            targetValue: targetValue,
            timePeriod: selectedTimePeriod,
            title: customTitle.isEmpty ? selectedType.rawValue : customTitle,
            description: customDescription.isEmpty ? "Track your \(selectedType.rawValue.lowercased()) progress" : customDescription
        )

        onSave(newGoal)
        dismiss()
    }
}

private struct GoalTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .foregroundColor(.white)
    }
}

private struct GoalTypeCard: View {
    let type: GoalType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: type.iconSystemName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))

                Text(type.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(hex: type.color) ?? .blue : Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: type.color) ?? .blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
