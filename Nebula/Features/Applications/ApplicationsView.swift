//
//  ApplicationsView.swift
//  Nebula — inventory + updates + startup items + complete uninstall.
//

import SwiftUI

struct ApplicationsView: View {
    @Environment(AppState.self) private var app
    @State private var search = ""
    @State private var filter: AppFilter = .all
    @State private var selection: InstalledApp.ID?

    enum AppFilter: String, CaseIterable, Identifiable {
        case all = "All", updates = "Updates", unused = "Unused", large = "Large"
        var id: String { rawValue }
    }

    private func matchesFilter(_ item: InstalledApp) -> Bool {
        switch filter {
        case .all:     return true
        case .updates: return item.hasUpdate
        case .unused:  return item.isUnused
        case .large:   return item.bytes > 1_000_000_000
        }
    }

    private var apps: [InstalledApp] {
        app.apps
            .filter { item in
                (search.isEmpty || item.name.localizedCaseInsensitiveContains(search))
                    && matchesFilter(item)
            }
            .sorted { $0.bytes > $1.bytes }
    }

    private var selectedApp: InstalledApp? {
        app.apps.first { $0.id == selection }
    }

    var body: some View {
        HStack(spacing: 0) {
            listColumn
            Divider()
            detailColumn.frame(width: 340)
        }
        .navigationTitle("Applications")
        .background(.windowBackground)
        .searchable(text: $search, placement: .toolbar, prompt: "Search apps")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Filter", selection: $filter) {
                    ForEach(AppFilter.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
            }
        }
    }

    private var listColumn: some View {
        Group {
            if apps.isEmpty {
                EmptyStateView(symbol: "magnifyingglass", title: "No apps match",
                               message: "Try a different search or clear the filter.",
                               actionTitle: "Clear filters") { search = ""; filter = .all }
            } else {
                List(apps, selection: $selection) { app in
                    AppRow(app: app).tag(app.id)
                }
                .listStyle(.inset)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var detailColumn: some View {
        if let selectedApp {
            AppDetailPanel(app: selectedApp)
        } else {
            EmptyStateView(symbol: "square.grid.2x2",
                           title: "Select an app",
                           message: "Choose an app to see its size, related files, and uninstall options.")
        }
    }
}

private struct AppRow: View {
    let app: InstalledApp
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "app.dashed")
                .font(.system(size: 22)).foregroundStyle(.tint).frame(width: 34)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: Spacing.sm) {
                    Text(app.name).font(.nebulaCallout)
                    if app.hasUpdate { Pill(text: "Update", tint: .nebulaInfo, style: .filled) }
                    if app.isStartupItem { Pill(text: "Login", tint: .secondary, style: .outline) }
                }
                Text(lastOpenedText).nebulaCaptionStyle()
            }
            Spacer()
            Text(ByteFormat.string(app.bytes)).font(.nebulaCallout).nebulaNumeric()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    private var lastOpenedText: String {
        guard let d = app.lastOpened else { return "Never opened" }
        return "Last opened \(d.formatted(.relative(presentation: .named)))"
    }
}

private struct AppDetailPanel: View {
    let app: InstalledApp
    @State private var showConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "app.dashed").font(.system(size: 40)).foregroundStyle(.tint)
                    VStack(alignment: .leading) {
                        Text(app.name).font(.nebulaSection)
                        Text("Version \(app.version)").nebulaCaptionStyle()
                        Text(app.bundleID).font(.nebulaMono).foregroundStyle(.tertiary)
                            .lineLimit(1).truncationMode(.middle)
                    }
                }

                HStack {
                    StatTile(label: "Size", value: ByteFormat.string(app.bytes))
                    StatTile(label: "Last opened",
                             value: app.lastOpened?.formatted(.relative(presentation: .named)) ?? "Never")
                }

                confidence

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Related files").font(.nebulaCardTitle)
                    ForEach(app.relatedFiles) { f in
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: f.isProtected ? "lock.fill" : "doc")
                                .font(.system(size: 11))
                                .foregroundStyle(f.isProtected ? Color.nebulaDanger : Color.secondary)
                            Text(f.path).font(.nebulaMono).lineLimit(1).truncationMode(.middle)
                            Spacer()
                            Text(ByteFormat.string(f.bytes)).nebulaCaptionStyle().nebulaNumeric()
                        }
                    }
                }
                .glassCard()

                Button(role: .destructive) { showConfirm = true } label: {
                    Label("Uninstall completely", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent).controlSize(.large).tint(.nebulaDanger)
            }
            .padding(Spacing.lg)
        }
        .background(.regularMaterial)
        .confirmationDialog("Uninstall \(app.name)?", isPresented: $showConfirm, titleVisibility: .visible) {
            Button("Move app & files to Trash", role: .destructive) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(app.relatedFiles.count) related files will be moved to Trash. Protected items are excluded.")
        }
    }

    private var confidence: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Uninstall confidence").font(.nebulaCardTitle)
                Spacer()
                Text("\(Int(app.uninstallConfidence * 100))%")
                    .font(.nebulaCallout).nebulaNumeric()
                    .foregroundStyle(confidenceColor)
            }
            ProgressView(value: app.uninstallConfidence).tint(confidenceColor)
            Text(confidenceCopy).nebulaCaptionStyle()
        }
        .glassCard()
    }
    private var confidenceColor: Color {
        app.uninstallConfidence > 0.85 ? .nebulaSuccess
        : app.uninstallConfidence > 0.65 ? .nebulaWarning : .nebulaDanger
    }
    private var confidenceCopy: String {
        app.uninstallConfidence > 0.85 ? "All related files identified. Clean removal expected."
        : "Some shared or system-adjacent files detected. Review before removing."
    }
}

private struct StatTile: View {
    var label: String, value: String
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(label).nebulaCaptionStyle()
            Text(value).font(.nebulaCallout).nebulaNumeric()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(padding: Spacing.md)
    }
}

#Preview { ApplicationsView().environment(AppState()).frame(width: 1100, height: 760) }
