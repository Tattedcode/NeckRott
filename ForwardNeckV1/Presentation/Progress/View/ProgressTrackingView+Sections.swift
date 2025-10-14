//
//  ProgressTrackingView+Sections.swift
//  ForwardNeckV1
//
//  Layout sections and helpers for the progress view.
//

import SwiftUI

extension ProgressTrackingView {
    private var cardColor: Color { Theme.cardBackground }
    private var inactiveDayColor: Color { Color.white.opacity(0.08) }
    private var textPrimary: Color { .white }
    private var secondaryText: Color { .white.opacity(0.7) }
    private var calendarColumns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 7) }
    private var summaryColumns: [GridItem] { Array(repeating: GridItem(.flexible(), spacing: 12), count: 3) }

    var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("neck fix calendar")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
        }
    }

    var calendarCard: some View {
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
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(cardColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
        )
    }

    var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.monthTitle) Summary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
                Text("Stats reset at the start of each month")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(secondaryText)
            }

            LazyVGrid(columns: summaryColumns, spacing: 12) {
                SummaryCard(
                    title: "total fixed",
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

    var dailySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days Summary")
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
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
                    )
            }
        }
    }

    var monthSelector: some View {
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

    func selectorButton(icon: String) -> some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(inactiveDayColor)
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textPrimary)
            )
    }

    var weekdayHeader: some View {
        HStack(spacing: 12) {
            ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    func calendarCell(for day: CalendarDay) -> some View {
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

    func calendarCellAccessibility(for date: Date, hasActivity: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        let base = formatter.string(from: date)
        return hasActivity ? "\(base), activity completed" : base
    }

    func dayBackgroundColor(for day: CalendarDay) -> Color {
        let mascotName = day.mascotAssetName
        switch true {
        case mascotName.contains("mascot1"):
            return Color.red.opacity(day.hasActivity ? 0.75 : 0.35)
        case mascotName.contains("mascot2"):
            return Color.orange.opacity(day.hasActivity ? 0.75 : 0.35)
        case mascotName.contains("mascot3"):
            return Color.yellow.opacity(day.hasActivity ? 0.75 : 0.35)
        default:
            return Color.green.opacity(day.hasActivity ? 0.75 : 0.35)
        }
    }
}
