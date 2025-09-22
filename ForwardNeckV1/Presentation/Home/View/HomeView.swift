//
//  HomeView.swift
//  ForwardNeckV1
//
//  Fresh home page design based on brainrot app screenshot
//  Clean, minimal design with mascot, health score, and statistics
//

import SwiftUI
import FamilyControls

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingExerciseTimer = false
    @State private var isInstructionsExpanded = false
    @State private var isAppPickerPresented = false
    @State private var presentedAchievement: MonthlyAchievement?
    @State private var shouldCelebrate = false
    @State private var lastPresentedAchievement: MonthlyAchievement?
    
    var body: some View {
        ZStack {
            // Background gradient matching onboarding
            Theme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // App title
                        Text("ForwardNeck")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Mascot and health score
                        mascotSection

                        // Statistics section
                        statisticsSection
                        
                        // Next exercise prompt
                        nextExerciseSection

                        // Monthly achievements
                        monthlyAchievementsSection

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }

            }
        }
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .fullScreenCover(isPresented: $isShowingExerciseTimer) {
            if let exercise = viewModel.nextExercise {
                ExerciseTimerSheet(
                    exercise: exercise,
                    onComplete: {
                        Task { @MainActor in
                            await viewModel.completeCurrentExercise()
                            isShowingExerciseTimer = false
                        }
                    },
                    onCancel: {
                        isShowingExerciseTimer = false
                    }
                )
            } else {
                ZStack {
                    Theme.backgroundGradient
                        .ignoresSafeArea()
                    Text("No exercise available")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $viewModel.activitySelection)
        .onChange(of: viewModel.recentlyUnlockedAchievement) { newValue in
            guard let newValue else { return }
            presentedAchievement = newValue
            lastPresentedAchievement = newValue
            shouldCelebrate = true
            viewModel.clearRecentlyUnlockedAchievement()
        }
        .sheet(item: $presentedAchievement, onDismiss: {
            if shouldCelebrate, let last = lastPresentedAchievement {
                viewModel.markAchievementCelebrated(last)
            }
            shouldCelebrate = false
            lastPresentedAchievement = nil
        }) { achievement in
            AchievementUnlockedSheet(
                achievement: achievement,
                isCelebrating: shouldCelebrate
            ) {
                presentedAchievement = nil
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.hidden)
        }
    }
    
    // MARK: - Mascot Section
    
    private var mascotSection: some View {
        VStack(spacing: 16) {
            // Mascot image - made bigger
            Image(mascotAssetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            
            // Health score
            Text("\(viewModel.healthPercentage)%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            // Health bar
            VStack(spacing: 4) {
                // Progress bar - made smaller
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(LinearGradient(
                                colors: [.red, .yellow, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: max(0, geometry.size.width * barFillRatio), height: 6)
                    }
                }
                .frame(height: 6)
                
                // Health label
                HStack(spacing: 4) {
                    Text("health")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            neckFixHistorySection
        }
    }
    
    // MARK: - Statistics Section
    
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
            
            // Four column stats
            HStack(spacing: 30) {
                // Left column - App time
                VStack(alignment: .center, spacing: 6) {
                    Text(viewModel.hasMonitoredApps ? "tracked app time" : "app time")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))

                    if viewModel.hasMonitoredApps {
                        Button {
                            isAppPickerPresented = true
                        } label: {
                            Text(viewModel.trackedUsageDisplay)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .accessibilityLabel("Tracked app time \(viewModel.trackedUsageDisplay)")
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            isAppPickerPresented = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Color.white.opacity(0.12))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add apps to track usage")
                    }
                }
                .frame(maxWidth: .infinity)

                // Middle left column - Neck fixes progress
                VStack(alignment: .center, spacing: 4) {
                    Text("neck fixes")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(viewModel.neckFixesCompleted)/\(viewModel.neckFixesTarget)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                // Middle column - Record Streak (longest)
                VStack(alignment: .center, spacing: 4) {
                    Text("record streak")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(viewModel.recordStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                // Right column - Daily Streak (current)
                VStack(alignment: .center, spacing: 4) {
                    Text("daily streak")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(viewModel.currentStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Next Exercise Section

    private var nextExerciseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time To Unrot Your Neck")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            
            Group {
                if let exercise = viewModel.nextExercise {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(exercise.description)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack(spacing: 12) {
                                Label(exercise.durationLabel, systemImage: "clock")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Label(exercise.difficulty.rawValue.capitalized, systemImage: "flame")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(color(for: exercise.difficulty))
                            }
                            
                            DisclosureGroup(isExpanded: $isInstructionsExpanded) {
                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                                        Text("\(index + 1). \(instruction)")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                }
                                .padding(.top, 6)
                            } label: {
                                Label("Instructions", systemImage: "list.bullet")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .tint(.white)
                        }
                        
                        Spacer(minLength: 16)
                        
                        VStack(spacing: 8) {
                            Spacer()
                            Button(action: {
                                isShowingExerciseTimer = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.green, Color.green.opacity(0.8)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 72, height: 72)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Start \(exercise.title)")
                            
                            Text("Start")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onChange(of: viewModel.nextExercise?.id) { _ in
                        isInstructionsExpanded = false
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No exercises available right now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Check back later for a new move to keep your posture sharp.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var monthlyAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Achievements")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)

            LazyVGrid(columns: achievementColumns, spacing: 14) {
                ForEach(viewModel.monthlyAchievements) { achievement in
                    let imageName = achievement.isUnlocked ? achievement.kind.unlockedImageName : achievement.kind.lockedImageName

                    VStack {
                        Group {
                            if achievement.kind.usesSystemImage {
                                Image(systemName: imageName)
                                    .resizable()
                            } else {
                                Image(imageName)
                                    .resizable()
                            }
                        }
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .padding(4)
                        .opacity(achievement.isUnlocked ? 1 : 0.3)
                        .grayscale(achievement.isUnlocked ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: achievement.isUnlocked)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        presentedAchievement = achievement
                        lastPresentedAchievement = achievement
                        shouldCelebrate = false
                    }
                }
            }
        }
    }

    private var achievementColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

    private var neckFixHistorySection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.neckFixHistory) { summary in
                    let isSelected = Calendar.current.isDate(summary.date, inSameDayAs: viewModel.selectedNeckFixDate)
                    let dayNumber = Calendar.current.component(.day, from: summary.date)
                    let weekday = Calendar.current.isDateInToday(summary.date) ? "Today" : Self.historyWeekdayFormatter.string(from: summary.date)

                    Button {
                        viewModel.selectNeckFixDate(summary.date)
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.purple.opacity(0.65) : Color.white.opacity(0.14))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                                    )

                                Text("\(dayNumber)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text(weekday)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .textCase(.uppercase)
                                .lineLimit(1)
                        }
                        .frame(width: 60)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private static let historyWeekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private func color(for difficulty: ExerciseDifficulty) -> Color {
        switch difficulty {
        case .easy:
            return .green
        case .medium:
            return .orange
        case .hard:
            return .red
        }
    }

    private var barFillRatio: CGFloat {
        let ratio = Double(viewModel.healthPercentage) / 100.0
        return CGFloat(min(max(ratio, 0.0), 1.0))
    }

    private var mascotAssetName: String {
        let percentage = viewModel.healthPercentage
        switch percentage {
        case ..<25:
            return "mascot1"
        case 25..<50:
            return "mascot2"
        case 50..<75:
            return "mascot3"
        default:
            return "mascot4"
        }
    }

    private struct ExerciseTimerSheet: View {
        let exercise: Exercise
        let onComplete: () -> Void
        let onCancel: () -> Void

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text(exercise.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Steps")
                            .font(.headline)
                            .foregroundColor(.white)
                        ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                            Text("\(index + 1). \(instruction)")
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    
                    ExerciseCountdownTimer(
                        durationSeconds: exercise.durationSeconds,
                        autoStart: true,
                        onComplete: onComplete,
                        onCancel: onCancel
                    )
                }
                .padding(24)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
        }
    }

}

private struct AchievementUnlockedSheet: View {
    let achievement: MonthlyAchievement
    let isCelebrating: Bool
    let onDismiss: () -> Void

    @State private var animateOverlay = false
    @State private var confettiActive = false

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    achievementArtwork
                        .frame(width: 190, height: 190)
                        .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 18)

                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 3)
                        .frame(width: 210, height: 210)
                        .scaleEffect(animateOverlay ? 1.08 : 0.92)
                        .opacity(animateOverlay ? 0.1 : 0.28)

                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 2)
                        .frame(width: 230, height: 230)
                        .scaleEffect(animateOverlay ? 1.15 : 0.85)
                        .opacity(animateOverlay ? 0.05 : 0.16)
                }
                .frame(height: 210)
                .onAppear {
                    withAnimation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
                        animateOverlay = true
                    }
                }

                VStack(spacing: 8) {
                    Text(achievement.isUnlocked ? "Achievement Unlocked!" : "Achievement Goal")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)

                    Text(achievement.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }

                Button(action: onDismiss) {
                    Text(achievement.isUnlocked ? "Good Job!" : "Got it")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.purple.opacity(0.3), radius: 12, x: 0, y: 8)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)
            .padding(.bottom, 36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white.opacity(0.12))
        }
        .overlay(
            ConfettiOverlay(isActive: $confettiActive)
        )
        .ignoresSafeArea()
        .onAppear {
            if isCelebrating {
                confettiActive = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    confettiActive = false
                }
            }
        }
        .onDisappear {
            confettiActive = false
        }
    }

    @ViewBuilder
    private var achievementArtwork: some View {
        Group {
            if achievement.kind.usesSystemImage {
                Image(systemName: achievement.kind.unlockedImageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
            } else {
                Image(achievement.kind.unlockedImageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .opacity(achievement.isUnlocked ? 1 : 0.35)
        .grayscale(achievement.isUnlocked ? 0 : 1)
    }
}

private struct ConfettiOverlay: View {
    @Binding var isActive: Bool
    @State private var pieces: [ConfettiPiece] = []

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiPieceView(
                        piece: piece,
                        containerSize: proxy.size,
                        isActive: $isActive
                    )
                }
            }
            .onChange(of: isActive) { active in
                if active {
                    pieces = ConfettiPiece.generate(count: 36, height: proxy.size.height)
                } else {
                    pieces.removeAll()
                }
            }
            .onAppear {
                if isActive {
                    pieces = ConfettiPiece.generate(count: 36, height: proxy.size.height)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let isLeft: Bool
    let startY: CGFloat
    let delay: Double
    let duration: Double
    let size: CGFloat
    let color: Color

    static func generate(count: Int, height: CGFloat) -> [ConfettiPiece] {
        let colors: [Color] = [.pink, .purple, .blue, .yellow, .orange, .green]
        return (0..<count).map { index in
            let isLeft = index.isMultiple(of: 2)
            return ConfettiPiece(
                isLeft: isLeft,
                startY: CGFloat.random(in: 20...(height * 0.5).clamped(to: 20...height)),
                delay: Double.random(in: 0...0.8),
                duration: Double.random(in: 2.6...4.2),
                size: CGFloat.random(in: 8...16),
                color: colors.randomElement() ?? .white
            )
        }
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

private struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let containerSize: CGSize
    @Binding var isActive: Bool
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0

    var body: some View {
        Rectangle()
            .fill(piece.color)
            .frame(width: piece.size, height: piece.size * 0.35)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear { startAnimation() }
            .onChange(of: isActive) { newValue in
                if newValue {
                    startAnimation()
                } else {
                    opacity = 0
                }
            }
    }

    private func startAnimation() {
        guard isActive else { return }
        let startX = piece.isLeft ? -60.0 : containerSize.width + 60.0
        let endX = piece.isLeft ? containerSize.width + 60.0 : -60.0
        position = CGPoint(x: startX, y: piece.startY)
        rotation = 0
        opacity = 0

        withAnimation(.easeOut(duration: piece.duration).delay(piece.delay)) {
            position = CGPoint(x: endX, y: piece.startY + containerSize.height * 0.85)
        }

        withAnimation(.linear(duration: piece.duration).repeatForever(autoreverses: false).delay(piece.delay)) {
            rotation = piece.isLeft ? 720 : -720
        }

        withAnimation(.easeIn(duration: 0.2).delay(piece.delay)) {
            opacity = 1
        }

        let fadeDelay = piece.delay + max(0, piece.duration - 0.6)
        withAnimation(.easeOut(duration: 0.6).delay(fadeDelay)) {
            opacity = 0
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
