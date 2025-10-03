import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "BGColorOne" asset catalog color resource.
    static let bgColorOne = DeveloperToolsSupport.ColorResource(name: "BGColorOne", bundle: resourceBundle)

    /// The "BGColorTwo" asset catalog color resource.
    static let bgColorTwo = DeveloperToolsSupport.ColorResource(name: "BGColorTwo", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "dailystreakstarted" asset catalog image resource.
    static let dailystreakstarted = DeveloperToolsSupport.ImageResource(name: "dailystreakstarted", bundle: resourceBundle)

    /// The "extraexercises" asset catalog image resource.
    static let extraexercises = DeveloperToolsSupport.ImageResource(name: "extraexercises", bundle: resourceBundle)

    /// The "fifteendaystreak" asset catalog image resource.
    static let fifteendaystreak = DeveloperToolsSupport.ImageResource(name: "fifteendaystreak", bundle: resourceBundle)

    /// The "firstexcersise" asset catalog image resource.
    static let firstexcersise = DeveloperToolsSupport.ImageResource(name: "firstexcersise", bundle: resourceBundle)

    /// The "fullmonthstreak" asset catalog image resource.
    static let fullmonthstreak = DeveloperToolsSupport.ImageResource(name: "fullmonthstreak", bundle: resourceBundle)

    /// The "girldailystreakstarted" asset catalog image resource.
    static let girldailystreakstarted = DeveloperToolsSupport.ImageResource(name: "girldailystreakstarted", bundle: resourceBundle)

    /// The "girlextraexercises" asset catalog image resource.
    static let girlextraexercises = DeveloperToolsSupport.ImageResource(name: "girlextraexercises", bundle: resourceBundle)

    /// The "girlfifteendaystreak" asset catalog image resource.
    static let girlfifteendaystreak = DeveloperToolsSupport.ImageResource(name: "girlfifteendaystreak", bundle: resourceBundle)

    /// The "girlfirstexcersise" asset catalog image resource.
    static let girlfirstexcersise = DeveloperToolsSupport.ImageResource(name: "girlfirstexcersise", bundle: resourceBundle)

    /// The "girlfullmonthstreak" asset catalog image resource.
    static let girlfullmonthstreak = DeveloperToolsSupport.ImageResource(name: "girlfullmonthstreak", bundle: resourceBundle)

    /// The "girlmascot1" asset catalog image resource.
    static let girlmascot1 = DeveloperToolsSupport.ImageResource(name: "girlmascot1", bundle: resourceBundle)

    /// The "girlmascot2" asset catalog image resource.
    static let girlmascot2 = DeveloperToolsSupport.ImageResource(name: "girlmascot2", bundle: resourceBundle)

    /// The "girlmascot3" asset catalog image resource.
    static let girlmascot3 = DeveloperToolsSupport.ImageResource(name: "girlmascot3", bundle: resourceBundle)

    /// The "girlmascot4" asset catalog image resource.
    static let girlmascot4 = DeveloperToolsSupport.ImageResource(name: "girlmascot4", bundle: resourceBundle)

    /// The "girltencompleted" asset catalog image resource.
    static let girltencompleted = DeveloperToolsSupport.ImageResource(name: "girltencompleted", bundle: resourceBundle)

    /// The "girltwentycompleted" asset catalog image resource.
    static let girltwentycompleted = DeveloperToolsSupport.ImageResource(name: "girltwentycompleted", bundle: resourceBundle)

    /// The "herodailystreakstarted" asset catalog image resource.
    static let herodailystreakstarted = DeveloperToolsSupport.ImageResource(name: "herodailystreakstarted", bundle: resourceBundle)

    /// The "heroextraexercises" asset catalog image resource.
    static let heroextraexercises = DeveloperToolsSupport.ImageResource(name: "heroextraexercises", bundle: resourceBundle)

    /// The "herofifteendaystreak" asset catalog image resource.
    static let herofifteendaystreak = DeveloperToolsSupport.ImageResource(name: "herofifteendaystreak", bundle: resourceBundle)

    /// The "herofirstexcersise" asset catalog image resource.
    static let herofirstexcersise = DeveloperToolsSupport.ImageResource(name: "herofirstexcersise", bundle: resourceBundle)

    /// The "herotencompleted" asset catalog image resource.
    static let herotencompleted = DeveloperToolsSupport.ImageResource(name: "herotencompleted", bundle: resourceBundle)

    /// The "herotwentycompleted" asset catalog image resource.
    static let herotwentycompleted = DeveloperToolsSupport.ImageResource(name: "herotwentycompleted", bundle: resourceBundle)

    /// The "mascot1" asset catalog image resource.
    static let mascot1 = DeveloperToolsSupport.ImageResource(name: "mascot1", bundle: resourceBundle)

    /// The "mascot2" asset catalog image resource.
    static let mascot2 = DeveloperToolsSupport.ImageResource(name: "mascot2", bundle: resourceBundle)

    /// The "mascot3" asset catalog image resource.
    static let mascot3 = DeveloperToolsSupport.ImageResource(name: "mascot3", bundle: resourceBundle)

    /// The "mascot4" asset catalog image resource.
    static let mascot4 = DeveloperToolsSupport.ImageResource(name: "mascot4", bundle: resourceBundle)

    /// The "skeledailystreakstarted" asset catalog image resource.
    static let skeledailystreakstarted = DeveloperToolsSupport.ImageResource(name: "skeledailystreakstarted", bundle: resourceBundle)

    /// The "skeleextraexercises" asset catalog image resource.
    static let skeleextraexercises = DeveloperToolsSupport.ImageResource(name: "skeleextraexercises", bundle: resourceBundle)

    /// The "skelefifteendaystreak" asset catalog image resource.
    static let skelefifteendaystreak = DeveloperToolsSupport.ImageResource(name: "skelefifteendaystreak", bundle: resourceBundle)

    /// The "skelefirstexcersise" asset catalog image resource.
    static let skelefirstexcersise = DeveloperToolsSupport.ImageResource(name: "skelefirstexcersise", bundle: resourceBundle)

    /// The "skelefullmonthstreak" asset catalog image resource.
    static let skelefullmonthstreak = DeveloperToolsSupport.ImageResource(name: "skelefullmonthstreak", bundle: resourceBundle)

    /// The "skelemascot1" asset catalog image resource.
    static let skelemascot1 = DeveloperToolsSupport.ImageResource(name: "skelemascot1", bundle: resourceBundle)

    /// The "skelemascot2" asset catalog image resource.
    static let skelemascot2 = DeveloperToolsSupport.ImageResource(name: "skelemascot2", bundle: resourceBundle)

    /// The "skelemascot3" asset catalog image resource.
    static let skelemascot3 = DeveloperToolsSupport.ImageResource(name: "skelemascot3", bundle: resourceBundle)

    /// The "skelemascot4" asset catalog image resource.
    static let skelemascot4 = DeveloperToolsSupport.ImageResource(name: "skelemascot4", bundle: resourceBundle)

    /// The "skeletwentycompleted" asset catalog image resource.
    static let skeletwentycompleted = DeveloperToolsSupport.ImageResource(name: "skeletwentycompleted", bundle: resourceBundle)

    /// The "supermascot1" asset catalog image resource.
    static let supermascot1 = DeveloperToolsSupport.ImageResource(name: "supermascot1", bundle: resourceBundle)

    /// The "supermascot2" asset catalog image resource.
    static let supermascot2 = DeveloperToolsSupport.ImageResource(name: "supermascot2", bundle: resourceBundle)

    /// The "supermascot3" asset catalog image resource.
    static let supermascot3 = DeveloperToolsSupport.ImageResource(name: "supermascot3", bundle: resourceBundle)

    /// The "supermascot4" asset catalog image resource.
    static let supermascot4 = DeveloperToolsSupport.ImageResource(name: "supermascot4", bundle: resourceBundle)

    /// The "tencompleted" asset catalog image resource.
    static let tencompleted = DeveloperToolsSupport.ImageResource(name: "tencompleted", bundle: resourceBundle)

    /// The "twentycompleted" asset catalog image resource.
    static let twentycompleted = DeveloperToolsSupport.ImageResource(name: "twentycompleted", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "BGColorOne" asset catalog color.
    static var bgColorOne: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bgColorOne)
#else
        .init()
#endif
    }

    /// The "BGColorTwo" asset catalog color.
    static var bgColorTwo: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .bgColorTwo)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "BGColorOne" asset catalog color.
    static var bgColorOne: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .bgColorOne)
#else
        .init()
#endif
    }

    /// The "BGColorTwo" asset catalog color.
    static var bgColorTwo: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .bgColorTwo)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "BGColorOne" asset catalog color.
    static var bgColorOne: SwiftUI.Color { .init(.bgColorOne) }

    /// The "BGColorTwo" asset catalog color.
    static var bgColorTwo: SwiftUI.Color { .init(.bgColorTwo) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "BGColorOne" asset catalog color.
    static var bgColorOne: SwiftUI.Color { .init(.bgColorOne) }

    /// The "BGColorTwo" asset catalog color.
    static var bgColorTwo: SwiftUI.Color { .init(.bgColorTwo) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "dailystreakstarted" asset catalog image.
    static var dailystreakstarted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dailystreakstarted)
#else
        .init()
#endif
    }

    /// The "extraexercises" asset catalog image.
    static var extraexercises: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .extraexercises)
#else
        .init()
#endif
    }

    /// The "fifteendaystreak" asset catalog image.
    static var fifteendaystreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fifteendaystreak)
#else
        .init()
#endif
    }

    /// The "firstexcersise" asset catalog image.
    static var firstexcersise: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .firstexcersise)
#else
        .init()
#endif
    }

    /// The "fullmonthstreak" asset catalog image.
    static var fullmonthstreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .fullmonthstreak)
#else
        .init()
#endif
    }

    /// The "girldailystreakstarted" asset catalog image.
    static var girldailystreakstarted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girldailystreakstarted)
#else
        .init()
#endif
    }

    /// The "girlextraexercises" asset catalog image.
    static var girlextraexercises: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlextraexercises)
#else
        .init()
#endif
    }

    /// The "girlfifteendaystreak" asset catalog image.
    static var girlfifteendaystreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlfifteendaystreak)
#else
        .init()
#endif
    }

    /// The "girlfirstexcersise" asset catalog image.
    static var girlfirstexcersise: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlfirstexcersise)
#else
        .init()
#endif
    }

    /// The "girlfullmonthstreak" asset catalog image.
    static var girlfullmonthstreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlfullmonthstreak)
#else
        .init()
#endif
    }

    /// The "girlmascot1" asset catalog image.
    static var girlmascot1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlmascot1)
#else
        .init()
#endif
    }

    /// The "girlmascot2" asset catalog image.
    static var girlmascot2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlmascot2)
#else
        .init()
#endif
    }

    /// The "girlmascot3" asset catalog image.
    static var girlmascot3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlmascot3)
#else
        .init()
#endif
    }

    /// The "girlmascot4" asset catalog image.
    static var girlmascot4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girlmascot4)
#else
        .init()
#endif
    }

    /// The "girltencompleted" asset catalog image.
    static var girltencompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girltencompleted)
#else
        .init()
#endif
    }

    /// The "girltwentycompleted" asset catalog image.
    static var girltwentycompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .girltwentycompleted)
#else
        .init()
#endif
    }

    /// The "herodailystreakstarted" asset catalog image.
    static var herodailystreakstarted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .herodailystreakstarted)
#else
        .init()
#endif
    }

    /// The "heroextraexercises" asset catalog image.
    static var heroextraexercises: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .heroextraexercises)
#else
        .init()
#endif
    }

    /// The "herofifteendaystreak" asset catalog image.
    static var herofifteendaystreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .herofifteendaystreak)
#else
        .init()
#endif
    }

    /// The "herofirstexcersise" asset catalog image.
    static var herofirstexcersise: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .herofirstexcersise)
#else
        .init()
#endif
    }

    /// The "herotencompleted" asset catalog image.
    static var herotencompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .herotencompleted)
#else
        .init()
#endif
    }

    /// The "herotwentycompleted" asset catalog image.
    static var herotwentycompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .herotwentycompleted)
#else
        .init()
#endif
    }

    /// The "mascot1" asset catalog image.
    static var mascot1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mascot1)
#else
        .init()
#endif
    }

    /// The "mascot2" asset catalog image.
    static var mascot2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mascot2)
#else
        .init()
#endif
    }

    /// The "mascot3" asset catalog image.
    static var mascot3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mascot3)
#else
        .init()
#endif
    }

    /// The "mascot4" asset catalog image.
    static var mascot4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mascot4)
#else
        .init()
#endif
    }

    /// The "skeledailystreakstarted" asset catalog image.
    static var skeledailystreakstarted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skeledailystreakstarted)
#else
        .init()
#endif
    }

    /// The "skeleextraexercises" asset catalog image.
    static var skeleextraexercises: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skeleextraexercises)
#else
        .init()
#endif
    }

    /// The "skelefifteendaystreak" asset catalog image.
    static var skelefifteendaystreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelefifteendaystreak)
#else
        .init()
#endif
    }

    /// The "skelefirstexcersise" asset catalog image.
    static var skelefirstexcersise: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelefirstexcersise)
#else
        .init()
#endif
    }

    /// The "skelefullmonthstreak" asset catalog image.
    static var skelefullmonthstreak: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelefullmonthstreak)
#else
        .init()
#endif
    }

    /// The "skelemascot1" asset catalog image.
    static var skelemascot1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelemascot1)
#else
        .init()
#endif
    }

    /// The "skelemascot2" asset catalog image.
    static var skelemascot2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelemascot2)
#else
        .init()
#endif
    }

    /// The "skelemascot3" asset catalog image.
    static var skelemascot3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelemascot3)
#else
        .init()
#endif
    }

    /// The "skelemascot4" asset catalog image.
    static var skelemascot4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skelemascot4)
#else
        .init()
#endif
    }

    /// The "skeletwentycompleted" asset catalog image.
    static var skeletwentycompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .skeletwentycompleted)
#else
        .init()
#endif
    }

    /// The "supermascot1" asset catalog image.
    static var supermascot1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .supermascot1)
#else
        .init()
#endif
    }

    /// The "supermascot2" asset catalog image.
    static var supermascot2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .supermascot2)
#else
        .init()
#endif
    }

    /// The "supermascot3" asset catalog image.
    static var supermascot3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .supermascot3)
#else
        .init()
#endif
    }

    /// The "supermascot4" asset catalog image.
    static var supermascot4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .supermascot4)
#else
        .init()
#endif
    }

    /// The "tencompleted" asset catalog image.
    static var tencompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .tencompleted)
#else
        .init()
#endif
    }

    /// The "twentycompleted" asset catalog image.
    static var twentycompleted: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .twentycompleted)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "dailystreakstarted" asset catalog image.
    static var dailystreakstarted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .dailystreakstarted)
#else
        .init()
#endif
    }

    /// The "extraexercises" asset catalog image.
    static var extraexercises: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .extraexercises)
#else
        .init()
#endif
    }

    /// The "fifteendaystreak" asset catalog image.
    static var fifteendaystreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fifteendaystreak)
#else
        .init()
#endif
    }

    /// The "firstexcersise" asset catalog image.
    static var firstexcersise: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .firstexcersise)
#else
        .init()
#endif
    }

    /// The "fullmonthstreak" asset catalog image.
    static var fullmonthstreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .fullmonthstreak)
#else
        .init()
#endif
    }

    /// The "girldailystreakstarted" asset catalog image.
    static var girldailystreakstarted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girldailystreakstarted)
#else
        .init()
#endif
    }

    /// The "girlextraexercises" asset catalog image.
    static var girlextraexercises: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlextraexercises)
#else
        .init()
#endif
    }

    /// The "girlfifteendaystreak" asset catalog image.
    static var girlfifteendaystreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlfifteendaystreak)
#else
        .init()
#endif
    }

    /// The "girlfirstexcersise" asset catalog image.
    static var girlfirstexcersise: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlfirstexcersise)
#else
        .init()
#endif
    }

    /// The "girlfullmonthstreak" asset catalog image.
    static var girlfullmonthstreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlfullmonthstreak)
#else
        .init()
#endif
    }

    /// The "girlmascot1" asset catalog image.
    static var girlmascot1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlmascot1)
#else
        .init()
#endif
    }

    /// The "girlmascot2" asset catalog image.
    static var girlmascot2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlmascot2)
#else
        .init()
#endif
    }

    /// The "girlmascot3" asset catalog image.
    static var girlmascot3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlmascot3)
#else
        .init()
#endif
    }

    /// The "girlmascot4" asset catalog image.
    static var girlmascot4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girlmascot4)
#else
        .init()
#endif
    }

    /// The "girltencompleted" asset catalog image.
    static var girltencompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girltencompleted)
#else
        .init()
#endif
    }

    /// The "girltwentycompleted" asset catalog image.
    static var girltwentycompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .girltwentycompleted)
#else
        .init()
#endif
    }

    /// The "herodailystreakstarted" asset catalog image.
    static var herodailystreakstarted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .herodailystreakstarted)
#else
        .init()
#endif
    }

    /// The "heroextraexercises" asset catalog image.
    static var heroextraexercises: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .heroextraexercises)
#else
        .init()
#endif
    }

    /// The "herofifteendaystreak" asset catalog image.
    static var herofifteendaystreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .herofifteendaystreak)
#else
        .init()
#endif
    }

    /// The "herofirstexcersise" asset catalog image.
    static var herofirstexcersise: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .herofirstexcersise)
#else
        .init()
#endif
    }

    /// The "herotencompleted" asset catalog image.
    static var herotencompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .herotencompleted)
#else
        .init()
#endif
    }

    /// The "herotwentycompleted" asset catalog image.
    static var herotwentycompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .herotwentycompleted)
#else
        .init()
#endif
    }

    /// The "mascot1" asset catalog image.
    static var mascot1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mascot1)
#else
        .init()
#endif
    }

    /// The "mascot2" asset catalog image.
    static var mascot2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mascot2)
#else
        .init()
#endif
    }

    /// The "mascot3" asset catalog image.
    static var mascot3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mascot3)
#else
        .init()
#endif
    }

    /// The "mascot4" asset catalog image.
    static var mascot4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mascot4)
#else
        .init()
#endif
    }

    /// The "skeledailystreakstarted" asset catalog image.
    static var skeledailystreakstarted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skeledailystreakstarted)
#else
        .init()
#endif
    }

    /// The "skeleextraexercises" asset catalog image.
    static var skeleextraexercises: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skeleextraexercises)
#else
        .init()
#endif
    }

    /// The "skelefifteendaystreak" asset catalog image.
    static var skelefifteendaystreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelefifteendaystreak)
#else
        .init()
#endif
    }

    /// The "skelefirstexcersise" asset catalog image.
    static var skelefirstexcersise: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelefirstexcersise)
#else
        .init()
#endif
    }

    /// The "skelefullmonthstreak" asset catalog image.
    static var skelefullmonthstreak: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelefullmonthstreak)
#else
        .init()
#endif
    }

    /// The "skelemascot1" asset catalog image.
    static var skelemascot1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelemascot1)
#else
        .init()
#endif
    }

    /// The "skelemascot2" asset catalog image.
    static var skelemascot2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelemascot2)
#else
        .init()
#endif
    }

    /// The "skelemascot3" asset catalog image.
    static var skelemascot3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelemascot3)
#else
        .init()
#endif
    }

    /// The "skelemascot4" asset catalog image.
    static var skelemascot4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skelemascot4)
#else
        .init()
#endif
    }

    /// The "skeletwentycompleted" asset catalog image.
    static var skeletwentycompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .skeletwentycompleted)
#else
        .init()
#endif
    }

    /// The "supermascot1" asset catalog image.
    static var supermascot1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .supermascot1)
#else
        .init()
#endif
    }

    /// The "supermascot2" asset catalog image.
    static var supermascot2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .supermascot2)
#else
        .init()
#endif
    }

    /// The "supermascot3" asset catalog image.
    static var supermascot3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .supermascot3)
#else
        .init()
#endif
    }

    /// The "supermascot4" asset catalog image.
    static var supermascot4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .supermascot4)
#else
        .init()
#endif
    }

    /// The "tencompleted" asset catalog image.
    static var tencompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .tencompleted)
#else
        .init()
#endif
    }

    /// The "twentycompleted" asset catalog image.
    static var twentycompleted: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .twentycompleted)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

