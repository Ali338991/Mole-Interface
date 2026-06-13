//
//  DashboardView.swift
//  Mole — Dashboard (home).
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var app

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h { case 5..<12: return "Good morning"; case 12..<17: return "Good afternoon"; default: return "Good evening" }
    }

    // Derived live values
    private var freePct: Int {
        app.totalDiskBytes > 0 ? Int(Double(app.freeDiskBytes) / Double(app.totalDiskBytes) * 100) : 0
    }
    private var safeCleanBytes: Int64 {
        app.cleanCategories.filter { $0.safety == .safe }.reduce(0) { $0 + $1.bytes }
    }
    private var staleProjectCount: Int {
        app.devGroups.flatMap(\.projects).filter(\.isStale).count
    }
    private var updateNames: String {
        let names = app.apps.filter(\.hasUpdate).map(\.name)
        return names.isEmpty ? "All apps up to date" : names.prefix(3).joined(separator: " · ")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header
                hero
                kpiRow
                recommended
                glance
            }
            .padding(.horizontal, Spacing.xxl)
            .padding(.vertical, Spacing.xl)
            .frame(maxWidth: 1060, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.nebulaWindowBg)
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting).font(.nebulaTitle).tracking(-0.5)
            Text("Your Mac is in good shape. There are a few easy wins below to free up space and keep things running smoothly.")
                .font(.nebulaBody).foregroundStyle(.nebulaText2).frame(maxWidth: 560, alignment: .leading)
        }
        .padding(.bottom, Spacing.xs)
    }

    // MARK: Hero

    private var hero: some View {
        HStack(alignment: .center, spacing: Spacing.xl) {
            HealthHeroRing(score: app.healthScore)
            VStack(alignment: .leading, spacing: 6) {
                Text("System health is good.").font(.system(size: 15, weight: .semibold))
                Text("No urgent issues. You could reclaim space and run light maintenance to keep performance crisp. Everything Mole removes routes to the Trash and is fully reversible.")
                    .font(.nebulaBody).foregroundStyle(.nebulaText2)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: Spacing.xl) {
                    heroStat(ByteFormat.string(app.reclaimableBytes), "Reclaimable")
                    heroStat("\(app.optimizeTasks.filter(\.isRecommended).count)", "Maintenance tasks")
                    heroStat("\(app.appsWithUpdates)", "App updates")
                }
                .padding(.top, Spacing.sm)
            }
            Spacer(minLength: 0)
        }
        .glassCard(padding: Spacing.xl, translucent: true)
    }

    private func heroStat(_ value: String, _ key: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.system(size: 19, weight: .bold)).nebulaNumeric()
            Text(key).font(.nebulaCaption).foregroundStyle(.nebulaText3)
        }
    }

    // MARK: KPIs

    private var kpiRow: some View {
        HStack(spacing: Spacing.lg) {
            KpiCard(icon: "internaldrive", tint: .nebulaInfo, label: "Free space",
                    value: ByteFormat.string(app.freeDiskBytes), unit: "",
                    foot: "\(freePct)% of \(ByteFormat.string(app.totalDiskBytes)) free", footTint: .nebulaSuccess) {
                app.navigate(to: .diskAnalyzer)
            }
            KpiCard(icon: "sparkles", tint: .nebulaAccent, label: "Reclaimable",
                    value: ByteFormat.string(app.reclaimableBytes), unit: "",
                    foot: "Across \(app.cleanCategories.count) categories", footTint: .nebulaText3) {
                app.navigate(to: .smartClean)
            }
            KpiCard(icon: "arrow.down.circle", tint: .nebulaSuccess, label: "App updates",
                    value: "\(app.appsWithUpdates)", unit: app.appsWithUpdates == 1 ? "app" : "apps",
                    foot: updateNames, footTint: .nebulaText3) {
                app.navigate(to: .applications)
            }
        }
    }

    // MARK: Recommended

    private var recommended: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHead("Recommended", hint: "Tailored to your Mac")
            HStack(spacing: Spacing.lg) {
                RecCard(icon: "sparkles", tint: .nebulaAccent, title: "Free up \(ByteFormat.string(safeCleanBytes))",
                        desc: "Caches, logs, and other safe-to-remove junk.", cta: "Review & clean") {
                    app.navigate(to: .smartClean)
                }
                RecCard(icon: "hammer", tint: .nebulaSuccess, title: "Reclaim \(ByteFormat.string(app.devTotalBytes)) of build artifacts",
                        desc: "\(staleProjectCount) stale projects with node_modules & build caches.", cta: "Open Developer Cleanup") {
                    app.navigate(to: .developerCleanup)
                }
                RecCard(icon: "arrow.down.circle", tint: .nebulaInfo, title: "\(app.appsWithUpdates) app updates available",
                        desc: updateNames, cta: "View applications") {
                    app.navigate(to: .applications)
                }
            }
        }
    }

    // MARK: Storage glance

    private var glance: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .firstTextBaseline) {
                sectionHead("At a glance", hint: "How your \(ByteFormat.string(app.totalDiskBytes)) disk is used")
                Spacer()
                Button("Open Disk Analyzer →") { app.navigate(to: .diskAnalyzer) }
                    .buttonStyle(.plain).font(.system(size: 12, weight: .semibold)).foregroundStyle(.nebulaAccent)
            }
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 6) {
                        Text(ByteFormat.string(app.totalDiskBytes - app.freeDiskBytes))
                            .font(.system(size: 17, weight: .bold)).nebulaNumeric()
                        Text("used").font(.nebulaBody).foregroundStyle(.nebulaText2)
                    }
                    Spacer()
                    Text("\(ByteFormat.string(app.freeDiskBytes)) available")
                        .font(.nebulaBody).foregroundStyle(.nebulaText2).nebulaNumeric()
                }
                StorageBar(segments: app.storageBreakdown, freeBytes: app.freeDiskBytes)
            }
            .glassCard(padding: Spacing.xl)
        }
    }

    private func sectionHead(_ title: String, hint: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
            Text(title).font(.nebulaSection).tracking(-0.2)
            Text(hint).font(.nebulaCaption).foregroundStyle(.nebulaText3)
        }
    }
}

// MARK: - Hero health ring

private struct HealthHeroRing: View {
    var score: Int
    @State private var animated: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle().stroke(Color.nebulaHairlineStrong, lineWidth: 13)
            Circle()
                .trim(from: 0, to: animated / 100)
                .stroke(HealthTint.color(for: score), style: .init(lineWidth: 13, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 2) {
                Text("\(Int(animated))").font(.system(size: 52, weight: .bold)).tracking(-1.5).nebulaNumeric()
                Text("out of 100").font(.system(size: 14, weight: .semibold)).foregroundStyle(.nebulaText3)
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 12))
                    Text(HealthTint.label(for: score)).font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(HealthTint.color(for: score))
                .padding(.top, 5)
            }
        }
        .frame(width: 168, height: 168)
        .onAppear {
            if reduceMotion { animated = Double(score) }
            else { withAnimation(.smooth(duration: 1.1)) { animated = Double(score) } }
        }
        .accessibilityElement()
        .accessibilityLabel("System health \(score) out of 100, \(HealthTint.label(for: score))")
    }
}

// MARK: - KPI card

private struct KpiCard: View {
    var icon: String, tint: Color, label: String, value: String, unit: String
    var foot: String, footTint: Color
    var action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(spacing: 9) {
                    Image(systemName: icon).font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(tint).frame(width: 30, height: 30)
                        .background(tint.opacity(0.14), in: .rect(cornerRadius: 8))
                    Text(label.uppercased()).font(.system(size: 11, weight: .medium)).tracking(0.4)
                        .foregroundStyle(.nebulaText2)
                    Spacer()
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value).font(.system(size: 30, weight: .bold)).tracking(-0.6).nebulaNumeric()
                    Text(unit).font(.system(size: 17, weight: .semibold)).foregroundStyle(.nebulaText2)
                }
                Text(foot).font(.nebulaCaption).foregroundStyle(footTint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(elevation: hovering ? .raised : .flat)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.18), value: hovering)
    }
}

// MARK: - Recommended card

private struct RecCard: View {
    var icon: String, tint: Color, title: String, desc: String, cta: String
    var action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                Image(systemName: icon).font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(tint).frame(width: 36, height: 36)
                    .background(tint.opacity(0.14), in: .rect(cornerRadius: 10))
                Text(title).font(.system(size: 15, weight: .semibold)).tracking(-0.2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(desc).font(.system(size: 12.5)).foregroundStyle(.nebulaText2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 2)
                HStack(spacing: 4) {
                    Text(cta).font(.system(size: 12.5, weight: .semibold))
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(.nebulaAccent)
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .glassCard(elevation: hovering ? .raised : .flat)
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.18), value: hovering)
    }
}

#Preview { DashboardView().environment(AppState()).frame(width: 1100, height: 800) }
