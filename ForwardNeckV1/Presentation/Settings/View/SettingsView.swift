//
//  SettingsView.swift
//  ForwardNeckV1
//
//  Redesigned settings screen inspired by the provided mockups.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel = SettingsViewModel()
    @Environment(\.openURL) var openURL
    @State var showResetConfirmation = false
    @State var showResetSuccess = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    header
                    screenTimeSection
                    widgetSection
                    supportSection
                    legalSection
                    resetSection
                    socialSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showingWidgetSheet) {
            WidgetSetupSheet(
                isConfigured: viewModel.widgetConfigured,
                onDone: { viewModel.showingWidgetSheet = false },
                onToggleConfigured: viewModel.markWidgetConfigured
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .confirmationDialog("Reset All Progress?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { viewModel.resetAppData() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This clears streaks, exercise history, goals, and achievements. This action cannot be undone.")
        }
        .alert("Data Reset", isPresented: $showResetSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All stats and achievements have been reset.")
        }
        .onChange(of: viewModel.resetCompleted) { completed in
            guard completed else { return }
            showResetSuccess = true
            viewModel.acknowledgeResetCompletion()
        }
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
