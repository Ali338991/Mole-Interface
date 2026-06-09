//
//  SmartCleanView.swift
//  Nebula — the core clean loop: scan → review → confirm → clean → done.
//

import SwiftUI

struct SmartCleanView: View {
    @Environment(AppState.self) private var app
    @State private var selected: Set<UUID> = []
    @State private var showConfirm = false
    @State private var dryRun = false

    private var selectedCategories: [CleanCategory] {
        app.cleanCategories.filter { selected.contains($0.id) }
    }
    private var selectedBytes: Int64 { selectedCategories.reduce(0) { $0 + $1.bytes } }

    var body: some View {
        Group {
            switch app.cleanPhase {
            case .idle:                       idleOrResults(scanned: false)
            case .scanning(let p):            scanning(progress: p)
            case .results:                    idleOrResults(scanned: true)
            case .working(let p):             cleaning(progress: p)
            case .complete(let freed):        completion(freed: freed)
            }
        }
        .navigationTitle("Smart Clean")
        .background(.windowBackground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ScanButton(phase: scanButtonPhase, idleTitle: "Scan") {
                    selected = []
                    app.simulateCleanScan()
                }
            }
        }
        .onAppear { preselectSafe() }
        .confirmationDialog("Clean \(ByteFormat.string(selectedBytes))?",
                            isPresented: $showConfirm, titleVisibility: .visible) {
            Button(dryRun ? "Preview (dry run)" : "Move to Trash & Clean",
                   role: dryRun ? nil : .destructive) {
                if !dryRun { app.simulateClean(freeing: selectedBytes) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Recoverable items move to Trash. \(selectedCategories.filter { !$0.routesToTrash }.count) categories are removed permanently. Protected system paths are always excluded.")
        }
    }

    private var scanButtonPhase: ScanButton.Phase {
        switch app.cleanPhase {
        case .scanning: .scanning
        case .results, .complete: .done
        default: .idle
        }
    }

    private func preselectSafe() {
        guard selected.isEmpty else { return }
        selected = Set(app.cleanCategories.filter { $0.safety == .safe }.map(\.id))
    }

    // MARK: Idle / Results

    @ViewBuilder
    private func idleOrResults(scanned: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                summaryHeader(scanned: scanned)
                categoryGroup(.safe, title: "Safe to clean")
                categoryGroup(.review, title: "Review recommended")
                categoryGroup(.advanced, title: "Advanced")
                Color.clear.frame(height: 60)
            }
            .screenPadding()
        }
        .overlay(alignment: .bottom) { actionBar }
    }

    private func summaryHeader(scanned: Bool) -> some View {
        HStack(spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(ByteFormat.string(app.reclaimableBytes))
                    .font(.nebulaHero).nebulaNumeric()
                Text(scanned ? "found across \(app.cleanCategories.count) categories"
                             : "estimated reclaimable space").nebulaCaptionStyle()
            }
            Spacer()
            Toggle("Dry run", isOn: $dryRun).toggleStyle(.switch)
                .help("Preview what would be removed without deleting anything.")
        }
        .glassCard(padding: Spacing.xl)
    }

    @ViewBuilder
    private func categoryGroup(_ safety: SafetyLevel, title: String) -> some View {
        let items = app.cleanCategories.filter { $0.safety == safety }
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                SectionHeader(title, subtitle: "\(ByteFormat.string(items.reduce(0){$0+$1.bytes}))")
                LazyVGrid(columns: [.init(.adaptive(minimum: 300), spacing: Spacing.lg)],
                          spacing: Spacing.lg) {
                    ForEach(items) { cat in
                        CategoryCard(category: cat, isSelected: binding(for: cat.id))
                    }
                }
            }
        }
    }

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(get: { selected.contains(id) },
                set: { if $0 { selected.insert(id) } else { selected.remove(id) } })
    }

    @ViewBuilder
    private var actionBar: some View {
        if !selected.isEmpty {
            FloatingActionButton(
                label: "Clean \(selected.count) categories · \(ByteFormat.string(selectedBytes))",
                systemImage: "sparkles") { showConfirm = true }
                .padding(.bottom, Spacing.xl)
        }
    }

    // MARK: Scanning

    private func scanning(progress: Double) -> some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                PulseRing()
                ProgressRing(progress: progress, lineWidth: 10).frame(width: 160, height: 160)
                VStack {
                    Text("\(Int(progress * 100))%").font(.nebulaTitle).nebulaNumeric()
                    Text("Scanning").nebulaCaptionStyle()
                }
            }
            Text("Inspecting caches, logs, leftovers, and developer junk…")
                .nebulaCaptionStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Cleaning

    private func cleaning(progress: Double) -> some View {
        VStack(spacing: Spacing.xl) {
            ProgressRing(progress: progress, lineWidth: 10, tint: .nebulaSuccess)
                .frame(width: 160, height: 160)
                .overlay { Text("\(Int(progress*100))%").font(.nebulaTitle).nebulaNumeric() }
            Text("Cleaning safely…").font(.nebulaSection)
            Text("Recoverable items are moving to Trash.").nebulaCaptionStyle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Completion

    private func completion(freed: Int64) -> some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.nebulaSuccess)
                .symbolEffect(.bounce, value: freed)
            Text(ByteFormat.string(freed)).font(.nebulaHero).nebulaNumeric()
            Text("freed up").font(.nebulaSection).foregroundStyle(.secondary)
            HStack(spacing: Spacing.md) {
                Button("Undo") { app.resetClean() }.controlSize(.large)
                Button("Done") { app.resetClean() }
                    .buttonStyle(.borderedProminent).controlSize(.large).tint(.nebulaAccent)
            }
            .padding(.top, Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Ambient pulsing ring behind the scan indicator.
private struct PulseRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false
    var body: some View {
        Circle()
            .stroke(Color.nebulaAccent.opacity(0.25), lineWidth: 2)
            .frame(width: 200, height: 200)
            .scaleEffect(animate ? 1.15 : 0.9)
            .opacity(animate ? 0 : 0.8)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 1.6).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
    }
}

#Preview { SmartCleanView().environment(AppState()).frame(width: 1100, height: 760) }
