//
//  ThemeManager.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI
import Combine

/// Manages app theme and dark mode settings
/// Part of B-009: Finish S-007 Settings Screen with dark mode
@MainActor
final class ThemeManager: ObservableObject {
    /// Shared instance for singleton pattern
    static let shared = ThemeManager()
    
    /// Published property for theme changes
    @Published var isDarkMode: Bool = false
    
    /// Published property for current theme
    @Published var currentTheme: AppTheme = .light
    
    /// Available app themes
    enum AppTheme: String, CaseIterable, Identifiable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
        
        var id: String { rawValue }
        
        /// Icon for the theme
        var icon: String {
            switch self {
            case .light:
                return "sun.max.fill"
            case .dark:
                return "moon.fill"
            case .system:
                return "gear"
            }
        }
        
        /// Description of the theme
        var description: String {
            switch self {
            case .light:
                return "Always use light appearance"
            case .dark:
                return "Always use dark appearance"
            case .system:
                return "Follow system appearance"
            }
        }
    }
    
    /// Initialize theme manager
    private init() {
        loadTheme()
        Log.info("ThemeManager initialized with theme: \(currentTheme.rawValue)")
    }
    
    /// Set the app theme
    /// - Parameter theme: The theme to set
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        updateDarkMode()
        saveTheme()
        Log.info("Theme changed to: \(theme.rawValue)")
    }
    
    /// Update dark mode based on current theme
    private func updateDarkMode() {
        switch currentTheme {
        case .light:
            isDarkMode = false
        case .dark:
            isDarkMode = true
        case .system:
            // Follow system appearance
            isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        }
    }
    
    /// Save theme preference to UserDefaults
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
        Log.info("Theme preference saved: \(currentTheme.rawValue)")
    }
    
    /// Load theme preference from UserDefaults
    private func loadTheme() {
        let savedTheme = UserDefaults.standard.string(forKey: "AppTheme") ?? AppTheme.system.rawValue
        currentTheme = AppTheme(rawValue: savedTheme) ?? .system
        updateDarkMode()
        Log.info("Theme preference loaded: \(currentTheme.rawValue)")
    }
    
    /// Get current background gradient based on theme
    var backgroundGradient: LinearGradient {
        if isDarkMode {
            // Dark mode stays darker but less heavy than before
            return LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.09, blue: 0.12),
                    Color(red: 0.12, green: 0.13, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            // Match Theme.backgroundGradient (pink→purple)
            return LinearGradient(
                colors: [
                    Color(red: 0.478, green: 0.118, blue: 0.361),
                    Color(red: 0.341, green: 0.102, blue: 0.376),
                    Color(red: 0.176, green: 0.039, blue: 0.290)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// Get current card background color based on theme
    var cardBackground: Color {
        if isDarkMode {
            return Color.white.opacity(0.1)
        } else {
            return Color.white.opacity(0.2)
        }
    }
    
    /// Get current primary text color based on theme
    var primaryText: Color {
        if isDarkMode {
            return Color.white
        } else {
            return Color.white
        }
    }
    
    /// Get current secondary text color based on theme
    var secondaryText: Color {
        if isDarkMode {
            return Color.white.opacity(0.7)
        } else {
            return Color.white.opacity(0.8)
        }
    }
    
    /// Get current pill active color based on theme
    var pillActive: Color {
        if isDarkMode {
            return Color.blue.opacity(0.8)
        } else {
            return Color.blue.opacity(0.9)
        }
    }
    
    /// Get current pill inactive color based on theme
    var pillInactive: Color {
        if isDarkMode {
            return Color.white.opacity(0.2)
        } else {
            return Color.white.opacity(0.3)
        }
    }
}
