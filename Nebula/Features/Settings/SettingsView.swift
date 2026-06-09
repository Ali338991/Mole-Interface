//
//  SettingsView.swift
//  Nebula — preferences (⌘,). Tabbed, @AppStorage-backed.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") { GeneralSettings() }
            Tab("Scan", systemImage: "sparkle.magnifyingglass") { ScanSettings() }
            Tab("Safety", systemImage: "checkmark.shield") { SafetySettings() }
            Tab("Menu Bar", systemImage: "menubar.rectangle") { MenuBarSettings() }
            Tab("About", systemImage: "info.circle") { AboutSettings() }
        }
        .scenePadding()
        .frame(width: 480, height: 360)
    }
}

private struct GeneralSettings: View {
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    var body: some View {
        Form {
            Picker("Appearance", selection: $appearance) {
                Text("System").tag("system"); Text("Light").tag("light"); Text("Dark").tag("dark")
            }
            Toggle("Launch Mole at login", isOn: $launchAtLogin)
        }
        .formStyle(.grouped)
    }
}

private struct ScanSettings: View {
    @AppStorage("includeDeveloperJunk") private var includeDev = true
    @AppStorage("includeBrowserCaches") private var includeBrowser = true
    @AppStorage("schedule") private var schedule = "weekly"
    var body: some View {
        Form {
            Section("Include in scans") {
                Toggle("Developer junk (Xcode, node_modules, Docker)", isOn: $includeDev)
                Toggle("Browser caches", isOn: $includeBrowser)
            }
            Section("Automatic scans") {
                Picker("Schedule", selection: $schedule) {
                    Text("Off").tag("off"); Text("Daily").tag("daily"); Text("Weekly").tag("weekly")
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct SafetySettings: View {
    @AppStorage("alwaysTrash") private var alwaysTrash = true
    @AppStorage("dryRunDefault") private var dryRunDefault = false
    @AppStorage("confirmDestructive") private var confirmDestructive = true
    var body: some View {
        Form {
            Section {
                Toggle("Always route removals to Trash (recoverable)", isOn: $alwaysTrash)
                Toggle("Start cleans in dry-run mode", isOn: $dryRunDefault)
                Toggle("Confirm before permanent removal", isOn: $confirmDestructive)
            } footer: {
                Text("Protected system paths are always excluded and cannot be cleaned.")
                    .nebulaCaptionStyle()
            }
        }
        .formStyle(.grouped)
    }
}

private struct MenuBarSettings: View {
    @AppStorage("menuBarMetrics") private var metrics = "cpu,memory,disk,temp"
    @AppStorage("menuRefresh") private var refresh = 1.0
    var body: some View {
        Form {
            Text("Shown metrics: CPU, Memory, Disk, Temperature").nebulaCaptionStyle()
            Slider(value: $refresh, in: 0.5...5, step: 0.5) { Text("Refresh interval") }
            Text("\(refresh, specifier: "%.1f")s").nebulaCaptionStyle().nebulaNumeric()
        }
        .formStyle(.grouped)
    }
}

private struct AboutSettings: View {
    var body: some View {
        VStack(spacing: Spacing.sm) {
            BrandTile(size: 56, corner: 14)
            Text("Mole").font(.nebulaSection)
            Text("Version 1.0 (build 1)").nebulaCaptionStyle()
            Text("A native macOS reimagining of the open-source Mole CLI.")
                .nebulaCaptionStyle().multilineTextAlignment(.center)
            Link("github.com/tw93/mole", destination: URL(string: "https://github.com/tw93/mole")!)
                .font(.nebulaCaption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview { SettingsView() }
