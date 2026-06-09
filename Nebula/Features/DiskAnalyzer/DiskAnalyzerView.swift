//
//  DiskAnalyzerView.swift
//  Nebula — a superior DaisyDisk: treemap, sunburst, largest files, timeline.
//

import SwiftUI
import Charts

struct DiskAnalyzerView: View {
    @State private var mode: ViewMode = .treemap
    @State private var path: [DiskNode] = []
    @State private var selectedFiles: Set<UUID> = []

    enum ViewMode: String, CaseIterable, Identifiable {
        case treemap = "Treemap", sunburst = "Sunburst", largest = "Largest", timeline = "Timeline"
        var id: String { rawValue }
        var symbol: String {
            switch self {
            case .treemap: "square.grid.3x3.fill"
            case .sunburst: "chart.pie.fill"
            case .largest: "list.number"
            case .timeline: "calendar"
            }
        }
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            content
        }
        .screenPadding()
        .padding(.bottom, Spacing.lg)
        .navigationTitle("Disk Analyzer")
        .background(.windowBackground)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("View", selection: $mode) {
                    ForEach(ViewMode.allCases) { Label($0.rawValue, systemImage: $0.symbol).tag($0) }
                }.pickerStyle(.segmented)
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch mode {
        case .treemap:
            TreemapView(root: MockData.diskRoot, path: $path)
        case .sunburst:
            SunburstView(node: path.last ?? MockData.diskRoot)
                .glassCard()
        case .largest:
            largestFiles
        case .timeline:
            timeline
        }
    }

    // MARK: Largest files

    private var largestFiles: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Table(MockData.largeFiles) {
                TableColumn("Name") { f in
                    HStack(spacing: Spacing.sm) {
                        Circle().fill(f.kind.color).frame(width: 8, height: 8)
                        Text(f.name)
                    }
                }
                TableColumn("Path") { f in
                    Text(f.path).font(.nebulaMono).foregroundStyle(.secondary)
                        .lineLimit(1).truncationMode(.middle)
                }
                TableColumn("Modified") { f in
                    Text(f.modified.formatted(.relative(presentation: .named)))
                        .foregroundStyle(.secondary)
                }
                TableColumn("Size") { f in
                    Text(ByteFormat.string(f.bytes)).nebulaNumeric()
                }
            }
            HStack {
                Spacer()
                Button(role: .destructive) {} label: {
                    Label("Move selected to Trash", systemImage: "trash")
                }
                .controlSize(.large)
                .help("Ad-hoc cleanup always routes to Trash for safety.")
            }
        }
        .glassCard()
    }

    // MARK: Timeline (size by age — find old, large, forgotten data)

    private var timeline: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader("Storage by age", subtitle: "Large items you haven't touched in a while")
            Chart(MockData.largeFiles) { f in
                PointMark(
                    x: .value("Age (days)", Int(Date().timeIntervalSince(f.modified) / 86_400)),
                    y: .value("Size (GB)", Double(f.bytes) / 1_000_000_000)
                )
                .foregroundStyle(f.kind.color)
                .symbolSize(by: .value("Size", Double(f.bytes)))
                .annotation(position: .top) {
                    Text(f.name).font(.system(size: 9)).foregroundStyle(.secondary)
                }
            }
            .chartXAxisLabel("Days since modified")
            .chartYAxisLabel("Size (GB)")
            .frame(minHeight: 320)
        }
        .glassCard()
    }
}

#Preview { DiskAnalyzerView().environment(AppState()).frame(width: 1100, height: 760) }
