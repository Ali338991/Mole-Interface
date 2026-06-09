//
//  Rings.swift
//  Nebula — Components / Progress & Health rings
//

import SwiftUI

/// Generic progress ring (scan, per-category, optimize tasks).
struct ProgressRing: View {
    var progress: Double            // 0...1
    var lineWidth: CGFloat = 8
    var tint: Color = .nebulaAccent
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.nebulaHairlineStrong, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.0001, min(progress, 1)))
                .stroke(tint, style: .init(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .nebulaAnimation(Motion.smooth, value: progress, reduceMotion: reduceMotion)
        }
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

/// The dashboard hero: an animated 0–100 health ring with the brand gradient.
struct HealthScoreRing: View {
    var score: Int
    var size: CGFloat = 180
    @State private var animatedScore: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var fraction: Double { Double(animatedScore) / 100 }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.nebulaHairlineStrong, lineWidth: 14)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(
                    LinearGradient(colors: [HealthTint.color(for: score),
                                            HealthTint.color(for: score).opacity(0.7)],
                                   startPoint: .top, endPoint: .bottom),
                    style: .init(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: Spacing.xxs) {
                Text("\(Int(animatedScore))")
                    .font(.system(size: size * 0.3, weight: .bold))
                    .nebulaNumeric()
                    .contentTransition(.numericText())
                Text(HealthTint.label(for: score))
                    .font(.nebulaCaption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .onAppear { animate() }
        .onChange(of: score) { _, _ in animate() }
        .accessibilityElement()
        .accessibilityLabel("System health")
        .accessibilityValue("\(score) out of 100, \(HealthTint.label(for: score))")
    }

    private func animate() {
        if reduceMotion { animatedScore = Double(score); return }
        withAnimation(Motion.smooth) { animatedScore = Double(score) }
    }
}

#Preview("Rings") {
    HStack(spacing: 40) {
        HealthScoreRing(score: 88)
        ProgressRing(progress: 0.66).frame(width: 120, height: 120)
    }
    .padding(40)
}
