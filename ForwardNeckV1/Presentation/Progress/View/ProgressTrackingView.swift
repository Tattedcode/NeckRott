//
//  ProgressTrackingView.swift
//  ForwardNeckV1
//
//  Calendar-first stats screen inspired by the brainrot calendar design.
//

import SwiftUI

struct ProgressTrackingView: View {
    @StateObject var viewModel = ProgressTrackingViewModel()

    private let backgroundGradient = Theme.backgroundGradient

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    calendarCard
                    summarySection
                    dailySummarySection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack { ProgressTrackingView() }
}
