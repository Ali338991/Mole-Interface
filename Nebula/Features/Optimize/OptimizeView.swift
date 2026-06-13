//
//  OptimizeView.swift
//  Nebula — optimization center: health, recommended actions, safe/advanced.
//

import SwiftUI

struct OptimizeView: View {
    @Environment(AppState.self) private var app
    @State private var mode: Mode = .safe
    @State private var selected: Set<UUID> = []
    @State private var running = false
    @State private var progress = 0.0

    enum Mode: String, CaseIterable, Identifiable { case safe = "Safe", advanced = "Advanced"; var id: String { rawValue } }

    private var tasks: [OptimizeTask] {
        app.optimizeTasks.filter { mode == .advanced || $0.safety != .advanced }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                center
                modePicker
                taskList
                Color.clear.frame(height: 40)
            }
            .screenPadding()
        }
        .navigationTitle("Optimize")
        .background(.windowBackground)
        .overlay(alignment: .bottom) {
            if !selected.isEmpty && !running {
                FloatingActionButton(label: "Run \(selected.count) tasks",
                                     systemImage: "wand.and.stars") { run() }
                    .padding(.bottom, Spacing.xl)
            }
        }
        .onAppear { selected = Set(app.optimizeTasks.filter(\.isRecommended).map(\.id)) }
    }

    private var center: some View {
        HStack(spacing: Spacing.xl) {
            ZStack {
                ProgressRing(progress: running ? progress : Double(app.healthScore)/100,
                             lineWidth: 12, tint: HealthTint.color(for: app.healthScore))
                    .frame(width: 130, height: 130)
                VStack {
                    Text(running ? "\(Int(progress*100))%" : "\(app.healthScore)")
                        .font(.nebulaTitle).nebulaNumeric()
                    Text(running ? "Optimizing" : "Health").nebulaCaptionStyle()
                }
            }
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Optimization center").font(.nebulaSection)
                Text("Run recommended maintenance to keep your Mac fast and your indexes fresh. Advanced tasks are available behind a toggle.")
                    .nebulaCaptionStyle().fixedSize(horizontal: false, vertical: true)
                Button {
                    selected = Set(app.optimizeTasks.filter(\.isRecommended).map(\.id)); run()
                } label: { Label("Run recommended", systemImage: "play.fill") }
                    .buttonStyle(.borderedProminent).controlSize(.large).tint(.nebulaAccent)
                    .disabled(running)
            }
            Spacer()
        }
        .glassCard(padding: Spacing.xl)
    }

    private var modePicker: some View {
        HStack {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }.pickerStyle(.segmented).frame(width: 220)
            if mode == .advanced {
                Pill(text: "Advanced tasks can affect running apps",
                     symbol: "exclamationmark.triangle.fill", tint: .nebulaWarning)
            }
            Spacer()
        }
    }

    private var taskList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(tasks) { task in
                OptimizeRow(task: task, isSelected: binding(for: task.id),
                            running: running, disabled: running)
            }
        }
    }

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(get: { selected.contains(id) },
                set: { if $0 { selected.insert(id) } else { selected.remove(id) } })
    }

    private func run() {
        running = true; progress = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            progress += 0.02
            if progress >= 1 {
                t.invalidate(); running = false
                withAnimation(Motion.smooth) { app.healthScore = min(100, app.healthScore + 9) }
                selected.removeAll()
            }
        }
    }
}

private struct OptimizeRow: View {
    let task: OptimizeTask
    @Binding var isSelected: Bool
    var running: Bool
    var disabled: Bool

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: task.symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(task.safety.tint)
                .frame(width: 36, height: 36)
                .background(task.safety.tint.opacity(0.12), in: .rect(cornerRadius: 9))
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: Spacing.sm) {
                    Text(task.name).font(.nebulaCallout)
                    if task.safety == .advanced {
                        Pill(text: "Advanced", tint: .nebulaDanger, style: .outline)
                    }
                }
                Text(task.detail).nebulaCaptionStyle()
            }
            Spacer()
            Text("~\(task.estimatedSeconds)s").nebulaCaptionStyle().nebulaNumeric()
            Toggle("", isOn: $isSelected).toggleStyle(.checkbox).labelsHidden().disabled(disabled)
        }
        .glassCard(padding: Spacing.md)
    }
}

#Preview { OptimizeView().environment(AppState()).frame(width: 1100, height: 760) }
