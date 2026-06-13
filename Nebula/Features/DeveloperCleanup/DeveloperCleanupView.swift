//
//  DeveloperCleanupView.swift
//  Nebula — project scanner with age-aware reclamation (mo purge + dev caches).
//

import SwiftUI

struct DeveloperCleanupView: View {
    @Environment(AppState.self) private var app
    @State private var selected: Set<UUID> = []
    @State private var staleOnly = false
    @State private var showConfirm = false

    private var groups: [DevArtifactGroup] { app.devGroups }

    private var selectedBytes: Int64 {
        groups.flatMap(\.projects).filter { selected.contains($0.id) }.reduce(0) { $0 + $1.bytes }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                header
                ForEach(groups) { group in
                    groupSection(group)
                }
                Color.clear.frame(height: 60)
            }
            .screenPadding()
        }
        .navigationTitle("Developer Cleanup")
        .background(.windowBackground)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Toggle("Stale only (>90 days)", isOn: $staleOnly).toggleStyle(.switch)
            }
        }
        .overlay(alignment: .bottom) {
            if !selected.isEmpty {
                FloatingActionButton(label: "Reclaim \(ByteFormat.string(selectedBytes))",
                                     systemImage: "hammer") { showConfirm = true }
                    .padding(.bottom, Spacing.xl)
            }
        }
        .confirmationDialog("Reclaim \(ByteFormat.string(selectedBytes))?",
                            isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Move to Trash", role: .destructive) { selected.removeAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Build artifacts can be regenerated. Source files are never touched.")
        }
    }

    private var header: some View {
        HStack(spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(ByteFormat.string(app.devTotalBytes)).font(.nebulaHero).nebulaNumeric()
                Text("in regenerable build artifacts across your projects").nebulaCaptionStyle()
            }
            Spacer()
            Image(systemName: "hammer.circle.fill")
                .font(.system(size: 44)).foregroundStyle(.nebulaSuccess)
        }
        .glassCard(padding: Spacing.xl)
    }

    @ViewBuilder
    private func groupSection(_ group: DevArtifactGroup) -> some View {
        let projects = group.projects.filter { !staleOnly || $0.isStale }
        if !projects.isEmpty {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Image(systemName: group.symbol).foregroundStyle(.tint)
                    Text(group.name).font(.nebulaSection)
                    Pill(text: "\(group.projectCount) projects", tint: .secondary, style: .outline)
                    Spacer()
                    Text(ByteFormat.string(group.bytes)).font(.nebulaCallout).nebulaNumeric()
                        .foregroundStyle(.secondary)
                    Button(allSelected(projects) ? "Deselect all" : "Select all") {
                        toggleAll(projects)
                    }.buttonStyle(.link).font(.nebulaCaption)
                }
                ForEach(projects) { proj in
                    projectRow(proj)
                }
            }
        }
    }

    private func projectRow(_ proj: DevProject) -> some View {
        HStack(spacing: Spacing.md) {
            Toggle("", isOn: binding(for: proj.id)).toggleStyle(.checkbox).labelsHidden()
            VStack(alignment: .leading, spacing: 1) {
                Text(proj.name).font(.nebulaCallout)
                Text(proj.path).font(.nebulaMono).foregroundStyle(.tertiary)
                    .lineLimit(1).truncationMode(.middle)
            }
            Spacer()
            if proj.isStale {
                Pill(text: "\(proj.ageDays)d untouched", symbol: "clock.badge.exclamationmark",
                     tint: .nebulaWarning)
            } else {
                Text("\(proj.ageDays)d ago").nebulaCaptionStyle().nebulaNumeric()
            }
            Text(ByteFormat.string(proj.bytes)).font(.nebulaCallout).nebulaNumeric()
                .frame(width: 80, alignment: .trailing)
        }
        .glassCard(padding: Spacing.md, elevation: selected.contains(proj.id) ? .raised : .flat)
    }

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(get: { selected.contains(id) },
                set: { if $0 { selected.insert(id) } else { selected.remove(id) } })
    }
    private func allSelected(_ projects: [DevProject]) -> Bool {
        projects.allSatisfy { selected.contains($0.id) }
    }
    private func toggleAll(_ projects: [DevProject]) {
        if allSelected(projects) { projects.forEach { selected.remove($0.id) } }
        else { projects.forEach { selected.insert($0.id) } }
    }
}

#Preview { DeveloperCleanupView().environment(AppState()).frame(width: 1100, height: 760) }
