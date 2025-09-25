//
//  ForwardNeckV1App.swift
//  ForwardNeckV1
//
//  Created by Liam Brown on 10/9/2568 BE.
//

import SwiftUI

@main
struct ForwardNeckV1App: App {
    init() {
#if DEBUG
        // Always start at onboarding during development builds for quick testing.
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "hasCompletedOnboarding")
        defaults.removeObject(forKey: "hasGrantedScreenTime")
        defaults.removeObject(forKey: "hasGrantedNotifications")
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
