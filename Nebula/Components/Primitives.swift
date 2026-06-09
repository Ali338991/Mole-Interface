//
//  Primitives.swift
//  Nebula — Components / SectionHeader, EmptyState, ScanButton, FAB
//

import SwiftUI

// MARK: - Section header

struct SectionHeader<Trailing: View>: View {
    var title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title).font(.nebulaSection)
                if let subtitle { Text(subtitle).nebulaCaptionStyle() }
            }
            Spacer()
            trailing
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle) { EmptyView() }
    }
}

// MARK: - Empty state

struct EmptyStateView: View {
    var symbol: String
    var title: String
    var message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.tertiary)
                .symbolRenderingMode(.hierarchical)
            Text(title).font(.nebulaSection)
            Text(message)
                .font(.nebulaBody).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.top, Spacing.xs)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}

// MARK: - Scan / primary CTA button

struct ScanButton: View {
    enum Phase { case idle, scanning, done }
    var phase: Phase
    var idleTitle: String = "Scan"
    var action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                icon
                Text(label).font(.nebulaCallout)
            }
            .padding(.horizontal, Spacing.lg)
            .frame(height: 38)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(phase == .scanning)
        .tint(.nebulaAccent)
    }

    @ViewBuilder private var icon: some View {
        switch phase {
        case .idle:
            Image(systemName: "sparkle.magnifyingglass")
        case .scanning:
            Image(systemName: "circle.dotted")
                .symbolEffect(.rotate, options: reduceMotion ? .nonRepeating : .repeating)
        case .done:
            Image(systemName: "checkmark.circle.fill")
        }
    }

    private var label: String {
        switch phase {
        case .idle: idleTitle
        case .scanning: "Scanning…"
        case .done: "Done"
        }
    }
}

// MARK: - Floating action button

struct FloatingActionButton: View {
    var label: String
    var systemImage: String
    var tint: Color = .nebulaAccent
    var action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: systemImage).font(.system(size: 14, weight: .bold))
                Text(label).font(.nebulaCallout)
            }
            .padding(.horizontal, Spacing.xl)
            .frame(height: 46)
            .foregroundStyle(.white)
            .background(LinearGradient.nebulaGradient, in: .capsule)
            .nebulaShadow(.floating)
        }
        .buttonStyle(.plain)
        .scaleEffect(appeared ? 1 : 0.9)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(Motion.adapt(Motion.bounce, reduceMotion: reduceMotion)) { appeared = true }
        }
    }
}

#Preview("Primitives") {
    VStack(spacing: 24) {
        SectionHeader(title: "Recommended", subtitle: "3 actions") {
            Button("See all") {}.buttonStyle(.link)
        }
        ScanButton(phase: .idle) {}
        FloatingActionButton(label: "Clean 8 items · 19.8 GB", systemImage: "sparkles") {}
        EmptyStateView(symbol: "checkmark.seal", title: "Your Mac is tidy",
                       message: "Nothing to clean right now. Last scanned 2 hours ago.",
                       actionTitle: "Scan again") {}
    }
    .padding(40).frame(width: 460)
}
