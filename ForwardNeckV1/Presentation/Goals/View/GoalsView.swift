//
//  GoalsView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

/// Goals screen for setting and managing custom goals
/// Part of S-005: Goals Screen
struct GoalsView: View {
    /// ViewModel for managing goals data
    @StateObject private var viewModel: GoalsViewModel = GoalsViewModel()
    
    /// State for showing add goal sheet
    @State private var showingAddGoal = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with completion stats
                    completionStatsSection
                    
                    // Active goals section
                    activeGoalsSection
                    
                    // Add goal button
                    addGoalButton
                }
                .padding(16)
            }
        }
        .onAppear {
            viewModel.loadGoals()
            Log.info("GoalsView appeared")
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView { newGoal in
                viewModel.addGoal(newGoal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// Completion statistics section
    private var completionStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Progress")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            
            HStack(spacing: 16) {
                // Completion percentage
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                        Text("Completion")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("\(Int(viewModel.completionPercentage * 100))%")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("\(viewModel.completedGoals)/\(viewModel.totalGoals) goals")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Active goals count
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.green)
                        Text("Active")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Text("\(viewModel.activeGoalsCount)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    
                    Text("goals set")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    /// Active goals section
    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Goals")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))
            
            if viewModel.goals.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No goals set yet")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Create your first custom goal to start tracking your progress")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                // Goals list
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.goals) { goal in
                        GoalCard(goal: goal) {
                            viewModel.toggleGoalActive(goal.id)
                        } onEdit: {
                            // TODO: Implement edit functionality
                        } onDelete: {
                            viewModel.deleteGoal(goal.id)
                        }
                    }
                }
            }
        }
    }
    
    /// Add goal button
    private var addGoalButton: some View {
        Button(action: {
            showingAddGoal = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add New Goal")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(LinearGradient(colors: [Color.blue, Color.pink], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

/// Card component for displaying individual goals
/// Part of S-005: Goals Screen
struct GoalCard: View {
    let goal: CustomGoal
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and toggle
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
            
            // Progress section
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
                
                // Progress bar
                ProgressView(value: goal.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: goal.type.color) ?? .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                // Time period and completion status
                HStack {
                    Text(goal.timePeriod.rawValue)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    if goal.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Completed!")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("\(Int(goal.progressPercentage * 100))%")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                        Text("Edit")
                    }
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
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
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
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(goal.isActive ? Color(hex: goal.type.color) ?? .clear : Color.clear, lineWidth: 2)
        )
    }
}

/// Add goal sheet view
/// Part of S-005: Goals Screen
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
                        // Goal type selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goal Type")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
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
                        
                        // Target value
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
                        
                        // Time period
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Period")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 12) {
                                ForEach(GoalTimePeriod.allCases) { period in
                                    Button(action: {
                                        selectedTimePeriod = period
                                    }) {
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
                        
                        // Custom title and description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Custom Details")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                TextField("Goal title", text: $customTitle)
                                    .textFieldStyle(CustomTextFieldStyle())
                                
                                TextField("Goal description", text: $customDescription, axis: .vertical)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            updateCustomFields()
        }
    }
    
    /// Update custom title and description based on selected type
    private func updateCustomFields() {
        if customTitle.isEmpty {
            customTitle = selectedType.rawValue
        }
        if customDescription.isEmpty {
            customDescription = "Track your \(selectedType.rawValue.lowercased()) progress"
        }
    }
    
    /// Save the new goal
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

/// Custom text field style for the add goal form
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .foregroundColor(.white)
    }
}

/// Goal type selection card
struct GoalTypeCard: View {
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

#Preview {
    NavigationStack {
        GoalsView()
    }
}
