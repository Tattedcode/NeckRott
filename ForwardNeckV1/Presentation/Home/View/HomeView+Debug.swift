//
//  HomeView+Debug.swift
//  ForwardNeckV1
//
//  Debug helpers for outlining layout regions.
//

import SwiftUI

let debugOutlines: Bool = false

extension View {
    @ViewBuilder
    func debugOutline(_ color: Color, enabled: Bool) -> some View {
        if enabled {
            overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 2)
            )
        } else {
            self
        }
    }
}
