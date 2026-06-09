//
//  Typography.swift
//  Nebula — Design System / Type
//
//  Uses system (SF Pro) fonts so Dynamic Type, optical sizing, and
//  appearance all work. Numeric displays use monospaced digits to avoid
//  jitter during live updates and counting animations.
//

import SwiftUI

// Mole type ramp.
extension Font {
    static let nebulaHero      = Font.system(size: 52, weight: .bold,     design: .default) // big "space freed" number
    static let nebulaTitle     = Font.system(size: 28, weight: .bold,     design: .default)
    static let nebulaSection   = Font.system(size: 19, weight: .semibold, design: .default)
    static let nebulaCardTitle = Font.system(size: 14, weight: .semibold, design: .default)
    static let nebulaBody      = Font.system(size: 13, weight: .regular,  design: .default)
    static let nebulaCallout   = Font.system(size: 13, weight: .medium,   design: .default)
    static let nebulaCaption   = Font.system(size: 11, weight: .medium,   design: .default)
    static let nebulaMono      = Font.system(size: 12, weight: .regular,  design: .monospaced)
}

extension View {
    /// Caption styling: small, secondary, tight.
    func nebulaCaptionStyle() -> some View {
        self.font(.nebulaCaption).foregroundStyle(.secondary)
    }

    /// For any number that should never reflow as it animates/updates.
    func nebulaNumeric() -> some View {
        self.monospacedDigit()
    }
}
