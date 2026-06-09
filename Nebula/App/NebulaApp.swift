//
//  NebulaApp.swift
//  Nebula — app entry. Three scenes: main window, menu-bar popover, settings.
//

import SwiftUI

@main
struct NebulaApp: App {
    @State private var app = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(app)
                .tint(.nebulaAccent)
                .frame(minWidth: 980, minHeight: 640)
        }
        .defaultSize(width: 1180, height: 780)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentMinSize)
        .commands { NebulaCommands(app: app) }

        #if os(macOS)
        MenuBarExtra("Mole", systemImage: "m.circle.fill") {
            MenuBarView()
                .environment(app)
                .tint(.nebulaAccent)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environment(app)
        }
        #endif
    }
}

/// Global menu-bar commands. Everything reachable by keyboard, per HIG.
struct NebulaCommands: Commands {
    let app: AppState

    var body: some Commands {
        CommandGroup(after: .toolbar) {
            Button("Command Palette") {
                withAnimation(Motion.snappy) { app.showCommandPalette.toggle() }
            }
            .keyboardShortcut("k", modifiers: .command)
        }
        CommandMenu("Actions") {
            Button("Smart Clean") { app.navigate(to: .smartClean) }
                .keyboardShortcut("1", modifiers: .command)
            Button("Disk Analyzer") { app.navigate(to: .diskAnalyzer) }
                .keyboardShortcut("2", modifiers: .command)
            Button("Optimize") { app.navigate(to: .optimize) }
                .keyboardShortcut("3", modifiers: .command)
            Button("System Monitor") { app.navigate(to: .systemMonitor) }
                .keyboardShortcut("4", modifiers: .command)
            Divider()
            Button("Run Quick Clean") {
                app.navigate(to: .smartClean)
                app.simulateCleanScan()
            }
            .keyboardShortcut("r", modifiers: [.command, .shift])
        }
    }
}
