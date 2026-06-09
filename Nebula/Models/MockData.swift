//
//  MockData.swift
//  Mole — Demo fixtures
//
//  Realistic sample data (sizes in decimal GB so the
//  byte formatter renders the same numbers). Replace each producer with a real
//  service behind the same shape when wiring the Mole CLI / system APIs.
//

import SwiftUI

private let GB: Int64 = 1_000_000_000

enum MockData {

    private static func daysAgo(_ d: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -d, to: Date()) ?? Date()
    }
    private static func gb(_ v: Double) -> Int64 { Int64(v * 1_000_000_000) }

    // MARK: Smart Clean (grouped by safety)

    static let cleanCategories: [CleanCategory] = [
        // Safe
        .init(name: "System caches", symbol: "cpu", bytes: gb(8.4), itemCount: 12_840,
              safety: .safe, routesToTrash: true,
              samplePaths: ["~/Library/Caches/com.apple.Safari", "/Library/Caches/com.apple.iconservices.store", "~/Library/Caches/CloudKit"]),
        .init(name: "Browser caches", symbol: "globe", bytes: gb(5.1), itemCount: 9_210,
              safety: .safe, routesToTrash: true,
              samplePaths: ["~/Library/Caches/Google/Chrome/Default", "~/Library/Caches/com.apple.Safari/WebKitCache", "~/Library/Caches/Firefox/Profiles"]),
        .init(name: "Logs & diagnostics", symbol: "doc.text", bytes: gb(1.9), itemCount: 3_420,
              safety: .safe, routesToTrash: true,
              samplePaths: ["~/Library/Logs/DiagnosticReports", "/private/var/log/asl", "~/Library/Logs/CoreSimulator"]),
        .init(name: "Trash", symbol: "trash", bytes: gb(3.6), itemCount: 184,
              safety: .safe, routesToTrash: false,
              samplePaths: ["~/.Trash (184 items)"]),
        // Review
        .init(name: "Xcode junk", symbol: "hammer", bytes: gb(14.8), itemCount: 642,
              safety: .review, routesToTrash: true,
              samplePaths: ["~/Library/Developer/Xcode/DerivedData", "~/Library/Developer/Xcode/iOS DeviceSupport", "~/Library/Developer/Xcode/Archives"]),
        .init(name: "App leftovers", symbol: "app.badge", bytes: gb(2.3), itemCount: 96,
              safety: .review, routesToTrash: true,
              samplePaths: ["~/Library/Application Support/Sketch", "~/Library/Preferences/com.spotify.client.plist", "~/Library/Caches/com.tinyspeck.slackmacgap"]),
        .init(name: "Installer files", symbol: "shippingbox", bytes: gb(6.2), itemCount: 11,
              safety: .review, routesToTrash: true,
              samplePaths: ["~/Downloads/Docker.dmg (612 MB)", "~/Downloads/Xcode_16.2.xip (3.1 GB)", "~/Downloads/Figma-124.5.dmg"]),
        // Advanced
        .init(name: "Docker dangling layers", symbol: "cube.box", bytes: gb(11.4), itemCount: 38,
              safety: .advanced, routesToTrash: false,
              samplePaths: ["Docker.raw — dangling image layers", "38 untagged images", "build cache (overlay2)"]),
    ]

    static var cleanTotalBytes: Int64 { cleanCategories.reduce(0) { $0 + $1.bytes } }

    // MARK: Applications

    static let apps: [InstalledApp] = [
        .init(name: "Xcode", bundleID: "com.apple.dt.Xcode", version: "16.2", bytes: gb(14.2),
              lastOpened: Date().addingTimeInterval(-7200), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.88, relatedFiles: related(7.0)),
        .init(name: "Figma", bundleID: "com.figma.Desktop", version: "124.4", bytes: gb(1.42),
              lastOpened: daysAgo(1), hasUpdate: true, isStartupItem: false,
              uninstallConfidence: 0.96, relatedFiles: related(0.6)),
        .init(name: "Docker Desktop", bundleID: "com.docker.docker", version: "4.34.2", bytes: gb(2.81),
              lastOpened: daysAgo(3), hasUpdate: true, isStartupItem: true,
              uninstallConfidence: 0.79, relatedFiles: dockerRelated),
        .init(name: "Slack", bundleID: "com.tinyspeck.slackmacgap", version: "4.41.96", bytes: gb(0.61),
              lastOpened: Date().addingTimeInterval(-3600), hasUpdate: false, isStartupItem: true,
              uninstallConfidence: 0.94, relatedFiles: related(0.3)),
        .init(name: "Google Chrome", bundleID: "com.google.Chrome", version: "126.0", bytes: gb(1.18),
              lastOpened: Date().addingTimeInterval(-1200), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.90, relatedFiles: related(0.8)),
        .init(name: "Notion", bundleID: "notion.id", version: "3.11.0", bytes: gb(0.74),
              lastOpened: daysAgo(5), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.97, relatedFiles: related(0.4)),
        .init(name: "Sketch", bundleID: "com.bohemiancoding.sketch3", version: "99.1", bytes: gb(0.52),
              lastOpened: daysAgo(142), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.98, relatedFiles: related(0.2)),
        .init(name: "Rectangle", bundleID: "com.knollsoft.Rectangle", version: "0.78", bytes: gb(0.012),
              lastOpened: Date().addingTimeInterval(-3600), hasUpdate: true, isStartupItem: true,
              uninstallConfidence: 0.99, relatedFiles: related(0.01)),
        .init(name: "Spotify", bundleID: "com.spotify.client", version: "1.2.40", bytes: gb(0.39),
              lastOpened: daysAgo(1), hasUpdate: false, isStartupItem: true,
              uninstallConfidence: 0.91, relatedFiles: related(0.5)),
        .init(name: "Final Cut Pro", bundleID: "com.apple.FinalCut", version: "10.8", bytes: gb(4.93),
              lastOpened: daysAgo(210), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.86, relatedFiles: related(2.1)),
        .init(name: "Postman", bundleID: "com.postmanlabs.mac", version: "11.2", bytes: gb(1.31),
              lastOpened: daysAgo(8), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.93, relatedFiles: related(0.7)),
        .init(name: "VLC", bundleID: "org.videolan.vlc", version: "3.0.21", bytes: gb(0.18),
              lastOpened: daysAgo(96), hasUpdate: false, isStartupItem: false,
              uninstallConfidence: 0.99, relatedFiles: related(0.1)),
    ]

    private static func related(_ supportGB: Double) -> [RelatedFile] {
        [.init(path: "~/Library/Application Support", bytes: gb(supportGB), isProtected: false),
         .init(path: "~/Library/Preferences/*.plist", bytes: 12_000, isProtected: false),
         .init(path: "~/Library/Caches", bytes: gb(supportGB * 0.4), isProtected: false)]
    }
    private static let dockerRelated: [RelatedFile] = [
        .init(path: "/Applications/Docker Desktop.app", bytes: gb(2.81), isProtected: false),
        .init(path: "~/Library/Application Support/com.docker.docker", bytes: gb(8.14), isProtected: false),
        .init(path: "~/Library/Preferences/com.docker.docker.plist", bytes: 100_000, isProtected: false),
        .init(path: "~/Library/Containers/com.docker.docker/Data/Docker.raw", bytes: gb(18.6), isProtected: false),
        .init(path: "~/Library/Caches/com.docker.helper", bytes: gb(1.12), isProtected: false),
        .init(path: "~/Library/Group Containers/group.com.docker", bytes: gb(0.34), isProtected: true),
    ]

    // MARK: Optimize

    static let optimizeTasks: [OptimizeTask] = [
        .init(name: "Rebuild Spotlight index", detail: "Fixes slow or missing search results.",
              symbol: "magnifyingglass", safety: .safe, estimatedSeconds: 180, isRecommended: true),
        .init(name: "Flush DNS & refresh network", detail: "Clears stale DNS and resets network stack.",
              symbol: "network", safety: .safe, estimatedSeconds: 10, isRecommended: true),
        .init(name: "Rebuild Launch Services", detail: "Fixes wrong \"Open With\" associations & duplicates.",
              symbol: "square.grid.2x2", safety: .safe, estimatedSeconds: 30, isRecommended: true),
        .init(name: "Rebuild font caches", detail: "Resolves garbled text and font glitches.",
              symbol: "textformat", safety: .review, estimatedSeconds: 20, isRecommended: false),
        .init(name: "Purge inactive memory", detail: "Frees inactive RAM. Apps may briefly slow.",
              symbol: "memorychip", safety: .advanced, estimatedSeconds: 5, isRecommended: false),
    ]

    // MARK: Disk Analyzer

    static let diskRoot: DiskNode = {
        DiskNode(name: "Macintosh HD", bytes: gb(712.3), kind: .system, children: [
            DiskNode(name: "Media", bytes: gb(198.4), kind: .media, children: [
                DiskNode(name: "Photos Library", bytes: gb(96.2), kind: .media),
                DiskNode(name: "Final Cut Projects", bytes: gb(54.1), kind: .media),
                DiskNode(name: "Music", bytes: gb(28.4), kind: .media),
                DiskNode(name: "Downloads/Video", bytes: gb(19.7), kind: .media),
            ]),
            DiskNode(name: "Applications", bytes: gb(142.6), kind: .apps, children: [
                DiskNode(name: "Xcode.app", bytes: gb(14.2), kind: .apps),
                DiskNode(name: "Logic Pro.app", bytes: gb(8.1), kind: .apps),
                DiskNode(name: "Final Cut Pro.app", bytes: gb(4.9), kind: .apps),
                DiskNode(name: "Other apps (84)", bytes: gb(115.4), kind: .apps),
            ]),
            DiskNode(name: "Developer", bytes: gb(121.3), kind: .developer, children: [
                DiskNode(name: "Simulators", bytes: gb(41.2), kind: .developer),
                DiskNode(name: "Docker.raw", bytes: gb(28.6), kind: .developer),
                DiskNode(name: "node_modules", bytes: gb(18.7), kind: .developer),
                DiskNode(name: "DerivedData", bytes: gb(12.4), kind: .caches),
                DiskNode(name: "Other", bytes: gb(20.4), kind: .developer),
            ]),
            DiskNode(name: "System", bytes: gb(96.5), kind: .system, children: [
                DiskNode(name: "Library", bytes: gb(38.2), kind: .system),
                DiskNode(name: "Sleep image", bytes: gb(36.0), kind: .system),
                DiskNode(name: "System", bytes: gb(11.5), kind: .system),
                DiskNode(name: "Other", bytes: gb(10.8), kind: .system),
            ]),
            DiskNode(name: "Documents", bytes: gb(88.1), kind: .documents, children: [
                DiskNode(name: "Projects", bytes: gb(41.0), kind: .documents),
                DiskNode(name: "Archives", bytes: gb(24.8), kind: .documents),
                DiskNode(name: "PDFs", bytes: gb(22.3), kind: .documents),
            ]),
            DiskNode(name: "Caches", bytes: gb(41.7), kind: .caches, children: [
                DiskNode(name: "System", bytes: gb(18.4), kind: .caches),
                DiskNode(name: "Browser", bytes: gb(12.1), kind: .caches),
                DiskNode(name: "App caches", bytes: gb(11.2), kind: .caches),
            ]),
            DiskNode(name: "Other", bytes: gb(23.7), kind: .other, children: [
                DiskNode(name: "Misc", bytes: gb(15.5), kind: .other),
                DiskNode(name: "Mail", bytes: gb(8.2), kind: .other),
            ]),
        ])
    }()

    static let largeFiles: [LargeFile] = [
        .init(name: "Photos Library.photoslibrary", path: "~/Pictures", bytes: gb(96.2), modified: Date(), kind: .media),
        .init(name: "CoreSimulator", path: "~/Library/Developer", bytes: gb(41.2), modified: daysAgo(1), kind: .developer),
        .init(name: "sleepimage", path: "/private/var/vm", bytes: gb(36.0), modified: daysAgo(2), kind: .system),
        .init(name: "Docker.raw", path: "~/Library/Containers/com.docker.docker/Data/vms/0", bytes: gb(28.6), modified: Date(), kind: .developer),
        .init(name: "Final Cut — Reel 2024.fcpbundle", path: "~/Movies/Final Cut", bytes: gb(24.1), modified: daysAgo(87), kind: .media),
        .init(name: "Xcode_16.2.xip", path: "~/Downloads", bytes: gb(9.1), modified: daysAgo(120), kind: .caches),
        .init(name: "GarageBand Library", path: "~/Music/Audio Music Apps", bytes: gb(6.4), modified: daysAgo(210), kind: .media),
        .init(name: "node_modules (legacy-storefront)", path: "~/Code/legacy-storefront", bytes: gb(3.8), modified: daysAgo(210), kind: .developer),
    ]

    // MARK: System Monitor

    static func liveMetrics() -> [LiveMetric] {
        func hist(_ spark: [Double]) -> [MetricSample] {
            spark.enumerated().map { MetricSample(time: Date().addingTimeInterval(Double($0.offset - spark.count)), value: $0.element) }
        }
        return [
            .init(kind: .cpu,         current: 18,   history: hist([22,18,25,40,32,28,19,16,21,18,24,20,17,18]), tint: .nebulaAccent),
            .init(kind: .gpu,         current: 7,    history: hist([4,6,9,12,8,5,7,6,10,7,5,6,8,7]),            tint: .nebulaInfo),
            .init(kind: .memory,      current: 23,   history: hist([20,21,22,24,23,23,22,23,24,23,22,23,23,23]), tint: .nebulaSuccess),
            .init(kind: .disk,        current: 84,   history: hist([10,40,120,90,60,30,84,70,50,90,84,40,60,84]), tint: .nebulaWarning),
            .init(kind: .network,     current: 6,    history: hist([2,4,8,12,6,3,5,7,6,4,6,8,6,6]),             tint: .nebulaInfo),
            .init(kind: .battery,     current: 86,   history: hist([92,91,90,89,88,88,87,87,86,86,86,86,86,86]), tint: .nebulaSuccess),
            .init(kind: .temperature, current: 47,   history: hist([44,45,46,48,50,49,47,46,47,48,47,46,47,47]), tint: .nebulaWarning),
            .init(kind: .fans,        current: 1980, history: hist([1800,1850,1900,2100,2000,1950,1980,1900,1980,2000,1980,1900,1950,1980]), tint: .nebulaAccent),
        ]
    }

    static let processes: [ProcessInsight] = [
        .init(name: "Xcode", cpu: 42.1, memoryBytes: gb(6.8)),
        .init(name: "kernel_task", cpu: 11.4, memoryBytes: gb(2.1)),
        .init(name: "Google Chrome Helper", cpu: 8.9, memoryBytes: gb(3.4)),
        .init(name: "Docker", cpu: 6.2, memoryBytes: gb(4.9)),
        .init(name: "WindowServer", cpu: 5.1, memoryBytes: gb(1.6)),
        .init(name: "Figma", cpu: 3.7, memoryBytes: gb(2.2)),
    ]

    // MARK: Developer Cleanup

    static let devGroups: [DevArtifactGroup] = [
        .init(name: "node_modules", symbol: "shippingbox", bytes: gb(18.7), projectCount: 23, projects: [
            .init(name: "legacy-storefront", path: "~/Code/legacy-storefront", bytes: gb(3.81), lastModified: daysAgo(210)),
            .init(name: "old-prototype-2023", path: "~/Code/old-prototype-2023", bytes: gb(2.64), lastModified: daysAgo(480)),
            .init(name: "api-gateway", path: "~/Code/api-gateway", bytes: gb(2.10), lastModified: daysAgo(12)),
            .init(name: "dashboard-app", path: "~/Code/dashboard-app", bytes: gb(1.42), lastModified: daysAgo(4)),
            .init(name: "marketing-site", path: "~/Code/marketing-site", bytes: gb(0.92), lastModified: daysAgo(156)),
        ]),
        .init(name: "Xcode DerivedData", symbol: "hammer", bytes: gb(12.4), projectCount: 9, projects: [
            .init(name: "Nebula-qf2", path: "~/Library/Developer/Xcode/DerivedData/Nebula-qf2", bytes: gb(5.22), lastModified: daysAgo(118)),
            .init(name: "Mole-abx", path: "~/Library/Developer/Xcode/DerivedData/Mole-abx", bytes: gb(4.10), lastModified: Date()),
            .init(name: "SideProj-kk1", path: "~/Library/Developer/Xcode/DerivedData/SideProj-kk1", bytes: gb(3.08), lastModified: daysAgo(92)),
        ]),
        .init(name: "Docker layers", symbol: "cube.box", bytes: gb(4.9), projectCount: 38, projects: [
            .init(name: "Dangling image layers", path: "Dangling image layers", bytes: gb(3.10), lastModified: daysAgo(60)),
            .init(name: "Stopped container volumes", path: "Stopped container volumes", bytes: gb(1.80), lastModified: daysAgo(140)),
        ]),
        .init(name: "build / dist", symbol: "folder", bytes: gb(2.2), projectCount: 17, projects: [
            .init(name: "legacy-storefront/build", path: "~/Code/legacy-storefront/build", bytes: gb(1.12), lastModified: daysAgo(210)),
            .init(name: "docs-site/.next", path: "~/Code/docs-site/.next", bytes: gb(0.67), lastModified: daysAgo(33)),
            .init(name: "dashboard-app/dist", path: "~/Code/dashboard-app/dist", bytes: gb(0.41), lastModified: daysAgo(4)),
        ]),
    ]

    static var devTotalBytes: Int64 { devGroups.reduce(0) { $0 + $1.bytes } }

    // MARK: Dashboard storage breakdown (design order/values)
    static let storageBreakdown: [StorageSegment] = [
        .init(label: "Applications", bytes: gb(142.6), color: .catApps),
        .init(label: "Media",        bytes: gb(198.4), color: .catMedia),
        .init(label: "Documents",    bytes: gb(88.1),  color: .catDocs),
        .init(label: "Developer",    bytes: gb(121.3), color: .catDev),
        .init(label: "System",       bytes: gb(96.5),  color: .catSystem),
        .init(label: "Caches",       bytes: gb(41.7),  color: .catCaches),
        .init(label: "Other",        bytes: gb(23.7),  color: .catOther),
    ]
}
