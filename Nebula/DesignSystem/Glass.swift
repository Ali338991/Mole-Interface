//
//  Glass.swift
//  Mole — Design System / Surfaces
//
//  Cards are solid surfaces (var(--surface)) with a hairline border and a soft
//  resting shadow, matching the Mole design. A translucent variant and a
//  floating surface (for overlays) are also provided.
//

import SwiftUI

private struct GlassCardModifier: ViewModifier {
    var radius: CGFloat = Radius.card
    var padding: CGFloat = Spacing.lg
    var elevation: Elevation = .flat
    var translucent: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                if translucent {
                    RoundedRectangle(cornerRadius: radius).fill(.regularMaterial)
                } else {
                    RoundedRectangle(cornerRadius: radius).fill(Color.nebulaSurface)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color.nebulaHairline, lineWidth: 0.5)
            )
            .compositingGroup()
            .modifier(CardShadow(elevation: elevation))
    }
}

/// Soft, layered shadow per the design's --card-shadow / --card-shadow-hover.
private struct CardShadow: ViewModifier {
    let elevation: Elevation
    func body(content: Content) -> some View {
        switch elevation {
        case .flat:
            content
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
        case .raised:
            content
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 18)
        case .floating:
            content
                .shadow(color: .black.opacity(0.18), radius: 30, x: 0, y: 8)
        }
    }
}

extension View {
    /// The standard Mole card surface.
    func glassCard(
        radius: CGFloat = Radius.card,
        padding: CGFloat = Spacing.lg,
        elevation: Elevation = .flat,
        translucent: Bool = false
    ) -> some View {
        modifier(GlassCardModifier(radius: radius, padding: padding,
                                   elevation: elevation, translucent: translucent))
    }

    /// Floating surface for palette / popovers.
    func floatingSurface(radius: CGFloat = Radius.card) -> some View {
        self
            .background(.ultraThinMaterial, in: .rect(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(Color.nebulaHairlineStrong, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.28), radius: 40, x: 0, y: 16)
    }
}
