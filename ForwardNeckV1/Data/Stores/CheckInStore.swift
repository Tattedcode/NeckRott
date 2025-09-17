//
//  CheckInStore.swift
//  ForwardNeckV1
//
//  Simple on-device persistence for posture check-ins using JSON in Application Support.
//  No internet required. Thread-safe via main-actor calls from ViewModels.
//

import Foundation

@MainActor
final class CheckInStore {
    // Singleton-like shared instance for now (can inject later)
    static let shared = CheckInStore()

    private let fileURL: URL
    private var cache: [PostureCheckIn] = []

    private init() {
        let fm = FileManager.default
        let base = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        self.fileURL = (base ?? URL(fileURLWithPath: NSTemporaryDirectory())).appendingPathComponent("checkins.json")
        Task { await load() }
    }

    // Returns all stored check-ins
    func all() -> [PostureCheckIn] { cache }

    // Adds a new check-in for now
    func addNow() async {
        let item = PostureCheckIn()
        cache.append(item)
        Log.info("Added check-in at \(item.timestamp)")
        await save()
    }

    // MARK: - File IO

    private func load() async {
        do {
            let data = try Data(contentsOf: fileURL)
            let items = try JSONDecoder().decode([PostureCheckIn].self, from: data)
            cache = items
            Log.info("Loaded \(items.count) check-ins from disk")
        } catch {
            // First run or error → start with empty
            cache = []
            Log.info("No existing check-ins file. Starting fresh. Error: \(error.localizedDescription)")
        }
    }

    private func save() async {
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: fileURL, options: .atomic)
            Log.info("Saved \(cache.count) check-ins to disk")
        } catch {
            Log.error("Failed to save check-ins: \(error.localizedDescription)")
        }
    }
    
    /// Reset all check-ins data
    /// Useful for testing and fresh start
    func resetAll() {
        cache = []
        Task {
            await save()
            Log.info("Reset all check-ins data")
        }
    }
}


