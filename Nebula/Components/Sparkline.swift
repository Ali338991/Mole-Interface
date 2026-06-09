//
//  Sparkline.swift
//  Nebula — Components / inline trend line
//

import SwiftUI
import Charts

private struct SparkPoint: Identifiable {
    let id = UUID()
    let x: Int
    let y: Double
}

/// Tiny inline trend used inside MetricCards.
struct Sparkline: View {
    var values: [Double]
    var tint: Color = .nebulaAccent

    private var points: [SparkPoint] {
        values.enumerated().map { SparkPoint(x: $0.offset, y: $0.element) }
    }

    var body: some View {
        Chart(points) { point in
            AreaMark(x: .value("i", point.x), y: .value("v", point.y))
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(colors: [tint.opacity(0.35), tint.opacity(0.02)],
                                   startPoint: .top, endPoint: .bottom)
                )
            LineMark(x: .value("i", point.x), y: .value("v", point.y))
                .interpolationMethod(.monotone)
                .foregroundStyle(tint)
                .lineStyle(.init(lineWidth: 1.5))
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .accessibilityHidden(true)
    }
}

#Preview("Sparkline") {
    Sparkline(values: (0..<24).map { _ in Double.random(in: 10...90) })
        .frame(width: 160, height: 44)
        .padding()
}
