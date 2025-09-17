//
//  ProgressTrackingView.swift
//  ForwardNeckV1
//
//  Screen showing daily goal ring and 7-day bar chart with mock data.
//

import SwiftUI

struct ProgressTrackingView: View {
    // Use StateObject so SwiftUI observes @Published changes (like selectedRange)
    @StateObject private var viewModel: ProgressTrackingViewModel = ProgressTrackingViewModel()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Progress")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    // Range selector and goals button
                    HStack {
                        // Range selector
                        HStack(spacing: 8) {
                            ForEach(ProgressRange.allCases) { range in
                                Button(action: { withAnimation { viewModel.selectedRange = range } }) {
                                    Text(range.rawValue)
                                        .font(.subheadline.bold())
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(viewModel.selectedRange == range ? Theme.pillSelected : Theme.pillUnselected)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Spacer()
                        
                        // Goals button
                        NavigationLink {
                            GoalsView()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "target")
                                Text("Goals")
                            }
                            .font(.subheadline.bold())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Theme.pillSelected)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    // Daily goal ring section
                    VStack(spacing: 12) {
                        Text("Daily Goal")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                        ProgressRingView(progress: viewModel.progress, size: 160, lineWidth: 16)
                        Text("\(viewModel.completedToday)/\(viewModel.dailyGoal) completed today")
                            .foregroundColor(.white.opacity(0.85))
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Streak statistics section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Streak & Stats")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                        
                        // Current streak
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Streak")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(viewModel.currentStreak) days")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "flame.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                        }
                        
                        // Stats grid
                        HStack(spacing: 20) {
                            // Longest streak
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Longest")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(viewModel.longestStreak)")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Total check-ins
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Check-ins")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(viewModel.totalPostureChecks)")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Total exercises
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Exercises")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("\(viewModel.totalExercises)")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // 7-day chart section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(titleForSelectedRange)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                        BarChartView(data: currentBarData)
                    }
                    
                    // Charts & Analytics section
                    VStack(spacing: 16) {
                        // Weekly bar chart
                        WeeklyBarChartView(
                            data: viewModel.weeklyAnalytics,
                            isEmpty: viewModel.weeklyAnalytics.isEmpty
                        )
                        
                        // Streak line chart
                        StreakLineChartView(
                            streakData: viewModel.streakOverTime,
                            isEmpty: viewModel.streakOverTime.streakData.isEmpty
                        )
                    }
                }
                .padding(16)
            }
        }
        .onAppear { Log.info("ProgressTrackingView appeared") }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var titleForSelectedRange: String {
        switch viewModel.selectedRange {
        case .last7: return "Last 7 Days"
        case .last14: return "Last 2 Weeks"
        case .last30: return "Last Month"
        }
    }

    private var currentBarData: [BarDatum] {
        switch viewModel.selectedRange {
        case .last7:
            return viewModel.last7Days.map { BarDatum(label: $0.label, value: Double($0.value)) }
        case .last14:
            return viewModel.last14Days.map { BarDatum(label: $0.label, value: Double($0.value)) }
        case .last30:
            return viewModel.last30Days.map { BarDatum(label: $0.label, value: Double($0.value)) }
        }
    }
}

#Preview {
    NavigationStack { ProgressTrackingView() }
}


