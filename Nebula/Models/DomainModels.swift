//
//  DomainModels.swift
//  Nebula — Domain models
//
//  Pure value types shared across features. No UI, no system access.
//  Sizes are stored in bytes (Int64) and formatted at the edge with
//  `ByteFormat`.
//

import SwiftUI

// MARK: - Byte formatting

enum ByteFormat {
    static func string(_ bytes: Int64) -> String {
        let f = ByteCountFormatter()
        f.countStyle = .file
        f.allowedUnits = [.useGB, .useMB, .useKB]
        return f.string(fromByteCount: bytes)
    }
}

// MARK: - Safety

/// How safe a cleanup target is. Drives pre-selection and badges.
enum SafetyLevel: String, CaseIterable {
    case safe       = "Safe to clean"
    case review     = "Review recommended"
    case advanced   = "Advanced"

    var tint: Color {
        switch self {
        case .safe:     return .nebulaSuccess
        case .review:   return .nebulaWarning
        case .advanced: return .nebulaDanger
        }
    }

    var symbol: String {
        switch self {
        case .safe:     return "checkmark.shield.fill"
        case .review:   return "exclamationmark.triangle.fill"
        case .advanced: return "lock.shield.fill"
        }
    }
}

// MARK: - Smart Clean

struct CleanCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbol: String
    let bytes: Int64
    let itemCount: Int
    let safety: SafetyLevel
    /// Whether removed items route to Trash (recoverable) vs. permanent.
    let routesToTrash: Bool
    /// Example included paths, for the expand-to-preview affordance.
    let samplePaths: [String]
}

// MARK: - Applications

struct InstalledApp: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleID: String
    let version: String
    let bytes: Int64
    let lastOpened: Date?
    let hasUpdate: Bool
    let isStartupItem: Bool
    /// 0...1 confidence that a full uninstall is safe & complete.
    let uninstallConfidence: Double
    let relatedFiles: [RelatedFile]

    var isUnused: Bool {
        guard let lastOpened else { return true }
        return Date().timeIntervalSince(lastOpened) > 60 * 60 * 24 * 90
    }
}

struct RelatedFile: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let bytes: Int64
    let isProtected: Bool
}

// MARK: - Optimize

struct OptimizeTask: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let detail: String
    let symbol: String
    let safety: SafetyLevel
    let estimatedSeconds: Int
    var isRecommended: Bool
}

// MARK: - Disk Analyzer

final class DiskNode: Identifiable {
    let id = UUID()
    let name: String
    let bytes: Int64
    let kind: DiskKind
    var children: [DiskNode]

    init(name: String, bytes: Int64, kind: DiskKind, children: [DiskNode] = []) {
        self.name = name
        self.bytes = bytes
        self.kind = kind
        self.children = children
    }

    var isLeaf: Bool { children.isEmpty }
}

enum DiskKind: String, CaseIterable {
    case apps = "Applications"
    case documents = "Documents"
    case media = "Media"
    case developer = "Developer"
    case system = "System"
    case caches = "Caches"
    case other = "Other"

    var color: Color {
        switch self {
        case .apps:      return .catApps
        case .documents: return .catDocs
        case .media:     return .catMedia
        case .developer: return .catDev
        case .system:    return .catSystem
        case .caches:    return .catCaches
        case .other:     return .catOther
        }
    }
}

struct LargeFile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let bytes: Int64
    let modified: Date
    let kind: DiskKind
}

// MARK: - System Monitor

enum MetricKind: String, CaseIterable, Identifiable {
    case cpu = "CPU", gpu = "GPU", memory = "Memory", disk = "Disk"
    case network = "Network", battery = "Battery", temperature = "Temp", fans = "Fans"
    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .cpu: "cpu"
        case .gpu: "cpu.fill"
        case .memory: "memorychip"
        case .disk: "internaldrive"
        case .network: "network"
        case .battery: "battery.75"
        case .temperature: "thermometer.medium"
        case .fans: "fanblades"
        }
    }

    var unit: String {
        switch self {
        case .cpu, .gpu, .memory, .battery: "%"
        case .disk: "MB/s"
        case .network: "Mbps"
        case .temperature: "°C"
        case .fans: "RPM"
        }
    }
}

struct MetricSample: Identifiable, Hashable {
    let id = UUID()
    let time: Date
    let value: Double
}

struct LiveMetric: Identifiable {
    let id = UUID()
    let kind: MetricKind
    var current: Double
    var history: [MetricSample]
    let tint: Color
}

struct ProcessInsight: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let cpu: Double
    let memoryBytes: Int64
}

// MARK: - Developer Cleanup

struct DevArtifactGroup: Identifiable, Hashable {
    let id = UUID()
    let name: String          // e.g. "node_modules"
    let symbol: String
    let bytes: Int64
    let projectCount: Int
    let projects: [DevProject]
}

struct DevProject: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let path: String
    let bytes: Int64
    let lastModified: Date

    var ageDays: Int {
        Int(Date().timeIntervalSince(lastModified) / 86_400)
    }
    var isStale: Bool { ageDays > 90 }
}
