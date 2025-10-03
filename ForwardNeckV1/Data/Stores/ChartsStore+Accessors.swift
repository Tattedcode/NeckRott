//
//  ChartsStore+Accessors.swift
//  ForwardNeckV1
//
//  Chart data helpers and empty states.
//

import Foundation

extension ChartsStore {
    func getChartData(for chartType: ChartType, timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        switch chartType {
        case .weeklyBar:
            return getWeeklyBarChartData(timeRange: timeRange)
        case .streakLine:
            return getStreakLineChartData(timeRange: timeRange)
        case .monthlyBar:
            return getMonthlyBarChartData(timeRange: timeRange)
        }
    }

    func hasData() -> Bool {
        !weeklyAnalytics.isEmpty || !monthlyAnalytics.isEmpty || !streakOverTime.streakData.isEmpty
    }

    func getEmptyStateMessage(for chartType: ChartType) -> String {
        switch chartType {
        case .weeklyBar:
            return "No weekly data available. Start checking your posture to see your progress!"
        case .streakLine:
            return "No streak data available. Build a streak by checking your posture daily!"
        case .monthlyBar:
            return "No monthly data available. Keep using the app to see your monthly progress!"
        }
    }

    private func getWeeklyBarChartData(timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        let weeksToShow = min(timeRange.days / 7, weeklyAnalytics.count)
        let recentWeeks = Array(weeklyAnalytics.suffix(weeksToShow))

        return recentWeeks.enumerated().map { index, week in
            ChartDataPoint(
                date: week.weekStart,
                value: Double(week.postureChecks),
                label: "W\(index + 1)"
            )
        }
    }

    private func getStreakLineChartData(timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        let daysToShow = min(timeRange.days, streakOverTime.streakData.count)
        return Array(streakOverTime.streakData.suffix(daysToShow))
    }

    private func getMonthlyBarChartData(timeRange: AnalyticsTimeRange) -> [ChartDataPoint] {
        let monthsToShow = min(timeRange.days / 30, monthlyAnalytics.count)
        let recentMonths = Array(monthlyAnalytics.suffix(monthsToShow))

        return recentMonths.enumerated().map { index, month in
            ChartDataPoint(
                date: Calendar.current.date(from: DateComponents(year: month.year, month: month.month)) ?? Date(),
                value: Double(month.totalPostureChecks),
                label: "M\(index + 1)"
            )
        }
    }
}
