//
//  SystemMonitorView.swift
//  Nebula — beautiful live monitoring (mo status), not boring graphs.
//

import SwiftUI
import Charts

struct SystemMonitorView: View {
    @State private var metrics: [LiveMetric] = MockData.liveMetrics()
    @State private var expanded: MetricKind?
    @State private var paused = false
    @State private var timescale: Timescale = .minute

    // INTEGRATION: replace this demo timer with a real sampler reading
    // `mo status --json` or system APIs.
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum Timescale: String, CaseIterable, Identifiable {
        case minute = "1m", hour = "1h", day = "24h"; var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                grid
                if let expanded, let metric = metrics.first(where: { $0.kind == expanded }) {
                    detailChart(metric)
                }
                processes
            }
            .screenPadding()
            .padding(.bottom, Spacing.xl)
        }
        .navigationTitle("System Monitor")
        .background(.windowBackground)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Scale", selection: $timescale) {
                    ForEach(Timescale.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented).frame(width: 160)
            }
            ToolbarItem(placement: .primaryAction) {
                Button { paused.toggle() } label: {
                    Label(paused ? "Resume" : "Pause",
                          systemImage: paused ? "play.fill" : "pause.fill")
                }
            }
        }
        .onReceive(tick) { _ in if !paused { advance() } }
    }

    private var grid: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 230), spacing: Spacing.lg)],
                  spacing: Spacing.lg) {
            ForEach(metrics) { m in
                Button { withAnimation(Motion.snappy) { expanded = (expanded == m.kind ? nil : m.kind) } } label: {
                    MetricCard(
                        title: m.kind.rawValue,
                        value: formatted(m),
                        systemImage: m.kind.symbol,
                        tint: m.tint,
                        trend: m.history.suffix(30).map(\.value)
                    )
                }
                .buttonStyle(.plain)
                .overlay(alignment: .topTrailing) {
                    if expanded == m.kind {
                        Image(systemName: "chevron.up.circle.fill")
                            .foregroundStyle(m.tint).padding(8)
                    }
                }
            }
        }
    }

    private func detailChart(_ m: LiveMetric) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader("\(m.kind.rawValue) history", subtitle: "Last \(timescale.rawValue) · now \(formatted(m))")
            Chart(m.history) { sample in
                AreaMark(x: .value("Time", sample.time), y: .value(m.kind.unit, sample.value))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(LinearGradient(colors: [m.tint.opacity(0.4), m.tint.opacity(0.03)],
                                                    startPoint: .top, endPoint: .bottom))
                LineMark(x: .value("Time", sample.time), y: .value(m.kind.unit, sample.value))
                    .interpolationMethod(.monotone)
                    .foregroundStyle(m.tint)
            }
            .chartYScale(domain: yDomain(for: m))
            .frame(minHeight: 260)
        }
        .glassCard()
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var processes: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader("Process insights", subtitle: "Top consumers right now")
            VStack(spacing: Spacing.sm) {
                ForEach(MockData.processes) { p in
                    HStack(spacing: Spacing.md) {
                        Text(p.name).font(.nebulaCallout).frame(width: 200, alignment: .leading)
                        ProgressView(value: min(p.cpu, 200), total: 200).tint(.nebulaAccent)
                        Text("\(Int(p.cpu))% CPU").nebulaCaptionStyle().nebulaNumeric().frame(width: 70, alignment: .trailing)
                        Text(ByteFormat.string(p.memoryBytes)).nebulaCaptionStyle().nebulaNumeric().frame(width: 80, alignment: .trailing)
                    }
                }
            }
        }
        .glassCard()
    }

    // MARK: Helpers

    private func formatted(_ m: LiveMetric) -> String {
        switch m.kind {
        case .fans: "\(Int(m.current)) \(m.kind.unit)"
        case .temperature: "\(Int(m.current))\(m.kind.unit)"
        default: "\(Int(m.current))\(m.kind.unit)"
        }
    }

    private func yDomain(for m: LiveMetric) -> ClosedRange<Double> {
        switch m.kind {
        case .cpu, .gpu, .memory, .battery: 0...100
        case .temperature: 30...90
        case .fans: 0...5000
        default: 0...max(120, (m.history.map(\.value).max() ?? 100) * 1.2)
        }
    }

    private func advance() {
        for i in metrics.indices {
            let spread: Double = metrics[i].kind == .fans ? 200 : 12
            let next = max(0, metrics[i].current + Double.random(in: -spread...spread))
            let capped = clamp(next, for: metrics[i].kind)
            metrics[i].current = capped
            metrics[i].history.append(MetricSample(time: Date(), value: capped))
            if metrics[i].history.count > 60 { metrics[i].history.removeFirst() }
        }
    }

    private func clamp(_ v: Double, for kind: MetricKind) -> Double {
        switch kind {
        case .cpu, .gpu, .memory, .battery: min(100, v)
        case .temperature: min(95, max(30, v))
        case .fans: min(5000, max(0, v))
        default: v
        }
    }
}

#Preview { SystemMonitorView().environment(AppState()).frame(width: 1100, height: 760) }
