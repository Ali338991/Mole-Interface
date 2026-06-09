//
//  Motion.swift
//  Nebula — Design System / Motion
//
//  Named animation curves so timing is consistent and tunable in one place.
//  All consumers should prefer `Motion.reduced(_:)` or read the
//  `accessibilityReduceMotion` environment so motion can be softened.
//

import SwiftUI

enum Motion {
    /// Navigation/content swaps, selection. 350ms.
    static let snappy = Animation.snappy(duration: 0.35)
    /// Ring fills, value transitions. 450ms.
    static let smooth = Animation.smooth(duration: 0.45)
    /// Success states, FAB appearance. ~500ms spring.
    static let bounce = Animation.spring(response: 0.5, dampingFraction: 0.7)
    /// Ambient scan pulse. 600ms.
    static let gentle = Animation.easeInOut(duration: 0.6)

    /// Returns a reduced-motion-safe variant: when the user prefers
    /// reduced motion, fall back to a quick linear cross-fade.
    static func adapt(_ animation: Animation, reduceMotion: Bool) -> Animation {
        reduceMotion ? .linear(duration: 0.15) : animation
    }
}

extension View {
    /// Applies an animation that automatically softens under Reduce Motion.
    func nebulaAnimation<V: Equatable>(
        _ animation: Animation,
        value: V,
        reduceMotion: Bool
    ) -> some View {
        self.animation(Motion.adapt(animation, reduceMotion: reduceMotion), value: value)
    }
}
