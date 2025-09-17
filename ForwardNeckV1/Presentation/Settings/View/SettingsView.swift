//
//  SettingsView.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

/// Comprehensive Settings screen with reminders, reset options, and dark mode
/// Part of B-009: Finish S-007 Settings Screen
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    @State private var showingAddReminder: Bool = false
    
    var body: some View {
        ZStack {
            // Dynamic background based on theme
            if viewModel.isDarkMode {
                Color.black.ignoresSafeArea()
            } else {
                Theme.backgroundGradient.ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Reminders Section
                    remindersSection
                    
                    // Theme Section
                    themeSection
                    
                    // Reset Section
                    resetSection
                    
                    // App Info Section
                    appInfoSection
                }
                .padding(16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadSettings()
            Log.info("SettingsView appeared")
        }
        .alert("Reset Data", isPresented: $viewModel.showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.performReset()
            }
        } message: {
            Text(viewModel.resetType.description)
        }
    }
    
    /// Reminders section with list and add functionality
    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(.white)
                Text("Reminders")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button("Add") {
                    showingAddReminder = true
                }
                .foregroundColor(.blue)
                .font(.subheadline.bold())
            }
            
            // Reminders list
            VStack(spacing: 8) {
                ForEach(viewModel.reminders) { reminder in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reminder.timeString)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            Text(reminder.enabled ? "Enabled" : "Disabled")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { reminder.enabled },
                            set: { _ in viewModel.toggleReminder(reminder) }
                        ))
                        .labelsHidden()
                    }
                    .padding(12)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if viewModel.reminders.isEmpty {
                    Text("No reminders set")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            addReminderSheet
        }
    }
    
    /// Theme selection section
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.white)
                Text("Appearance")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Theme options
            VStack(spacing: 8) {
                ForEach(ThemeManager.AppTheme.allCases) { theme in
                    Button(action: {
                        viewModel.setTheme(theme)
                    }) {
                        HStack {
                            Image(systemName: theme.icon)
                                .foregroundColor(.white)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(theme.rawValue)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                Text(theme.description)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            if viewModel.currentTheme == theme {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(12)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    /// Reset options section
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
                Text("Reset Data")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Reset options
            VStack(spacing: 8) {
                ForEach(SettingsViewModel.ResetType.allCases) { resetType in
                    Button(action: {
                        viewModel.showResetAlert(for: resetType)
                    }) {
                        HStack {
                            Image(systemName: resetType.icon)
                                .foregroundColor(resetType == .allData ? .red : .white)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(resetType.rawValue)
                                    .font(.subheadline.bold())
                                    .foregroundColor(resetType == .allData ? .red : .white)
                                Text(resetType.description)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.caption)
                        }
                        .padding(12)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    /// App information section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.white)
                Text("App Information")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // App info
            VStack(spacing: 12) {
                HStack {
                    Text("App Name")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(viewModel.appName)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Version")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(viewModel.appVersion)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Build")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("B-009")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
            }
            .padding(12)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    /// Add reminder sheet
    private var addReminderSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add New Reminder")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                DatePicker("Time", selection: $viewModel.newTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .colorScheme(.dark)
                    .labelsHidden()
                
                Button("Add Reminder") {
                    viewModel.addReminder(time: viewModel.newTime)
                    showingAddReminder = false
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding(20)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingAddReminder = false
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
