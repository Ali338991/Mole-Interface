//
//  MetricCard.swift
//  Nebula — Components / KPI card
//

import SwiftUI

struct MetricCard: View {
    var title: String
    var value: String
    var systemImage: String
    var tint: Color = .nebulaAccent
    var caption: String? = nil
    var trend: [Double]? = nil
    var delta: String? = nil
    var deltaIsPositive: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 26, height: 26)
                    .background(tint.opacity(0.12), in: .rect(cornerRadius: 8))
                Text(title).font(.nebulaCaption).foregroundStyle(.secondary)
                Spacer()
                if let delta {
                    Pill(text: delta,
                         tint: deltaIsPositive ? .nebulaSuccess : .nebulaDanger,
                         style: .tinted)
                }
            }

            Text(value)
                .font(.nebulaSection)
                .nebulaNumeric()
                .contentTransition(.numericText())

            if let trend {
                Sparkline(values: trend, tint: tint)
                    .frame(height: 34)
            }
            if let caption {
                Text(caption).nebulaCaptionStyle()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

#Preview("MetricCard") {
    HStack {
        MetricCard(title: "CPU", value: "34%", systemImage: "cpu", tint: .nebulaAccent,
                   trend: (0..<20).map { _ in .random(in: 10...80) }, delta: "+4%", deltaIsPositive: false)
        MetricCard(title: "Free Disk", value: "138 GB", systemImage: "internaldrive",
                   tint: .nebulaSuccess, caption: "of 494 GB")
    }
    .frame(width: 460).padding()
}
