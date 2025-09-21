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
                VStack(alignment: .leading, spacing: 28) {
                    header
                    calendarCard
                    summarySection
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
                .foregroundColor(.red)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("monthly neck summary")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textPrimary)
            
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
            return Color.red.opacity(day.hasActivity ? 0.35 : 0.12)
        case "mascot2":
            return Color.orange.opacity(day.hasActivity ? 0.35 : 0.12)
        case "mascot3":
            return Color.yellow.opacity(day.hasActivity ? 0.35 : 0.12)
        default:
            return Color.green.opacity(day.hasActivity ? 0.35 : 0.12)
        }
    }
}

#Preview {
    NavigationStack { ProgressTrackingView() }
}
