//
//  ProgressTrackingView.swift
//  ForwardNeckV1
//
//  Calendar-first stats screen inspired by the brainrot calendar design.
//

import SwiftUI

struct ProgressTrackingView: View {
    @StateObject private var viewModel = ProgressTrackingViewModel()
    
    private let backgroundGradient = Theme.backgroundGradient
    private let cardColor = Theme.cardBackground
    private let inactiveDayColor = Color.white.opacity(0.08)
    private let textPrimary = Color.white
    private let secondaryText = Color.white.opacity(0.7)
    
    private let calendarColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 7)
    private let summaryColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    calendarCard
                    summarySection
                    dailySummarySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBarHidden(true)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("neck fix calendar")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            monthSelector
            weekdayHeader
            LazyVGrid(columns: calendarColumns, spacing: 12) {
                ForEach(viewModel.calendarDays) { day in
                    calendarCell(for: day)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
    }
    
    private var monthSelector: some View {
        HStack {
            Button(action: { viewModel.moveMonth(by: -1) }) {
                selectorButton(icon: "chevron.left")
            }
            Spacer(minLength: 12)
            Text(viewModel.monthTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textPrimary)
            Spacer(minLength: 12)
            Button(action: { viewModel.moveMonth(by: 1) }) {
                selectorButton(icon: "chevron.right")
            }
        }
    }
    
    private func selectorButton(icon: String) -> some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(inactiveDayColor)
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
            )
    }
    
    private var weekdayHeader: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func calendarCell(for day: CalendarDay) -> some View {
        Group {
            if let dayNumber = day.day, let date = day.date {
                RoundedRectangle(cornerRadius: 16)
                    .fill(dayBackgroundColor(for: day))
                    .frame(height: 64)
                    .overlay(
                        VStack(spacing: 6) {
                            Text("\(dayNumber)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textPrimary)
                            Image(day.mascotAssetName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                        .padding(.vertical, 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(day.isToday ? 0.9 : 0), lineWidth: 2)
                    )
                    .accessibilityLabel(calendarCellAccessibility(for: date, hasActivity: day.hasActivity))
            } else {
                Color.clear.frame(height: 64)
            }
        }
    }
    
    private func calendarCellAccessibility(for date: Date, hasActivity: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let base = formatter.string(from: date)
        return hasActivity ? "\(base), activity completed" : base
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: summaryColumns, spacing: 12) {
                SummaryCard(
                    title: "total fixes",
                    value: viewModel.summary.totalLabel,
                    systemIcon: "chart.bar.fill",
                    accentColor: Color.blue.opacity(0.8)
                )
                SummaryCard(
                    title: "days complete",
                    value: viewModel.summary.completedDaysLabel,
                    systemIcon: "calendar.badge.checkmark",
                    accentColor: Color.orange.opacity(0.8)
                )
                SummaryCard(
                    title: "days missed",
                    value: viewModel.summary.missedDaysLabel,
                    systemIcon: "calendar.badge.exclamationmark",
                    accentColor: Color.pink.opacity(0.8)
                )
            }
        }
    }

    private var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("daily summary")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textPrimary)

            if viewModel.dailySummary.isEmpty {
                Text("No exercise data yet.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(secondaryText)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                DailySummaryChart(entries: viewModel.dailySummary, goal: viewModel.dailyGoal)
                    .frame(height: 190)
                    .background(cardColor)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.06))
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 10)
            }
        }
    }

    private struct SummaryCard: View {
        let title: String
        let value: String
        let systemIcon: String
        let accentColor: Color

        private var textPrimary: Color { Color.white }
        private var secondaryText: Color { Color.white.opacity(0.7) }

        var body: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .frame(height: 100)
                .overlay(
                    VStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor.opacity(0.35))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: systemIcon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.white)
                            )
                        Text(title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(secondaryText)
                        Text(value)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(16)
                )
                .shadow(color: accentColor.opacity(0.25), radius: 10, x: 0, y: 8)
        }
    }

    private func dayBackgroundColor(for day: CalendarDay) -> Color {
        switch day.mascotAssetName {
        case "mascot1":
            return Color.red.opacity(day.hasActivity ? 0.75 : 0.35)
        case "mascot2":
            return Color.orange.opacity(day.hasActivity ? 0.75 : 0.35)
        case "mascot3":
            return Color.yellow.opacity(day.hasActivity ? 0.75 : 0.35)
        default:
            return Color.green.opacity(day.hasActivity ? 0.75 : 0.35)
        }
    }
}

private struct DailySummaryChart: View {
    let entries: [DailyActivity]
    let goal: Int

    private var maxValue: Int {
        max(goal, entries.map { $0.count }.max() ?? 0, 1)
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let labelHeight: CGFloat = 20
            let verticalSpacing: CGFloat = 10
            let barHeight = max(0, totalHeight - (labelHeight * 2) - (verticalSpacing * 2))
            let barWidth = max(16, (geometry.size.width - CGFloat(entries.count - 1) * 12) / CGFloat(entries.count))

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(entries) { entry in
                    VStack(alignment: .center, spacing: verticalSpacing) {
                        Text("\(entry.count)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(height: labelHeight)

                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.12))
                                .frame(width: barWidth, height: barHeight)

                            RoundedRectangle(cornerRadius: 12)
                                .fill(LinearGradient(
                                    colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.85)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                .frame(width: barWidth, height: max(6, CGFloat(entry.count) / CGFloat(maxValue) * barHeight))
                        }

                        Text(entry.label)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(height: labelHeight)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
    }
}

#Preview {
    NavigationStack { ProgressTrackingView() }
}
