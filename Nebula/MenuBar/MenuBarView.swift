//
//  MenuBarView.swift
//  Mole — menu-bar popover: live metrics + quick actions (Raycast/iStat feel).
//

import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) private var app
    @Environment(\.openWindow) private var openWindow

    private let metrics = MockData.liveMetrics()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            header
            Divider()
            miniMetrics
            Divider()
            quickActions
            Divider()
            footer
        }
        .padding(Spacing.md)
        .frame(width: 300)
    }

    private var header: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle().stroke(Color.nebulaHairlineStrong, lineWidth: 4)
                Circle().trim(from: 0, to: Double(app.healthScore)/100)
                    .stroke(HealthTint.color(for: app.healthScore), style: .init(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(app.healthScore)").font(.system(size: 13, weight: .bold)).nebulaNumeric()
            }
            .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 0) {
                Text("Mole").font(.nebulaCardTitle)
                Text(HealthTint.label(for: app.healthScore)).nebulaCaptionStyle()
            }
            Spacer()
        }
    }

    private var miniMetrics: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: Spacing.sm) {
            ForEach(metrics.prefix(4).map { $0 }) { m in
                HStack(spacing: Spacing.sm) {
                    Image(systemName: m.kind.symbol).font(.system(size: 12)).foregroundStyle(m.tint)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(m.kind.rawValue).font(.system(size: 10)).foregroundStyle(.secondary)
                        Text("\(Int(m.current))\(m.kind.unit)").font(.nebulaCallout).nebulaNumeric()
                    }
                    Spacer()
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(spacing: 2) {
            actionRow("sparkles", "Quick Clean") {
                app.navigate(to: .smartClean); app.simulateCleanScan(); focusApp()
            }
            actionRow("wand.and.stars", "Run Maintenance") {
                app.navigate(to: .optimize); focusApp()
            }
            actionRow("macwindow", "Open Mole") { focusApp() }
        }
    }

    private func actionRow(_ symbol: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: symbol).frame(width: 18).foregroundStyle(.tint)
                Text(title).font(.nebulaBody)
                Spacer()
            }
            .padding(.vertical, 5).padding(.horizontal, Spacing.sm).contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        HStack {
            Text("Last scan: 2h ago").nebulaCaptionStyle()
            Spacer()
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain).font(.nebulaCaption).foregroundStyle(.secondary)
        }
    }

    private func focusApp() {
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

#Preview { MenuBarView().environment(AppState()).frame(width: 300) }
