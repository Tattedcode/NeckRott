//
//  HomeView.swift
//  ForwardNeckV1
//
//  Fresh home page design based on brainrot app screenshot
//  Clean, minimal design with mascot, health score, and statistics
//

import SwiftUI
import FamilyControls

// Toggle to show colored debug outlines around major views
private let debugOutlines: Bool = false

private extension View {
    @ViewBuilder
    func debugOutline(_ color: Color, enabled: Bool) -> some View {
        if enabled {
            self.overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            )
        } else {
            self
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isShowingExerciseTimer = false
    @State private var isInstructionsExpanded = false
    @State private var isAppPickerPresented = false
    @State private var presentedAchievement: MonthlyAchievement?
    @State private var shouldCelebrate = false
    @State private var lastPresentedAchievement: MonthlyAchievement?
    @State private var flamePulse = false
    
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

                        // Next exercise prompt
                        nextExerciseSection

                        // Statistics section
                        statisticsSection

                        // History cards for the last few days
                        previousDatesSection

                        // Monthly achievements
                        monthlyAchievementsSection

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }

            }

            // Dim the home content slightly when the achievement sheet is visible
            if presentedAchievement != nil {
                Color.black.opacity(0.22)
                    .ignoresSafeArea()
                    .transition(.opacity)
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
        let mascotName = viewModel.heroMascotName

        return VStack(spacing: 16) {
            // Hero mascot image matches the current health percentage so the UI feels alive
            Image(mascotName)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                // Subtle bottom shadow so the hero mascot lifts off the background
                .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
                
                .accessibilityHidden(true)
                .onAppear {
        Log.info("HomeView hero mascot displayed: \(mascotName) for health \(viewModel.healthPercentage)%")
                }
            
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
        }
        .debugOutline(.red, enabled: debugOutlines)
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
                    HStack(spacing: 6) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        if viewModel.currentStreak >= 1 {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .scaleEffect(flamePulse ? 1.15 : 0.9)
                                .opacity(flamePulse ? 1.0 : 0.75)
                                .onAppear { withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { flamePulse = true } }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .debugOutline(.yellow, enabled: debugOutlines)
    }

    /// What each mini card looks like (mascot on left, score on right)
    private struct PreviousDayCardView: View {
        let card: PreviousDaySummary

        var body: some View {
            GeometryReader { geometry in
                let height = geometry.size.height
                let mascotSize = height * 0.72
                let percentageFont = height * 0.3
                let dateFont = height * 0.11

                HStack(alignment: .center, spacing: 16) {
                    // Mascot sits on the left and gets as much space as possible
                    Image(card.mascotAssetName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                        .frame(width: mascotSize, height: mascotSize)
                        // Darker shadow under mini mascot thumbnails
                        
                        .accessibilityHidden(true)

                    Spacer(minLength: 0)

                    // Percentage is huge, with the date tucked underneath
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(card.percentageText)
                            .font(.system(size: percentageFont, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .allowsTightening(true)

                        Text(card.label)
                            .font(.system(size: dateFont, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    .padding(.trailing, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(width: 180, height: 96)
            .background(Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
            )
            // Dual shadows to create a soft 3D effect on the gradient background
            
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(card.label) \(card.percentageText)")
            .onAppear {
                Log.debug("HomeView previous day card 3D shadow applied for \(card.label)")
            }
        }
    }

    // MARK: - Next Exercise Section

    private var nextExerciseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time To Unrot Your Neck")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)
            
            Group {
                if let exercise = viewModel.nextExercise {
                    exerciseCard(for: exercise)
                    // Lift the entire exercise card block with multi-layered shadows for a 3D pop
                    
                    .onAppear {
                        Log.debug("HomeView next exercise card elevated for \(exercise.title)")
                    }
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
                    // Shadow sits on the background shape only, not on inner content/buttons
                    
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
            )
            // Outer shadows make the timer/instructions card feel layered above the gradient
            
            .onAppear {
                Log.debug("HomeView nextExerciseSection card applied 3D shadow stack")
            }
        }
        .debugOutline(.green, enabled: debugOutlines)
    }

    /// Carousel that shows how you did on recent days (mascot left, score right)
    private var previousDatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Previous 7 Days")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            if viewModel.previousDayCards.isEmpty {
                Text("Complete exercises to unlock your history ✨")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.previousDayCards) { card in
                            PreviousDayCardView(card: card)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .debugOutline(.blue, enabled: debugOutlines)
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
        .debugOutline(.purple, enabled: debugOutlines)
    }

    private var achievementColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    }

    private var barFillRatio: CGFloat {
        let ratio = Double(viewModel.healthPercentage) / 100.0
        return CGFloat(min(max(ratio, 0.0), 1.0))
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

    // Brighter gradient for the action button so the sheet feels celebratory and light
    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.62, blue: 0.98),
                Color(red: 0.72, green: 0.52, blue: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // Light purplish gradient so the sheet feels bright but readable
    private var sheetGradient: LinearGradient { Theme.backgroundGradient }

    var body: some View {
        ZStack {
            // Light purplish gradient (brighter than HomeView's background)
            sheetGradient
                .ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    achievementArtwork
                        .frame(width: 190, height: 190)
                        

                    Circle()
                        .stroke(Color.white.opacity(0.55), lineWidth: 3)
                        .frame(width: 210, height: 210)
                        .scaleEffect(animateOverlay ? 1.08 : 0.92)
                        .opacity(animateOverlay ? 0.25 : 0.4)

                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 230, height: 230)
                        .scaleEffect(animateOverlay ? 1.15 : 0.85)
                        .opacity(animateOverlay ? 0.12 : 0.26)
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
                        .background(buttonGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)
            .padding(.bottom, 36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .overlay(
            ConfettiOverlay(isActive: $confettiActive)
        )
        .ignoresSafeArea()
        .onAppear {
            Log.debug("AchievementUnlockedSheet bright styling applied for \(achievement.title)")
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

// MARK: - Helpers

private extension HomeView {
    @ViewBuilder
    func exerciseCard(for exercise: Exercise) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(exercise.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)

                exerciseMeta(for: exercise)

                DisclosureGroup(isExpanded: $isInstructionsExpanded) {
                    instructionList(for: exercise)
                } label: {
                    Label("Instructions", systemImage: "list.bullet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .tint(.white)
            }

            Spacer(minLength: 16)

            VStack(spacing: 8) {
                Button(action: {
                    isShowingExerciseTimer = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 72, height: 72)
                        Image(systemName: "play.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel("Start \(exercise.title)")

                Text("Start")
                    .font(.system(size: 14, weight: .semibold))
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
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))

            Label(exercise.difficulty.rawValue.capitalized, systemImage: "flame")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color(for: exercise.difficulty))
        }
    }

    @ViewBuilder
    func instructionList(for exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                Text("\(index + 1). \(instruction)")
                    .font(.system(size: 13))
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
}

// MARK: - Preview

#Preview {
    HomeView()
}
