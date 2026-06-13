//
//  SystemData.swift
//  Mole — live system data provider
//
//  Real data via Foundation (disk, apps, caches, projects) and the Mole engine
//  (`mo status --json`). Everything is defensive: any source that fails returns
//  nil/empty, and AppState keeps the sample values as a fallback.
//
//  All scans are meant to run off the main thread.
//

import Foundation
import AppKit

enum SystemData {

    private static let fm = FileManager.default
    private static var home: URL { fm.homeDirectoryForCurrentUser }
    private static func gbInt(_ v: Double) -> Int64 { Int64(v * 1_000_000_000) }

    // MARK: Disk capacity

    /// (free, total) bytes for the boot volume.
    static func diskCapacity() -> (free: Int64, total: Int64)? {
        let url = URL(fileURLWithPath: "/")
        guard let v = try? url.resourceValues(forKeys: [
            .volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey
        ]) else { return nil }
        let free = Int64(v.volumeAvailableCapacityForImportantUsage ?? 0)
        let total = Int64(v.volumeTotalCapacity ?? 0)
        guard total > 0 else { return nil }
        return (free, total)
    }

    // MARK: Directory sizing

    /// Recursive allocated size of a directory (skips errors). Bounded by `maxEntries`.
    static func directorySize(_ url: URL, maxEntries: Int = 200_000) -> Int64 {
        guard let en = fm.enumerator(at: url,
                                     includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
                                     options: [.skipsHiddenFiles], errorHandler: { _, _ in true }) else { return 0 }
        var total: Int64 = 0
        var count = 0
        for case let f as URL in en {
            count += 1
            if count > maxEntries { break }
            let vals = try? f.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            total += Int64(vals?.totalFileAllocatedSize ?? vals?.fileAllocatedSize ?? 0)
        }
        return total
    }

    private static func exists(_ url: URL) -> Bool { fm.fileExists(atPath: url.path) }

    // MARK: Installed applications

    static func installedApps() -> [InstalledApp] {
        let dirs = [URL(fileURLWithPath: "/Applications"), home.appendingPathComponent("Applications")]
        var apps: [InstalledApp] = []
        for dir in dirs {
            guard let items = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.contentAccessDateKey],
                                                          options: [.skipsHiddenFiles]) else { continue }
            for url in items where url.pathExtension == "app" {
                guard let bundle = Bundle(url: url) else { continue }
                let info = bundle.infoDictionary ?? [:]
                let name = (fm.displayName(atPath: url.path) as String).replacingOccurrences(of: ".app", with: "")
                let bundleID = bundle.bundleIdentifier ?? (info["CFBundleIdentifier"] as? String ?? "unknown")
                let version = (info["CFBundleShortVersionString"] as? String) ?? (info["CFBundleVersion"] as? String) ?? "—"
                let size = directorySize(url, maxEntries: 60_000)
                let opened = (try? url.resourceValues(forKeys: [.contentAccessDateKey]))?.contentAccessDate
                let related = relatedFiles(forBundleID: bundleID, name: name)
                let conf = related.contains { $0.isProtected } ? 0.78 : 0.95
                apps.append(InstalledApp(
                    name: name, bundleID: bundleID, version: version, bytes: size,
                    lastOpened: opened, hasUpdate: false, isStartupItem: false,
                    uninstallConfidence: conf, relatedFiles: related))
            }
        }
        return apps.sorted { $0.bytes > $1.bytes }
    }

    private static func relatedFiles(forBundleID id: String, name: String) -> [RelatedFile] {
        let lib = home.appendingPathComponent("Library")
        let candidates: [(String, Bool)] = [
            ("Application Support/\(name)", false),
            ("Caches/\(id)", false),
            ("Preferences/\(id).plist", false),
            ("Logs/\(name)", false),
            ("Containers/\(id)", false),
            ("Group Containers/group.\(id)", true),
        ]
        var files: [RelatedFile] = []
        for (rel, prot) in candidates {
            let url = lib.appendingPathComponent(rel)
            guard exists(url) else { continue }
            let size = url.pathExtension == "plist"
                ? Int64((try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                : directorySize(url, maxEntries: 20_000)
            files.append(RelatedFile(path: "~/Library/\(rel)", bytes: size, isProtected: prot))
        }
        return files
    }

    // MARK: Smart Clean categories (sizes of known junk locations)

    static func cleanCategories() -> [CleanCategory] {
        let lib = home.appendingPathComponent("Library")
        func size(_ rel: String, base: URL) -> Int64 {
            let u = base.appendingPathComponent(rel); return exists(u) ? directorySize(u) : 0
        }
        let systemCaches = size("Caches", base: lib)
        let browser = ["Caches/Google/Chrome", "Caches/com.apple.Safari", "Caches/Firefox", "Caches/com.microsoft.edgemac"]
            .reduce(Int64(0)) { $0 + size($1, base: lib) }
        let logs = size("Logs", base: lib)
        let trash = directorySize(home.appendingPathComponent(".Trash"))
        let xcode = ["Developer/Xcode/DerivedData", "Developer/Xcode/iOS DeviceSupport", "Developer/Xcode/Archives"]
            .reduce(Int64(0)) { $0 + size($1, base: lib) }
        let installers = installerFilesSize()

        func cat(_ name: String, _ symbol: String, _ bytes: Int64, _ safety: SafetyLevel,
                 _ trashRoute: Bool, _ paths: [String]) -> CleanCategory {
            CleanCategory(name: name, symbol: symbol, bytes: bytes, itemCount: 0,
                          safety: safety, routesToTrash: trashRoute, samplePaths: paths)
        }
        return [
            cat("System caches", "cpu", max(0, systemCaches - browser), .safe, true, ["~/Library/Caches"]),
            cat("Browser caches", "globe", browser, .safe, true, ["~/Library/Caches/Google/Chrome", "~/Library/Caches/com.apple.Safari"]),
            cat("Logs & diagnostics", "doc.text", logs, .safe, true, ["~/Library/Logs"]),
            cat("Trash", "trash", trash, .safe, false, ["~/.Trash"]),
            cat("Xcode junk", "hammer", xcode, .review, true, ["~/Library/Developer/Xcode/DerivedData"]),
            cat("Installer files", "shippingbox", installers, .review, true, ["~/Downloads/*.dmg", "~/Downloads/*.pkg"]),
        ].filter { $0.bytes > 0 }
    }

    private static func installerFilesSize() -> Int64 {
        let dl = home.appendingPathComponent("Downloads")
        guard let items = try? fm.contentsOfDirectory(at: dl, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
        let exts: Set<String> = ["dmg", "pkg", "xip"]
        return items.filter { exts.contains($0.pathExtension.lowercased()) }
            .reduce(Int64(0)) { $0 + Int64((try? $1.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0) }
    }

    // MARK: Developer artifacts

    static func devGroups() -> [DevArtifactGroup] {
        let roots = ["Projects", "dev", "Developer", "GitHub", "Code", "Documents"]
            .map { home.appendingPathComponent($0) }.filter { exists($0) }
        var byType: [String: (symbol: String, projects: [DevProject])] = [
            "node_modules": ("shippingbox", []), "build / dist": ("folder", []), "target / .build": ("hammer", [])
        ]
        let artifactMap: [(dir: String, group: String)] = [
            ("node_modules", "node_modules"), ("build", "build / dist"), ("dist", "build / dist"),
            (".next", "build / dist"), ("target", "target / .build"), (".build", "target / .build"),
        ]
        for root in roots {
            guard let projects = try? fm.contentsOfDirectory(at: root, includingPropertiesForKeys: nil,
                                                              options: [.skipsHiddenFiles]) else { continue }
            for proj in projects {
                for art in artifactMap {
                    let artURL = proj.appendingPathComponent(art.dir)
                    guard exists(artURL) else { continue }
                    let size = directorySize(artURL, maxEntries: 50_000)
                    guard size > 0 else { continue }
                    let mod = (try? artURL.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date()
                    byType[art.group]?.projects.append(
                        DevProject(name: proj.lastPathComponent, path: "~/\(root.lastPathComponent)/\(proj.lastPathComponent)/\(art.dir)",
                                   bytes: size, lastModified: mod))
                }
            }
        }
        return byType.compactMap { name, v in
            guard !v.projects.isEmpty else { return nil }
            let total = v.projects.reduce(Int64(0)) { $0 + $1.bytes }
            return DevArtifactGroup(name: name, symbol: v.symbol, bytes: total,
                                    projectCount: v.projects.count, projects: v.projects.sorted { $0.bytes > $1.bytes })
        }.sorted { $0.bytes > $1.bytes }
    }

    // MARK: Storage breakdown + tree

    static func storageBreakdown() -> (segments: [StorageSegment], free: Int64, total: Int64)? {
        guard let cap = diskCapacity() else { return nil }
        let lib = home.appendingPathComponent("Library")
        let apps = directorySize(URL(fileURLWithPath: "/Applications"), maxEntries: 120_000)
        let media = ["Movies", "Music", "Pictures"].reduce(Int64(0)) { $0 + directorySize(home.appendingPathComponent($1)) }
        let docs = directorySize(home.appendingPathComponent("Documents"))
        let dev = directorySize(lib.appendingPathComponent("Developer"), maxEntries: 120_000)
        let caches = directorySize(lib.appendingPathComponent("Caches"))
        let used = cap.total - cap.free
        let measured = apps + media + docs + dev + caches
        let other = max(0, used - measured)
        let segs: [StorageSegment] = [
            .init(label: "Applications", bytes: apps, color: .catApps),
            .init(label: "Media", bytes: media, color: .catMedia),
            .init(label: "Documents", bytes: docs, color: .catDocs),
            .init(label: "Developer", bytes: dev, color: .catDev),
            .init(label: "Caches", bytes: caches, color: .catCaches),
            .init(label: "Other", bytes: other, color: .catOther),
        ].filter { $0.bytes > 0 }
        return (segs, cap.free, cap.total)
    }

    static func diskTree(from segments: [StorageSegment], total: Int64) -> DiskNode {
        let kindFor: (String) -> DiskKind = {
            switch $0 {
            case "Applications": .apps; case "Media": .media; case "Documents": .documents
            case "Developer": .developer; case "Caches": .caches; default: .other
            }
        }
        let children = segments.map { DiskNode(name: $0.label, bytes: $0.bytes, kind: kindFor($0.label)) }
        return DiskNode(name: "Macintosh HD", bytes: segments.reduce(0) { $0 + $1.bytes }, kind: .system, children: children)
    }

    // MARK: Large files

    static func largeFiles(minBytes: Int64 = 1_000_000_000, limit: Int = 12) -> [LargeFile] {
        let roots = ["Downloads", "Movies", "Documents", "Desktop", "Library/Developer"]
            .map { home.appendingPathComponent($0) }.filter { exists($0) }
        var found: [LargeFile] = []
        for root in roots {
            guard let en = fm.enumerator(at: root, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey],
                                         options: [.skipsHiddenFiles], errorHandler: { _, _ in true }) else { continue }
            var seen = 0
            for case let f as URL in en {
                seen += 1; if seen > 80_000 { break }
                let v = try? f.resourceValues(forKeys: [.fileSizeKey, .contentModificationDateKey, .isRegularFileKey])
                guard v?.isRegularFile == true, let sz = v?.fileSize, Int64(sz) >= minBytes else { continue }
                found.append(LargeFile(name: f.lastPathComponent, path: f.deletingLastPathComponent().path,
                                       bytes: Int64(sz), modified: v?.contentModificationDate ?? Date(), kind: .other))
            }
        }
        return Array(found.sorted { $0.bytes > $1.bytes }.prefix(limit))
    }

    // MARK: Live status via the Mole engine (`mo status --json`)

    struct StatusSnapshot {
        var health: Int?
        var cpu: Double?
        var memoryPercent: Double?
        var diskPercent: Double?
    }

    static func engineStatus() -> StatusSnapshot? {
        let result = MoleCLI.runShell("mo status --json")
        guard result.code == 0, let data = result.output.data(using: .utf8) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        var snap = StatusSnapshot()
        snap.health = json["health_score"] as? Int
        if let cpu = json["cpu"] as? [String: Any] { snap.cpu = cpu["usage"] as? Double }
        if let mem = json["memory"] as? [String: Any] { snap.memoryPercent = mem["used_percent"] as? Double }
        if let disks = json["disks"] as? [[String: Any]], let first = disks.first {
            snap.diskPercent = (first["used_percent"] as? Double) ?? (first["usedPercent"] as? Double)
        }
        return snap
    }
}
