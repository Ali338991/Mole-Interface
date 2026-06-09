//
//  Sidebar.swift
//  Mole — custom translucent sidebar (brand mark, grouped nav, health footer).
//  Button-driven so navigation is reliable.
//

import SwiftUI

struct Sidebar: View {
    @Environment(AppState.self) private var app

    var body: some View {
        VStack(spacing: 0) {
            brandRow
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    navGroup(.overview)
                    navGroup(.reclaim)
                    navGroup(.system)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.lg)
            }
            Divider()
            footer
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.ultraThinMaterial)
        .navigationSplitViewColumnWidth(min: 218, ideal: 248, max: 300)
    }

    // MARK: Brand

    private var brandRow: some View {
        HStack(spacing: 10) {
            BrandTile(size: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text("Mole").font(.system(size: 16, weight: .bold))
                Text("System Care").font(.nebulaCaption).foregroundStyle(.nebulaText3)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.md)
    }

    // MARK: Nav

    @ViewBuilder
    private func navGroup(_ section: Destination.Section) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(section.rawValue.uppercased())
                .font(.system(size: 10.5, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(.nebulaText3)
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
            ForEach(Destination.items(in: section)) { dest in
                NavRow(dest: dest,
                       isActive: app.destination == dest,
                       badge: dest == .applications ? app.appsWithUpdates : 0) {
                    app.navigate(to: dest)
                }
            }
        }
    }

    // MARK: Footer

    private var footer: some View {
        HStack(spacing: 9) {
            ZStack {
                Circle().stroke(Color.nebulaHairlineStrong, lineWidth: 3.5)
                Circle()
                    .trim(from: 0, to: Double(app.healthScore) / 100)
                    .stroke(HealthTint.color(for: app.healthScore),
                            style: .init(lineWidth: 3.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 26, height: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text("Health \(app.healthScore)").font(.system(size: 14, weight: .bold)).nebulaNumeric()
                Text(HealthTint.label(for: app.healthScore)).font(.nebulaCaption).foregroundStyle(.nebulaText2)
            }
            Spacer()
            SettingsLink {
                Image(systemName: "gearshape").font(.system(size: 14))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.nebulaText2)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }
}

/// A single sidebar navigation row with active + hover styling.
private struct NavRow: View {
    let dest: Destination
    let isActive: Bool
    let badge: Int
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: dest.symbol)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 18)
                    .foregroundStyle(isActive ? Color.nebulaAccent : Color.nebulaText2)
                Text(dest.title)
                    .font(.system(size: 13.5, weight: isActive ? .semibold : .medium))
                    .foregroundStyle(isActive ? Color.nebulaAccent : Color.nebulaText)
                Spacer()
                if badge > 0 {
                    Text("\(badge)")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.nebulaAccent, in: .capsule)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isActive ? Color.nebulaAccent.opacity(0.14)
                                   : (hovering ? Color.nebulaAccent.opacity(0.06) : .clear))
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
