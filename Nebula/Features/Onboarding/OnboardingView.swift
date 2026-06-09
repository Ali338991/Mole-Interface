//
//  OnboardingView.swift
//  Mole — first-run welcome → pillars → grant access → first scan.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var app
    @State private var step = 0

    private let steps = 3

    var body: some View {
        ZStack {
            LinearGradient.nebulaGradient.opacity(0.12).ignoresSafeArea()
            VStack(spacing: Spacing.xl) {
                Spacer()
                content
                Spacer()
                controls
            }
            .padding(Spacing.xxxl)
            .frame(maxWidth: 720)
        }
    }

    @ViewBuilder private var content: some View {
        switch step {
        case 0: welcome
        case 1: pillars
        default: access
        }
    }

    private var welcome: some View {
        VStack(spacing: Spacing.lg) {
            BrandTile(size: 96, corner: 24)
            Text("Welcome to Mole").font(.nebulaHero)
            Text("A calm, powerful way to clean, optimize, and understand your Mac.")
                .font(.nebulaSection).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .transition(.opacity)
    }

    private var pillars: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("What Mole does").font(.nebulaTitle)
            pillar("sparkles", "Reclaim space safely",
                   "Caches, logs, leftovers, and developer junk — everything recoverable via Trash.")
            pillar("chart.pie", "See where it all went",
                   "An interactive treemap and sunburst make your disk legible.")
            pillar("wand.and.stars", "Keep things fast",
                   "One-click maintenance rebuilds indexes and refreshes the system.")
            pillar("checkmark.shield", "Trust by default",
                   "Protected paths are never touched. Nothing is removed without your say-so.")
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    private func pillar(_ symbol: String, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: symbol).font(.system(size: 20)).foregroundStyle(.tint).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.nebulaCardTitle)
                Text(body).nebulaCaptionStyle()
            }
        }
    }

    private var access: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 56)).foregroundStyle(.tint)
            Text("Grant access").font(.nebulaTitle)
            Text("Mole needs permission to scan the folders it cleans. It reads only what it shows you, and never removes anything without confirmation. You can revoke access anytime in System Settings.")
                .font(.nebulaBody).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).frame(maxWidth: 460)
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    private var controls: some View {
        VStack(spacing: Spacing.lg) {
            HStack(spacing: Spacing.sm) {
                ForEach(0..<steps, id: \.self) { i in
                    Capsule()
                        .fill(i == step ? Color.nebulaAccent : Color.nebulaHairlineStrong)
                        .frame(width: i == step ? 22 : 8, height: 8)
                }
            }
            HStack {
                Button("Skip") { finish() }.buttonStyle(.link)
                Spacer()
                Button(step == steps - 1 ? "Run first scan" : "Continue") {
                    if step == steps - 1 { finish() }
                    else { withAnimation(Motion.snappy) { step += 1 } }
                }
                .buttonStyle(.borderedProminent).controlSize(.large).tint(.nebulaAccent)
            }
        }
    }

    private func finish() {
        app.hasCompletedOnboarding = true
        app.navigate(to: .smartClean)
        app.simulateCleanScan()
    }
}

#Preview { OnboardingView().environment(AppState()).frame(width: 900, height: 640) }
