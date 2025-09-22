//
//  HomeViewModel.swift
//  ForwardNeckV1
//
//  Simplified MVVM ViewModel for Home screen metrics.
//

import Combine
import Foundation
import FamilyControls
#if canImport(DeviceActivity)
import DeviceActivity
#endif

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var screenTimeDisplay: String = "0m"
    // @Published private(set) var isLoadingScreenTime = false
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var recordStreak: Int = 0
    @Published private(set) var nextExercise: Exercise?
    @Published private(set) var neckFixesCompleted: Int = 0
    @Published private(set) var neckFixesTarget: Int = 0
    @Published private(set) var healthPercentage: Int = 100
    @Published private(set) var selectedNeckFixDate: Date = Date()
    @Published var activitySelection: FamilyActivitySelection = .init() {
        didSet {
            appMonitoringStore.updateSelection(activitySelection)
            refreshTrackedAppUsage()
            scheduleMonitoring(for: activitySelection)
        }
    }
    @Published private(set) var trackedUsageMinutes: Int = 0
    @Published private(set) var monthlyAchievements: [MonthlyAchievement] = MonthlyAchievementKind.allCases.map { MonthlyAchievement(kind: $0) }
    @Published private(set) var recentlyUnlockedAchievement: MonthlyAchievement?
    @Published private(set) var neckFixHistory: [NeckFixDaySummary] = []
    
    // private let screenTimeService: ScreenTimeService
    private let streakStore: StreakStore
    private let exerciseStore: ExerciseStore
    private let userStore: UserStore
    private let appMonitoringStore = AppMonitoringStore()
    private var cancellables = Set<AnyCancellable>()
    private var lastExerciseId: UUID?
    private let historyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    private let achievementsShownKey = "home.achievements.shown"
    private var shownAchievementKinds: Set<MonthlyAchievementKind> {
        didSet { saveShownAchievements() }
    }
    private var celebrationsEnabled = false
    
    init(
        // screenTimeService: ScreenTimeService? = nil,
        streakStore: StreakStore? = nil,
        exerciseStore: ExerciseStore? = nil,
        userStore: UserStore? = nil
    ) {
        // self.screenTimeService = screenTimeService ?? ScreenTimeService()
        self.streakStore = streakStore ?? StreakStore.shared
        self.exerciseStore = exerciseStore ?? ExerciseStore.shared
        self.userStore = userStore ?? UserStore()
        self.shownAchievementKinds = Self.loadShownAchievements(key: achievementsShownKey)

        NotificationCenter.default.publisher(for: .appDataDidReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleAppDataReset()
            }
            .store(in: &cancellables)

        bindStreakStore()
        bindExerciseStore()
        bindUserStore()
        updateStreaks()
        updateNextExercise()
        selectedNeckFixDate = Calendar.current.startOfDay(for: Date())
        updateNeckFixes(for: selectedNeckFixDate)
        activitySelection = appMonitoringStore.activitySelection
    }
    
    func onAppear() async {
        updateStreaks()
        updateNextExercise()
        updateNeckFixes(for: selectedNeckFixDate)
        // await refreshScreenTime()
        refreshTrackedAppUsage()
        celebrationsEnabled = true
    }

    // func refreshScreenTime() async {
    //     isLoadingScreenTime = true
    //     await screenTimeService.fetchScreenTime()
    //     screenTimeDisplay = screenTimeService.formatScreenTime(screenTimeService.totalScreenTime)
    //     isLoadingScreenTime = false
    // }
    
    private func bindStreakStore() {
        streakStore.$streaks
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateStreaks()
            }
            .store(in: &cancellables)
    }
    
    private func bindExerciseStore() {
        exerciseStore.$exercises
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateNextExercise()
            }
            .store(in: &cancellables)

        exerciseStore.$completions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateNeckFixes(for: self.selectedNeckFixDate)
            }
            .store(in: &cancellables)
    }

    private func bindUserStore() {
        userStore.$dailyGoal
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.updateNeckFixes(for: self.selectedNeckFixDate)
            }
            .store(in: &cancellables)
    }

    private func updateStreaks() {
        recordStreak = streakStore.longestStreak(for: .postureChecks)
        currentStreak = streakStore.currentStreak(for: .postureChecks)
    }

    private func updateNextExercise() {
        let exercises = exerciseStore.allExercises()
        guard !exercises.isEmpty else {
            nextExercise = nil
            lastExerciseId = nil
            return
        }
        let filtered = exercises.filter { $0.id != lastExerciseId }
        let selectionPool = filtered.isEmpty ? exercises : filtered
        guard let selection = selectionPool.randomElement() else {
            nextExercise = nil
            lastExerciseId = nil
            return
        }
        lastExerciseId = selection.id
        nextExercise = selection
    }

    func completeCurrentExercise() async {
        guard let exercise = nextExercise else { return }
        await exerciseStore.recordCompletion(exerciseId: exercise.id, durationSeconds: exercise.durationSeconds)
        updateNextExercise()
        updateNeckFixes(for: selectedNeckFixDate)
    }

    // MARK: - App Monitoring Helpers

    var hasMonitoredApps: Bool { !activitySelection.applications.isEmpty }

    var trackedUsageDisplay: String {
        formatMinutes(trackedUsageMinutes)
    }

    func refreshTrackedAppUsage() {
        trackedUsageMinutes = appMonitoringStore.totalUsageMinutes()
    }

    func selectNeckFixDate(_ date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        selectedNeckFixDate = normalizedDate
        updateNeckFixes(for: normalizedDate)
    }

    func markAchievementCelebrated(_ achievement: MonthlyAchievement) {
        guard achievement.isUnlocked else { return }
        if !shownAchievementKinds.contains(achievement.kind) {
            shownAchievementKinds.insert(achievement.kind)
        }
    }

    private func updateNeckFixes(for date: Date) {
        neckFixesTarget = max(0, userStore.dailyGoal)

        let calendar = Calendar.current
        let completionsForDate = exerciseStore.completions.filter { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: date)
        }
        neckFixesCompleted = completionsForDate.count

        if neckFixesTarget > 0 {
            let progress = Double(neckFixesCompleted) / Double(neckFixesTarget)
            healthPercentage = Int((min(1.0, max(0.0, progress))) * 100)
        } else {
            healthPercentage = 0
        }

        let referenceDate = max(date, Date())
        neckFixHistory = buildNeckFixHistory(endingOn: referenceDate, days: 6)
        updateMonthlyAchievements(skipCelebration: !celebrationsEnabled)

        if #available(iOS 14.0, *) {
            let mascot = WidgetSyncManager.mascot(for: healthPercentage)
            WidgetSyncManager.updateWidget(percentage: healthPercentage, mascot: mascot)
        }
    }

    func clearRecentlyUnlockedAchievement() {
        recentlyUnlockedAchievement = nil
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }

}

private extension HomeViewModel {
    func updateMonthlyAchievements(skipCelebration: Bool) {
        var updated = monthlyAchievements
        guard !updated.isEmpty else { return }

        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now

        let completions = exerciseStore.completions.filter { $0.completedAt <= now }
        let completionsThisMonth = completions.filter { completion in
            completion.completedAt >= startOfMonth && completion.completedAt < startOfNextMonth
        }
        let completionsToday = completions.filter { completion in
            calendar.isDate(completion.completedAt, inSameDayAs: now)
        }
        let completionsTodayCount = completionsToday.count
        let currentPostureStreak = streakStore.currentStreak(for: .postureChecks)
        let totalCompletions = completions.count
        let monthlyCompletionCount = completionsThisMonth.count
        let dailyGoal = userStore.dailyGoal

        var newlyUnlocked: MonthlyAchievement?

        for index in updated.indices {
            let kind = updated[index].kind
            let wasUnlocked = updated[index].isUnlocked

            let isUnlocked: Bool = {
                switch kind {
                case .firstExercise:
                    return monthlyCompletionCount >= 1
                case .extraExercises:
                    let goal = max(0, dailyGoal)
                    return goal == 0 ? completionsTodayCount >= 1 : completionsTodayCount > goal
                case .dailyStreakStarted:
                    let goalMetToday = dailyGoal <= 0 ? completionsTodayCount >= 1 : completionsTodayCount >= dailyGoal
                    return currentPostureStreak >= 1 && goalMetToday
                case .fifteenDayStreak:
                    return currentPostureStreak >= 15
                case .fullMonthStreak:
                    return currentPostureStreak >= 30
                case .tenCompleted:
                    return totalCompletions >= 10
                case .twentyCompleted:
                    return totalCompletions >= 20
                }
            }()

            updated[index].isUnlocked = isUnlocked
            if isUnlocked && skipCelebration && !shownAchievementKinds.contains(kind) {
                shownAchievementKinds.insert(kind)
            }

            if !skipCelebration,
               isUnlocked,
               !wasUnlocked,
               !shownAchievementKinds.contains(kind) {
                newlyUnlocked = updated[index]
            }
        }

        monthlyAchievements = updated
        if let newlyUnlocked {
            recentlyUnlockedAchievement = newlyUnlocked
        }
    }
}

private extension HomeViewModel {
    static func loadShownAchievements(key: String) -> Set<MonthlyAchievementKind> {
        guard let data = UserDefaults.standard.data(forKey: key),
              let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        let kinds = rawValues.compactMap { MonthlyAchievementKind(rawValue: $0) }
        return Set(kinds)
    }

    func saveShownAchievements() {
        let rawValues = shownAchievementKinds.map { $0.rawValue }
        if rawValues.isEmpty {
            UserDefaults.standard.removeObject(forKey: achievementsShownKey)
        } else if let data = try? JSONEncoder().encode(rawValues) {
            UserDefaults.standard.set(data, forKey: achievementsShownKey)
        }
    }

    func handleAppDataReset() {
        celebrationsEnabled = false
        shownAchievementKinds = []
        recentlyUnlockedAchievement = nil
        UserDefaults.standard.removeObject(forKey: achievementsShownKey)
        userStore.loadUserData()
        updateStreaks()
        updateNextExercise()
        selectedNeckFixDate = Calendar.current.startOfDay(for: Date())
        updateNeckFixes(for: selectedNeckFixDate)
        celebrationsEnabled = true
    }
}

// MARK: - App Monitoring Scheduling

private extension HomeViewModel {
    func scheduleMonitoring(for selection: FamilyActivitySelection) {
        #if canImport(DeviceActivity)
        if #available(iOS 16.0, *) {
            Task { await configureMonitoring(for: selection) }
        } else {
            Log.info("Device activity monitoring requires iOS 16.0 or newer")
        }
        #else
        Log.info("DeviceActivity framework unavailable – skipping monitoring schedule")
        #endif
    }

    #if canImport(DeviceActivity)
    @available(iOS 16.0, *)
    private func configureMonitoring(for selection: FamilyActivitySelection) async {
        let monitoredApps = selection.applications
        let activityName = DeviceActivityName("ForwardNeckAppMonitoring")
        let center = DeviceActivityCenter()

        guard !monitoredApps.isEmpty else {
            center.stopMonitoring([activityName])
            Log.info("Stopped app monitoring – no apps selected")
            return
        }

        do {
            if AuthorizationCenter.shared.authorizationStatus != .approved {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            }

            let startOfDay = DateComponents(hour: 0, minute: 0)
            let endOfDay = DateComponents(hour: 23, minute: 59, second: 59)
            let schedule = DeviceActivitySchedule(intervalStart: startOfDay, intervalEnd: endOfDay, repeats: true)

            try center.startMonitoring(activityName, during: schedule)
            Log.info("Scheduled app monitoring for \(monitoredApps.count) apps")
        } catch {
            Log.error("Failed to schedule app monitoring: \(error.localizedDescription)")
        }
    }
    #endif
}

struct MonthlyAchievement: Identifiable, Equatable {
    let kind: MonthlyAchievementKind
    var isUnlocked: Bool = false
    var id: MonthlyAchievementKind { kind }
    var title: String { kind.title }
}

struct NeckFixDaySummary: Identifiable, Equatable {
    var id: Date { date }
    let date: Date
    let label: String
    let count: Int
}

enum MonthlyAchievementKind: String, CaseIterable, Hashable, Codable {
    case firstExercise
    case extraExercises
    case tenCompleted
    case twentyCompleted
    case dailyStreakStarted
    case fifteenDayStreak
    case fullMonthStreak
}

extension MonthlyAchievementKind {
    var title: String {
        switch self {
        case .firstExercise: return "First Exercise This Month"
        case .extraExercises: return "Completed Extra Exercise"
        case .tenCompleted: return "10 Exercises Completed"
        case .twentyCompleted: return "20 Exercises Completed"
        case .dailyStreakStarted: return "Daily Streak Started"
        case .fifteenDayStreak: return "15 Day Streak"
        case .fullMonthStreak: return "Full Month Streak"
        }
    }

    var lockedImageName: String {
        switch self {
        case .extraExercises:
            return "extraexercises"
        case .dailyStreakStarted:
            return "dailystreakstarted"
        case .fifteenDayStreak:
            return "fifteendaystreak"
        case .firstExercise:
            return "firstexcersise"
        case .fullMonthStreak:
            return "fullmonthstreak"
        case .tenCompleted:
            return "tencompleted"
        case .twentyCompleted:
            return "twentycompleted"
        }
    }

    var unlockedImageName: String {
        switch self {
        case .extraExercises:
            return "extraexercises"
        case .dailyStreakStarted:
            return "dailystreakstarted"
        case .fifteenDayStreak:
            return "fifteendaystreak"
        case .firstExercise:
            return "firstexcersise"
        case .fullMonthStreak:
            return "fullmonthstreak"
        case .tenCompleted:
            return "tencompleted"
        case .twentyCompleted:
            return "twentycompleted"
        }
    }

    var usesSystemImage: Bool { false }
}

private extension HomeViewModel {
    func buildNeckFixHistory(endingOn referenceDate: Date, days: Int) -> [NeckFixDaySummary] {
        let calendar = Calendar.current
        let normalizedReference = calendar.startOfDay(for: referenceDate)
        let range = (0..<max(days, 1))

        let summaries = range.compactMap { offset -> NeckFixDaySummary? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: normalizedReference) else { return nil }
            let count = exerciseStore.completions.filter { completion in
                calendar.isDate(completion.completedAt, inSameDayAs: date)
            }.count
            let label = historyFormatter.string(from: date)
            return NeckFixDaySummary(date: date, label: label, count: count)
        }

        return summaries.sorted { $0.date < $1.date }
    }
}
