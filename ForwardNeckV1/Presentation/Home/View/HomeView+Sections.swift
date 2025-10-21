//
//  HomeView+Sections.swift
//  ForwardNeckV1
//
//  Primary content sections for the home dashboard.
//

import SwiftUI

extension HomeView {
    // MARK: - Mascot

    var mascotSection: some View {
        let mascotName = viewModel.heroMascotName

        return VStack(spacing: 16) {
            Image(mascotName)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 10)
                .accessibilityHidden(true)
                .onAppear {
                    Log.info("HomeView hero mascot displayed: \(mascotName) for health \(viewModel.healthPercentage)%")
                }

            Text("\(viewModel.healthPercentage)%")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.red, .yellow, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geometry.size.width * barFillRatio), height: 8)
                    }
                }
                .frame(height: 8)

                HStack(spacing: 4) {
                    Text("health")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Image(systemName: "info.circle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .debugOutline(.red, enabled: debugOutlines)
    }

    // MARK: - Stats

    var statisticsSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)

            Spacer().frame(height: 16)

            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("neck fixes")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                    Text("\(viewModel.neckFixesCompleted)/\(viewModel.neckFixesTarget)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("record")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)
                    Text("\(viewModel.recordStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("daily streak")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 2)

                    HStack(spacing: 6) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)

                        if viewModel.currentStreak >= 1 {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .scaleEffect(flamePulse ? 1.15 : 0.9)
                                .opacity(flamePulse ? 1.0 : 0.75)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                                        flamePulse = true
                                    }
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .debugOutline(.yellow, enabled: debugOutlines)
    }

    // MARK: - Next Exercise

    var nextExerciseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Exercises")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Quick Workout Exercise Card
                timeSlotExerciseCard(
                    slot: .morning,
                    status: viewModel.morningSlotStatus,
                    exercise: viewModel.dailyUnrotExercise
                )
                
                // Full Daily Workout Exercise Card - only show if not completed today
                if viewModel.afternoonSlotStatus != .completed {
                    timeSlotExerciseCard(
                        slot: .afternoon,
                        status: viewModel.afternoonSlotStatus,
                        exercise: viewModel.dailyUnrotExercise
                    )
                }
            }
        }
        .debugOutline(.green, enabled: debugOutlines)
    }
    
    @ViewBuilder
    func timeSlotExerciseCard(slot: ExerciseTimeSlot, status: SlotStatus, exercise: Exercise?) -> some View {
        compactExerciseCard(
            title: slot.rawValue,
            subtitle: slot.timeRangeString,
            exercise: exercise,
            status: status,
            slot: slot
        ) {
            // Check if user can start this exercise
            guard viewModel.checkCanStartExercise(for: slot) else { return }
            
            // For Full Daily Workout (afternoon), navigate to Plan tab instead of showing timer
            if slot == .afternoon {
                selectedTab = .plan
                Log.debug("HomeView navigating to Plan tab for Full Daily Workout")
            } else {
                // For Quick Workout (morning), show timer as before
                viewModel.currentTimeSlot = slot
                viewModel.nextExercise = exercise
                isShowingExerciseTimer = true
                Log.debug("HomeView starting \(slot.rawValue) exercise: \(exercise?.title ?? "nil")")
            }
        }
    }

    // MARK: - History

    var previousDatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Previous 7 Days")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            if viewModel.previousDayCards.isEmpty {
                Text("Complete exercises to unlock your history ✨")
                    .font(.system(size: 14, weight: .bold))
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
        .padding(.bottom, 20) // Add bottom padding to create gap from tab bar
        .debugOutline(.blue, enabled: debugOutlines)
    }


    var barFillRatio: CGFloat {
        let ratio = Double(viewModel.healthPercentage) / 100.0
        return CGFloat(min(max(ratio, 0.0), 1.0))
    }
}
