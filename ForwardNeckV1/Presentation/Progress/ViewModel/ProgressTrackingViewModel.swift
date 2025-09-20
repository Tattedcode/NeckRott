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
    
    var hasActivity: Bool { completionCount > 0 }
}

struct MonthlySummary {
    var totalFixes: Int
    var averageDaily: Double
    var bestDay: Date?
    var topExerciseName: String?
    
    static let empty = MonthlySummary(totalFixes: 0, averageDaily: 0, bestDay: nil, topExerciseName: nil)
    
    var totalLabel: String { "\(totalFixes)" }
    var averageLabel: String {
        guard totalFixes > 0 else { return "0" }
        return String(format: "%.1f", averageDaily)
    }
    var bestDayLabel: String {
        guard let bestDay else { return "n/a" }
        return MonthlySummary.bestDayFormatter.string(from: bestDay)
    }
    var topExerciseLabel: String { topExerciseName ?? "n/a" }
    
    private static let bestDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}

@MainActor
final class ProgressTrackingViewModel: ObservableObject {
    @Published var displayedMonth: Date
    @Published var calendarDays: [CalendarDay] = []
    @Published var summary: MonthlySummary = .empty
    @Published private(set) var dailyGoal: Int = 0
    
    private let exerciseStore = ExerciseStore.shared
    private let userStore = UserStore()
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    private let monthFormatter: DateFormatter
    private let startOfMonthComponents: Set<Calendar.Component> = [.year, .month]
    
    init() {
        let components = Calendar.current.dateComponents(startOfMonthComponents, from: Date())
        displayedMonth = Calendar.current.date(from: components) ?? Date()
        monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "LLLL yyyy"
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
        summary = buildSummary(from: completions, dayCounts: dayCounts)
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
            cells.append(CalendarDay(date: nil, day: nil, isToday: false, completionCount: 0, mascotAssetName: "mascot1"))
        }
        for day in dayRange {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let dayKey = calendar.startOfDay(for: date)
            var count = dayCounts[dayKey] ?? 0

            // Inject lightweight dummy data for past days during testing
            if count == 0, date < calendar.startOfDay(for: Date()) {
                let dayNumber = calendar.component(.day, from: date)
                let baseline = max(dailyGoal, 3)
                count = (dayNumber % (baseline + 1))
            }

            let mascot = mascotAssetName(for: count)
            cells.append(
                CalendarDay(
                    date: date,
                    day: day,
                    isToday: calendar.isDateInToday(date),
                    completionCount: count,
                    mascotAssetName: mascot
                )
            )
        }
        let remainder = cells.count % 7
        if remainder != 0 {
            for _ in 0..<(7 - remainder) {
                cells.append(CalendarDay(date: nil, day: nil, isToday: false, completionCount: 0, mascotAssetName: "mascot1"))
            }
        }
        return cells
    }
    
    private func buildSummary(from completions: [ExerciseCompletion], dayCounts: [Date: Int]) -> MonthlySummary {
        let total = completions.count
        let dayCount = (calendar.range(of: .day, in: .month, for: displayedMonth)?.count).map(Double.init) ?? 1
        let average = dayCount > 0 ? Double(total) / dayCount : 0
        let bestDayDate = dayCounts.max { lhs, rhs in lhs.value < rhs.value }?.key
        let topExerciseName = topExerciseName(from: completions)
        return MonthlySummary(totalFixes: total, averageDaily: average, bestDay: bestDayDate, topExerciseName: topExerciseName)
    }

    private func topExerciseName(from completions: [ExerciseCompletion]) -> String? {
        guard !completions.isEmpty else { return nil }
        let counts = completions.reduce(into: [UUID: Int]()) { dict, completion in
            dict[completion.exerciseId, default: 0] += 1
        }
        guard let topId = counts.max(by: { $0.value < $1.value })?.key else { return nil }
        return exerciseStore.exercise(by: topId)?.title
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
