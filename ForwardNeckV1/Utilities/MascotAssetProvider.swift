//
//  MascotAssetProvider.swift
//  ForwardNeckV1
//
//  Helps us pick the right mascot image name based on the kiddo's choice.
//

import Foundation

/// Tiny helper for storing whichever mascot theme the kid picked.
struct MascotThemeState {
    private static let mascotPrefixKey = "mascotThemePrefix"

    /// Save the prefix ("" = default, "skele" = skeleton, etc.) and brag about it for debugging.
    static func save(prefix: String) {
        UserDefaults.standard.set(prefix, forKey: mascotPrefixKey)
        Log.info("MascotThemeState saved prefix=\(readableName(for: prefix)))")
    }

    /// Peek at the prefix without mutating anything.
    static func currentPrefix() -> String {
        let stored = UserDefaults.standard.string(forKey: mascotPrefixKey) ?? ""
        Log.info("MascotThemeState read prefix=\(readableName(for: stored)))")
        return stored
    }

    private static func readableName(for prefix: String) -> String {
        switch prefix {
        case "":
            return "default"
        case "skele":
            return "skeleton"
        case "girl":
            return "girl"
        case "hero":
            return "superhero"
        default:
            return prefix
        }
    }
}

/// Gives us the correct mascot image name (normal or skeleton) everywhere.
enum MascotAssetProvider {
    /// Figure out what prefix ("" or "skele") we should use right now.
    private static var currentPrefix: String {
        MascotThemeState.currentPrefix()
    }

    /// Turn a base mascot name like "mascot4" into the right themed name.
    static func resolvedMascotName(for baseName: String) -> String {
        let rawPrefix = currentPrefix

        guard !rawPrefix.isEmpty else {
            // No special prefix? Just give the original name back.
            return baseName
        }

        let effectivePrefix: String
        if baseName.hasPrefix("mascot") && rawPrefix == "hero" {
            // The superhero mascot images are still stored with the "super" prefix.
            effectivePrefix = "super"
        } else {
            effectivePrefix = rawPrefix
        }

        if baseName.hasPrefix("mascot") {
            let themedName = "\(effectivePrefix)\(baseName)"
            Log.info("MascotAssetProvider resolved mascot asset \(baseName) -> \(themedName)")
            return themedName
        }

        if baseName.hasPrefix("daily")
            || baseName.hasPrefix("extra")
            || baseName.hasPrefix("fifteen")
            || baseName.hasPrefix("first")
            || baseName.hasPrefix("full")
            || baseName.hasPrefix("ten")
            || baseName.hasPrefix("twenty") {
            let themedName = "\(effectivePrefix)\(baseName)"
            Log.info("MascotAssetProvider resolved achievement asset \(baseName) -> \(themedName)")
            return themedName
        }

        return baseName
    }
}

