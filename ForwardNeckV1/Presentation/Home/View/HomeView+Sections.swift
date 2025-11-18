//
//  HomeView+Sections.swift
//  NeckRotV1
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
                .frame(height: 220)
                .accessibilityHidden(true)
                .onAppear {
                    Log.info("HomeView hero mascot displayed: \(mascotName) for health \(viewModel.healthPercentage)%")
                }

            Text("\(viewModel.healthPercentage)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.black)

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

                Text("Neck health")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
                
                Text("Level: \(viewModel.currentLevel)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black.opacity(0.7))
            }
        }
        .padding(.bottom, 8)
        .debugOutline(.red, enabled: debugOutlines)
    }

    // MARK: - Stats

    var statisticsSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.2))
                .frame(height: 1)

            Spacer().frame(height: 16)

            HStack(spacing: 20) {
                // Rank section (first column)
                VStack(spacing: 4) {
                    Text("rank")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, 2)
                    
                    if LeaderboardStore.shared.hasJoinedLeaderboard {
                        if let rank = LeaderboardStore.shared.currentUserRank {
                            Text("#\(rank)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        } else {
                            Button(action: {
                                selectedTab = .leaderboard
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        Button(action: {
                            selectedTab = .leaderboard
                        }) {
                            Text("Join")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(Color.green)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Today section
                VStack(spacing: 4) {
                    Text("today")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, 2)
                    Text("\(viewModel.neckFixesCompleted)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                // Record section
                VStack(spacing: 4) {
                    Text("record")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, 2)
                    Text("\(viewModel.recordStreak)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                // Daily streak section
                VStack(spacing: 4) {
                    Text("daily streak")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.top, 2)

                    HStack(spacing: 6) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)

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
            VStack(spacing: 12) {
                // Connect 4 Card - always available
                connect4Card()
                
                // Quick Workout Exercise Card
                timeSlotExerciseCard(
                    slot: .morning,
                    status: viewModel.morningSlotStatus,
                    exercise: viewModel.dailyUnrotExercise
                )
                
                // Full Daily Workout Exercise Card - always show (locked with countdown when completed)
                timeSlotExerciseCard(
                    slot: .afternoon,
                    status: viewModel.afternoonSlotStatus,
                    exercise: viewModel.dailyUnrotExercise
                )
            }
        }
        .debugOutline(.green, enabled: debugOutlines)
    }
    
    // MARK: - Connect 4 Card
    
    @ViewBuilder
    func connect4Card() -> some View {
        Button(action: {
            // Show Connect 4 matchmaking view (it will start matchmaking automatically)
            isShowingConnect4 = true
        }) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Connect 4")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                    
                    Text("Play against other players while maintaining good posture")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.5, blue: 1.0),
                                    Color(red: 0.1, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
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
            
            // For Full Daily Workout (afternoon), navigate to Circuit tab instead of showing timer
            if slot == .afternoon {
                selectedTab = .circuit
                Log.debug("HomeView navigating to Circuit tab for Full Daily Workout")
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
                .foregroundColor(.black)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, 20) // Add padding to title only

            if viewModel.previousDayCards.isEmpty {
                Text("Complete exercises to unlock your history ✨")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black.opacity(0.6))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20) // Add padding to empty state
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.previousDayCards) { card in
                            PreviousDayCardView(card: card)
                        }
                    }
                    .padding(.horizontal, 20) // Add horizontal padding to content
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
