//
//  ReminderStore.swift
//  ForwardNeckV1
//
//  Persists an array of daily reminder times to disk.
//

import Foundation

@MainActor
final class ReminderStore {
    static let shared = ReminderStore()

    private let fileURL: URL
    private(set) var reminders: [Reminder] = []

    private init() {
        let fm = FileManager.default
        let base = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.fileURL = (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("reminders.json")
        Task { await load() }
    }

    func all() -> [Reminder] { reminders }

    func add(hour: Int, minute: Int, enabled: Bool = true) async -> Reminder {
        let new = Reminder(hour: hour, minute: minute, enabled: enabled)
        reminders.append(new)
        await save()
        Log.info("Added reminder at \(new.timeString)")
        return new
    }

    func update(_ reminder: Reminder) async {
        if let idx = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[idx] = reminder
            await save()
        }
    }

    func remove(id: UUID) async {
        reminders.removeAll { $0.id == id }
        await save()
    }

    // MARK: - IO
    private func load() async {
        do {
            let data = try Data(contentsOf: fileURL)
            let items = try JSONDecoder().decode([Reminder].self, from: data)
            reminders = items
            Log.info("Loaded \(items.count) reminders")
        } catch {
            // Seed defaults on first run: morning, lunch, evening
            reminders = [Reminder(hour: 9, minute: 0), Reminder(hour: 13, minute: 0), Reminder(hour: 18, minute: 0)]
            await save()
            Log.info("Seeded default reminders (9:00, 1:00, 6:00)")
        }
    }

    private func save() async {
        do {
            let data = try JSONEncoder().encode(reminders)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            Log.error("Failed saving reminders: \(error.localizedDescription)")
        }
    }
}


