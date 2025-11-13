//
//  HomeView+ExerciseCard.swift
//  ForwardNeckV1
//
//  Exercise card rendering and helpers.
//

import SwiftUI

extension HomeView {
    // MARK: - Compact Exercise Card (for side-by-side layout)
    
    /// Compact exercise card with time slot status support
    @ViewBuilder
    func compactExerciseCard(title: String, subtitle: String = "", exercise: Exercise?, status: SlotStatus, slot: ExerciseTimeSlot, onStart: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(statusTextColor(for: status))
                    
                    statusIcon(for: status, slot: slot)
                }
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(statusTextColor(for: status).opacity(0.7))
                }
                
                if status == .locked {
                    if slot == .morning {
                        // Show cooldown for Quick Workout (30 minutes)
                        let cooldownCheck = ExerciseStore.shared.canStartSlot(.morning, cooldownMinutes: 30)
                        if let timeRemaining = cooldownCheck.timeRemaining {
                            Text("Available in \(ExerciseTimeSlot.formatTimeInterval(timeRemaining))")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                    } else if slot == .afternoon {
                        // Show countdown until 6am next day for Full Daily Workout
                        if let timeUntil = timeUntil6AMNextDay() {
                            Text("Available in \(ExerciseTimeSlot.formatTimeInterval(timeUntil))")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.red)
                                .padding(.top, 4)
                        }
                    } else if let timeUntil = slot.timeUntilAvailable() {
                        // Show time-based lock for other slots
                        Text("Available in \(ExerciseTimeSlot.formatTimeInterval(timeUntil))")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.orange)
                            .padding(.top, 4)
                    }
                }
                
                if status != .locked {
                    if slot == .morning {
                        Text("Complete a random workout for neck health")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(statusTextColor(for: status).opacity(0.7))
                            .lineLimit(1)
                    } else if slot == .afternoon {
                        Text("Fully strengthen your neck")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(statusTextColor(for: status).opacity(0.7))
                            .lineLimit(1)
                    } else if let exercise = exercise {
                        Text(exercise.description)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(statusTextColor(for: status).opacity(0.7))
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onStart) {
                ZStack {
                    Circle()
                        .fill(buttonGradient(for: status))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: buttonIcon(for: status))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(status != .available)
            .opacity(status == .available ? 1.0 : 0.5)
            .accessibilityLabel(accessibilityLabel(for: status, slot: slot))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cardBackground(for: status))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(cardBorder(for: status), lineWidth: 1)
        )
    }
    
    // MARK: - Status Helpers
    
    @ViewBuilder
    private func statusIcon(for status: SlotStatus, slot: ExerciseTimeSlot) -> some View {
        Group {
            switch status {
            case .locked:
                // Show lock icon for both Quick Workout and Full Daily Workout when locked
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            case .available:
                Image(systemName: "clock.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }
        }
    }
    
    private func statusTextColor(for status: SlotStatus) -> Color {
        switch status {
        case .locked, .completed:
            return .black.opacity(0.7)
        case .available:
            return .black
        }
    }
    
    /// Get description text for exercise card based on slot
    private func descriptionText(for slot: ExerciseTimeSlot, exercise: Exercise?) -> String {
        switch slot {
        case .morning:
            return "Complete a random workout for neck health"
        case .afternoon:
            return "Fully strengthen your neck"
        }
    }
    
    private func buttonGradient(for status: SlotStatus) -> LinearGradient {
        switch status {
        case .available:
            return LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 1.0),
                    Color(red: 0.1, green: 0.3, blue: 0.8)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return LinearGradient(
                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private func buttonIcon(for status: SlotStatus) -> String {
        switch status {
        case .locked:
            return "lock.fill"
        case .available:
            return "play.fill"
        case .completed:
            return "checkmark"
        }
    }
    
    private func cardBackground(for status: SlotStatus) -> Color {
        switch status {
        case .locked, .completed:
            return Color.white.opacity(0.05)
        case .available:
            return Color.white.opacity(0.08)
        }
    }
    
    private func cardBorder(for status: SlotStatus) -> Color {
        switch status {
        case .locked:
            return Color.black.opacity(0.15)
        case .available:
            return Color.black.opacity(0.2)
        case .completed:
            return Color.black.opacity(0.15)
        }
    }
    
    private func accessibilityLabel(for status: SlotStatus, slot: ExerciseTimeSlot) -> String {
        switch status {
        case .locked:
            return "\(slot.rawValue) exercise locked"
        case .available:
            return "Start \(slot.rawValue) exercise"
        case .completed:
            return "\(slot.rawValue) exercise completed"
        }
    }
    
    // MARK: - Original Exercise Card (legacy)
    
    @ViewBuilder
    func exerciseCard(for exercise: Exercise) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(exercise.description)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                exerciseMeta(for: exercise)

                DisclosureGroup(isExpanded: $isInstructionsExpanded) {
                    instructionList(for: exercise)
                } label: {
                    HStack(spacing: 6) {
                        Text("Instructions")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isInstructionsExpanded ? 90 : 0))
                            .animation(.easeInOut(duration: 0.2), value: isInstructionsExpanded)
                    }
                }
                .tint(.white)
            }

            Spacer(minLength: 16)

            VStack(spacing: 8) {
                Button(action: { isShowingExerciseTimer = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.5, blue: 1.0),   // bright blue
                                        Color(red: 0.1, green: 0.3, blue: 0.8)    // deeper blue
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 72, height: 72)
                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Start \(exercise.title)")

                Text("Start")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 90, alignment: .top)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    func exerciseMeta(for exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            Label(exercise.durationLabel, systemImage: "clock")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white.opacity(0.8))

            Label(exercise.difficulty.rawValue.capitalized, systemImage: "flame")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color(for: exercise.difficulty))
        }
    }

    @ViewBuilder
    func instructionList(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                Text("\(index + 1). \(instruction)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(.top, 6)
    }

    func color(for difficulty: ExerciseDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }
    
    /// Calculate time until 6am next day (for Full Daily Workout lockout)
    private func timeUntil6AMNextDay() -> TimeInterval? {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 6
        components.minute = 0
        components.second = 0
        
        // If it's before 6am today, return time until 6am today
        if hour < 6 {
            if let today6AM = calendar.date(from: components) {
                return today6AM.timeIntervalSince(now)
            }
        } else {
            // If it's after 6am, return time until 6am tomorrow
            components.day! += 1
            if let tomorrow6AM = calendar.date(from: components) {
                return tomorrow6AM.timeIntervalSince(now)
            }
        }
        
        return nil
    }
}
