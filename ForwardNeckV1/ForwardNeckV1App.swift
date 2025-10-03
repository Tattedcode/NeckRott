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
        // Toggle this flag while testing so we can jump straight to the home screen without redoing onboarding every time.
        let skipOnboardingForDebug = true
        let defaults = UserDefaults.standard

        if skipOnboardingForDebug {
            defaults.set(true, forKey: "hasCompletedOnboarding")
            Log.debug("ForwardNeckV1App debug launch: skipping onboarding and opening home screen")
        } else {
            defaults.removeObject(forKey: "hasCompletedOnboarding")
            defaults.removeObject(forKey: "hasGrantedScreenTime")
            defaults.removeObject(forKey: "hasGrantedNotifications")
            Log.debug("ForwardNeckV1App debug launch: resetting onboarding flow")
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
