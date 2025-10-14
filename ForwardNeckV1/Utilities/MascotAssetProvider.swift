//
//  MascotAssetProvider.swift
//  ForwardNeckV1
//
//  Simple helper that returns mascot names. We only use one mascot set now.
//

import Foundation

/// Simple provider that returns mascot names as-is. We only use mascot1-4 now.
enum MascotAssetProvider {
    /// Return the mascot name directly without any theme modifications
    static func resolvedMascotName(for baseName: String) -> String {
        Log.info("MascotAssetProvider using mascot: \(baseName)")
        return baseName
    }
}

