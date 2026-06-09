//
//  Spacing.swift
//  Nebula — Design System / Spacing, radius, elevation
//

import SwiftUI

/// 8-pt soft grid spacing scale.
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 12
    static let lg:  CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
}

enum Radius {
    static let sm:      CGFloat = 6
    static let md:      CGFloat = 8
    static let control: CGFloat = 9
    static let lg:      CGFloat = 12
    static let card:    CGFloat = 16
    static let hero:    CGFloat = 24
    static let capsule: CGFloat = 999
}

/// Three-level elevation system.
enum Elevation {
    case flat, raised, floating
}

private struct NebulaShadow: ViewModifier {
    let level: Elevation
    func body(content: Content) -> some View {
        switch level {
        case .flat:
            content
        case .raised:
            content.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        case .floating:
            content.shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 8)
        }
    }
}

extension View {
    func nebulaShadow(_ level: Elevation) -> some View {
        modifier(NebulaShadow(level: level))
    }

    /// Standard screen content insets.
    func screenPadding() -> some View {
        self.padding(.horizontal, Spacing.xl).padding(.top, Spacing.xl)
    }
}
