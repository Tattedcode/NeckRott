//
//  GoalsView.swift
//  ForwardNeckV1
//
//  Goals overview screen.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @State private var showingAddGoal = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    completionStatsSection
                    activeGoalsSection
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

    private var completionStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal Progress")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))

            HStack(spacing: 16) {
                completionCard
                activeGoalsCard
            }
        }
    }

    private var completionCard: some View {
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
    }

    private var activeGoalsCard: some View {
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

    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Goals")
                .font(.headline)
                .foregroundColor(.white.opacity(0.85))

            if viewModel.goals.isEmpty {
                emptyState
            } else {
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

    private var emptyState: some View {
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
    }

    private var addGoalButton: some View {
        Button(action: { showingAddGoal = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add New Goal")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [Color.blue, Color.pink], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack { GoalsView() }
}
