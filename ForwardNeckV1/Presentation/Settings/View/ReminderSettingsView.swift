//
//  ReminderSettingsView.swift
//  ForwardNeckV1
//
//  Allows users to add/remove daily reminder times.
//

import SwiftUI

struct ReminderSettingsView: View {
    @State private var reminders: [Reminder] = ReminderStore.shared.all()
    @State private var newTime: Date = Date()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 16) {
                List {
                    ForEach(reminders) { reminder in
                        HStack {
                            Text(reminder.timeString)
                                .foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: binding(for: reminder))
                                .labelsHidden()
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: delete)
                }
                .scrollContentBackground(.hidden)

                // Add new reminder row
                HStack(spacing: 12) {
                    DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .colorScheme(.dark)
                    Button(action: add) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding(12)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(16)
            .navigationTitle("Reminders")
            .toolbarRole(.editor)
        }
        .onAppear { Task { await refresh() } }
    }

    // MARK: - Actions
    private func add() {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: newTime)
        Task { @MainActor in
            _ = await ReminderStore.shared.add(hour: comps.hour ?? 9, minute: comps.minute ?? 0)
            await refresh()
            await NotificationManager.shared.scheduleAll(from: reminders)
        }
    }

    private func delete(at offsets: IndexSet) {
        Task { @MainActor in
            for index in offsets { await ReminderStore.shared.remove(id: reminders[index].id) }
            await refresh()
            await NotificationManager.shared.scheduleAll(from: reminders)
        }
    }

    private func refresh() async {
        reminders = ReminderStore.shared.all()
    }

    private func binding(for reminder: Reminder) -> Binding<Bool> {
        let idx = reminders.firstIndex(of: reminder)!
        return Binding<Bool>(
            get: { reminders[idx].enabled },
            set: { newValue in
                reminders[idx].enabled = newValue
                Task { await ReminderStore.shared.update(reminders[idx]); await NotificationManager.shared.scheduleAll(from: reminders) }
            }
        )
    }
}

#Preview {
    NavigationStack { ReminderSettingsView() }
}


