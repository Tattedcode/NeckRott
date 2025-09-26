//
//  ProgressTrackingViewModel.swift
//  ForwardNeckV1
//
//  Calendar-driven stats view model powering the Stats tab.
//

import Combine
import Foundation

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
    let day: Int?
    let isToday: Bool
    let completionCount: Int
    let mascotAssetName: String
    let didReachGoal: Bool
    
    var hasActivity: Bool { completionCount > 0 }
}

struct MonthlySummary {
    var totalFixes: Int
    var completedDays: Int
    var missedDays: Int
    
    static let empty = MonthlySummary(totalFixes: 0, completedDays: 0, missedDays: 0)
    
    var totalLabel: String { "\(totalFixes)" }
    var completedDaysLabel: String { "\(completedDays)" }
    var missedDaysLabel: String { "\(missedDays)" }
}

struct DailyActivity: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
    let label: String
}

@MainActor
final class ProgressTrackingViewModel: ObservableObject {
    @Published var displayedMonth: Date
    @Published var calendarDays: [CalendarDay] = []
    @Published var summary: MonthlySummary = .empty
    @Published private(set) var dailyGoal: Int = 0
    @Published private(set) var dailySummary: [DailyActivity] = []
    
    private let exerciseStore = ExerciseStore.shared
    private let userStore = UserStore()
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    private let monthFormatter: DateFormatter
    private let dayLabelFormatter: DateFormatter
    private let startOfMonthComponents: Set<Calendar.Component> = [.year, .month]
    private let enableDummyDataForPastDays = true // Preview helper to make the calendar feel populated
    
    init() {
        let components = Calendar.current.dateComponents(startOfMonthComponents, from: Date())
        displayedMonth = Calendar.current.date(from: components) ?? Date()
        monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL yyyy"
        dayLabelFormatter = DateFormatter()
        dayLabelFormatter.dateFormat = "d"
        observeStores()
        rebuild()
    }
    
    func moveMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        displayedMonth = newMonth
        rebuild()
    }
    
    var monthTitle: String {
        monthFormatter.string(from: displayedMonth).capitalized
    }
    
    var weekdaySymbols: [String] {
        // Custom symbols to match the design (s, m, t, w, t, f, s)
        ["s", "m", "t", "w", "t", "f", "s"]
    }
    
    // MARK: - Private helpers
    
    private func observeStores() {
        dailyGoal = max(userStore.dailyGoal, 1)

        exerciseStore.$completions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.rebuild()
            }
            .store(in: &cancellables)
        
        exerciseStore.$exercises
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.rebuild()
            }
            .store(in: &cancellables)

        userStore.$dailyGoal
            .receive(on: RunLoop.main)
            .sink { [weak self] newGoal in
                self?.dailyGoal = max(newGoal, 1)
                self?.rebuild()
            }
            .store(in: &cancellables)
    }

    private func rebuild() {
        let completions = monthCompletions()
        let dayCounts = dayCounts(from: completions)
        calendarDays = generateCalendarDays(using: dayCounts)
        summary = buildSummary(from: calendarDays)
        dailySummary = buildDailySummary(from: calendarDays)
    }
    
    private func monthCompletions() -> [ExerciseCompletion] {
        guard let interval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let start = calendar.startOfDay(for: interval.start)
        let end = calendar.startOfDay(for: interval.end)
        return exerciseStore.completions.filter { completion in
            completion.completedAt >= start && completion.completedAt < end
        }
    }
    
    private func dayCounts(from completions: [ExerciseCompletion]) -> [Date: Int] {
        completions.reduce(into: [Date: Int]()) { dict, completion in
            let key = calendar.startOfDay(for: completion.completedAt)
            dict[key, default: 0] += 1
        }
    }
    
    private func generateCalendarDays(using dayCounts: [Date: Int]) -> [CalendarDay] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents(startOfMonthComponents, from: displayedMonth)),
              let dayRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }
        var cells: [CalendarDay] = []
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingPlaceholders = (firstWeekday + 6) % 7 // Align weeks to start on Sunday
        for _ in 0..<leadingPlaceholders {
            cells.append(
                CalendarDay(
                    date: nil,
                    day: nil,
                    isToday: false,
                    completionCount: 0,
                    mascotAssetName: MascotAssetProvider.resolvedMascotName(for: "mascot1"),
                    didReachGoal: false
                )
            )
        }
        let todayStart = calendar.startOfDay(for: Date())
        for day in dayRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let dayKey = calendar.startOfDay(for: date)
            var count = dayCounts[dayKey] ?? 0

            if enableDummyDataForPastDays,
               count == 0,
               dayKey < todayStart {
                let dayNumber = calendar.component(.day, from: date)
                let baseline = max(dailyGoal, 3)
                count = dayNumber % (baseline + 1)
            }

            let baseMascot = mascotAssetName(for: count)
            let resolvedMascot = MascotAssetProvider.resolvedMascotName(for: baseMascot)
            Log.info("ProgressTrackingViewModel calendar mascot base=\(baseMascot) resolved=\(resolvedMascot) for day=\(day)")
            let didReachGoal = count >= dailyGoal
            cells.append(
                CalendarDay(
                    date: date,
                    day: day,
                    isToday: calendar.isDateInToday(date),
                    completionCount: count,
                    mascotAssetName: resolvedMascot,
                    didReachGoal: didReachGoal
                )
            )
        }
        let remainder = cells.count % 7
        if remainder != 0 {
            for _ in 0..<(7 - remainder) {
                cells.append(
                    CalendarDay(
                        date: nil,
                        day: nil,
                        isToday: false,
                        completionCount: 0,
                    mascotAssetName: MascotAssetProvider.resolvedMascotName(for: "mascot1"),
                        didReachGoal: false
                    )
                )
            }
        }
        return cells
    }

    private func buildSummary(from calendarDays: [CalendarDay]) -> MonthlySummary {
        let total = calendarDays.reduce(into: 0) { partialResult, calendarDay in
            guard calendarDay.date != nil else { return }
            partialResult += calendarDay.completionCount
        }
        let todayStart = calendar.startOfDay(for: Date())
        let completedDays = calendarDays.filter { calendarDay in
            guard let date = calendarDay.date else { return false }
            let dayStart = calendar.startOfDay(for: date)
            guard dayStart <= todayStart else { return false }
            return calendarDay.didReachGoal
        }.count
        let missedDays = calendarDays.filter { calendarDay in
            guard let date = calendarDay.date else { return false }
            let dayStart = calendar.startOfDay(for: date)
            guard dayStart < todayStart else { return false }
            return !calendarDay.hasActivity
        }.count

        return MonthlySummary(totalFixes: total, completedDays: completedDays, missedDays: missedDays)
    }

    private func buildDailySummary(from calendarDays: [CalendarDay]) -> [DailyActivity] {
        let todayStart = calendar.startOfDay(for: Date())
        let actualDays = calendarDays.compactMap { day -> DailyActivity? in
            guard let date = day.date else { return nil }
            let dayStart = calendar.startOfDay(for: date)
            guard dayStart <= todayStart else { return nil }
            let label = dayLabelFormatter.string(from: dayStart)
            return DailyActivity(date: dayStart, count: max(day.completionCount, 0), label: label)
        }

        let recent = actualDays.sorted { $0.date > $1.date }.prefix(7)
        return Array(recent).sorted { $0.date < $1.date }
    }

    private func mascotAssetName(for completionCount: Int) -> String {
        guard dailyGoal > 0 else { return "mascot1" }
        let ratio = min(1.0, Double(completionCount) / Double(dailyGoal))
        switch ratio {
        case ..<0.25:
            return "mascot1"
        case 0.25..<0.5:
            return "mascot2"
        case 0.5..<0.75:
            return "mascot3"
        default:
            return "mascot4"
        }
    }
}
