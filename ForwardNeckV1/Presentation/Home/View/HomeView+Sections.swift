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
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [.red, .yellow, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geometry.size.width * barFillRatio), height: 6)
                    }
                }
                .frame(height: 6)

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
                    Text(viewModel.hasMonitoredApps ? "tracked app time" : "app time")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 2)

                    Text(viewModel.hasMonitoredApps ? viewModel.trackedUsageDisplay : "0m")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)

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
        VStack(alignment: .leading, spacing: 12) {
            Text("Time To Unrot Your Neck")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Group {
                if let exercise = viewModel.nextExercise {
                    exerciseCard(for: exercise)
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
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1.2)
            )
            .onAppear {
                Log.debug("HomeView nextExerciseSection card applied 3D shadow stack")
            }
        }
        .debugOutline(.green, enabled: debugOutlines)
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
        .debugOutline(.blue, enabled: debugOutlines)
    }


    var barFillRatio: CGFloat {
        let ratio = Double(viewModel.healthPercentage) / 100.0
        return CGFloat(min(max(ratio, 0.0), 1.0))
    }
}
