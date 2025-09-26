import Foundation

@MainActor
final class AppResetService {
    static let shared = AppResetService()
    private init() {}

    func resetAll() async {
        ExerciseStore.shared.resetAll()
        CheckInStore.shared.resetAll()
        StreakStore.shared.resetAll()
        GoalsStore.shared.resetAll()
        GamificationStore.shared.resetAll()
        UserStore().clearUserData()

        UserDefaults.standard.removeObject(forKey: "home.achievements.shown")

        NotificationCenter.default.post(name: .appDataDidReset, object: nil)
    }
}

extension Notification.Name {
    static let appDataDidReset = Notification.Name("appDataDidReset")
    static let mascotThemeDidChange = Notification.Name("mascotThemeDidChange")
}
