//
//  NavigationModels.swift
//  Nebula — Navigation destinations
//

import SwiftUI

/// Every primary destination in the sidebar workspace.
enum Destination: String, CaseIterable, Identifiable, Hashable {
    case dashboard, smartClean, applications, optimize
    case diskAnalyzer, systemMonitor, developerCleanup

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:        "Dashboard"
        case .smartClean:       "Smart Clean"
        case .applications:     "Applications"
        case .optimize:         "Optimize"
        case .diskAnalyzer:     "Disk Analyzer"
        case .systemMonitor:    "System Monitor"
        case .developerCleanup: "Developer Cleanup"
        }
    }

    var subtitle: String {
        switch self {
        case .dashboard:        "Last scan 14 minutes ago"
        case .smartClean:       "Last scan 14 minutes ago"
        case .applications:     "12 apps · 28.6 GB"
        case .optimize:         "System maintenance"
        case .diskAnalyzer:     "Macintosh HD · 994.7 GB"
        case .systemMonitor:    "Live · updated every 2s"
        case .developerCleanup: "Regenerable build artifacts"
        }
    }

    var symbol: String {
        switch self {
        case .dashboard:        "gauge.with.dots.needle.50percent"
        case .smartClean:       "sparkles"
        case .applications:     "square.grid.2x2"
        case .optimize:         "wand.and.stars"
        case .diskAnalyzer:     "chart.pie"
        case .systemMonitor:    "waveform.path.ecg"
        case .developerCleanup: "hammer"
        }
    }

    /// Sidebar grouping.
    enum Section: String, CaseIterable, Identifiable {
        case overview = "Overview"
        case reclaim  = "Reclaim"
        case system   = "System"
        var id: String { rawValue }
    }

    var section: Section {
        switch self {
        case .dashboard: .overview
        case .smartClean, .applications, .diskAnalyzer, .developerCleanup: .reclaim
        case .optimize, .systemMonitor: .system
        }
    }

    static func items(in section: Section) -> [Destination] {
        allCases.filter { $0.section == section }
    }
}

/// A globally-invokable action surfaced in the command palette.
struct PaletteCommand: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let symbol: String
    let destination: Destination?
}
