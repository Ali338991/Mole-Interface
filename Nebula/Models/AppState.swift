//
//  AppState.swift
//  Nebula — Global observable state
//
//  Single @Observable store injected into the environment. Owns navigation,
//  scan/clean phase, the health score, and demo data. View-local ephemeral
//  state stays in each view; this is only for cross-screen state.
//

import SwiftUI
import Observation

/// Phase shared by scan-then-act flows (Clean, Optimize, Developer Cleanup).
enum WorkPhase: Equatable {
    case idle
    case scanning(progress: Double)
    case results
    case working(progress: Double)
    case complete(bytesFreed: Int64)
}

@Observable
final class AppState {

    // MARK: Navigation
    var destination: Destination = .dashboard
    var showCommandPalette = false
    var hasCompletedOnboarding = false

    // MARK: Appearance — design leads light, with a toolbar toggle.
    var appearance: ColorScheme = .light
    func toggleAppearance() {
        withAnimation(Motion.smooth) { appearance = (appearance == .light) ? .dark : .light }
    }

    // MARK: Mole engine (CLI) status
    //
    // The app is a front-end for the Mole command-line engine. On first launch
    // we detect whether it's installed; if not, the CLI setup screen guides the
    // user to install it with one click before the workspace appears.
    enum CLIState: Equatable { case checking, missing, installing, installed }
    var cliState: CLIState = .checking
    /// Live output from the installer.
    var installLog = ""
    /// Set when an automatic install attempt failed (e.g. Homebrew missing).
    var installFailed = false
    /// Lets the user explore the UI on mock data without the engine present.
    var cliDemoMode = false
    var cliReady: Bool {
        if case .installed = cliState { return true }
        return cliDemoMode
    }

    /// Detects a real `mo` install on a background queue. Because this checks
    /// the actual system, an already-installed engine is found on every launch
    /// and the setup screen never reappears.
    func checkCLI() {
        cliState = .checking
        DispatchQueue.global(qos: .userInitiated).async {
            let found = MoleCLI.isInstalled()
            DispatchQueue.main.async {
                withAnimation(Motion.smooth) { self.cliState = found ? .installed : .missing }
            }
        }
    }

    /// Installs the engine for real via Homebrew. On success the install
    /// persists, so subsequent launches skip the setup screen.
    func installCLI() {
        installFailed = false
        installLog = "Starting install…"
        cliState = .installing
        DispatchQueue.global(qos: .userInitiated).async {
            let ok = MoleCLI.runInstall { line in self.installLog = line }
            DispatchQueue.main.async {
                withAnimation(Motion.smooth) {
                    if ok {
                        self.cliState = .installed
                    } else {
                        self.cliState = .missing
                        self.installFailed = true
                    }
                }
            }
        }
    }

    // MARK: Health
    /// 0...100 system health. Recomputed after clean/optimize.
    var healthScore: Int = 92

    // MARK: Smart Clean
    var cleanPhase: WorkPhase = .idle
    var cleanCategories: [CleanCategory] = MockData.cleanCategories

    // MARK: Optimize
    var optimizePhase: WorkPhase = .idle

    // MARK: Developer Cleanup
    var devPhase: WorkPhase = .idle

    // MARK: Convenience
    var reclaimableBytes: Int64 { MockData.cleanTotalBytes }
    var freeDiskBytes: Int64 = 282_400_000_000
    var totalDiskBytes: Int64 = 994_700_000_000
    var appsWithUpdates: Int { MockData.apps.filter(\.hasUpdate).count }

    var paletteCommands: [PaletteCommand] {
        Destination.allCases.map { PaletteCommand(title: $0.title, symbol: $0.symbol, destination: $0) }
        + [
            PaletteCommand(title: "Run Quick Clean", symbol: "sparkles", destination: .smartClean),
            PaletteCommand(title: "Run Maintenance", symbol: "wand.and.stars", destination: .optimize),
            PaletteCommand(title: "Open Settings", symbol: "gearshape", destination: nil),
        ]
    }

    // MARK: Simulated work
    //
    // INTEGRATION: replace these timers with real Mole CLI / system calls.
    // Each respects the dry-run / Trash-routing contract described in
    // DESIGN_SPEC.md §1.2 and Mole's safety rules.

    func navigate(to destination: Destination) {
        withAnimation(Motion.snappy) { self.destination = destination }
    }

    func simulateCleanScan() {
        cleanPhase = .scanning(progress: 0)
        ramp { p in self.cleanPhase = .scanning(progress: p) } completion: {
            self.cleanPhase = .results
        }
    }

    func simulateClean(freeing bytes: Int64) {
        cleanPhase = .working(progress: 0)
        ramp { p in self.cleanPhase = .working(progress: p) } completion: {
            withAnimation(Motion.smooth) {
                self.cleanPhase = .complete(bytesFreed: bytes)
                self.healthScore = min(100, self.healthScore + 14)
                self.freeDiskBytes += bytes
            }
        }
    }

    func resetClean() { cleanPhase = .idle }

    /// Simple progress ramp on the main actor for demo purposes.
    private func ramp(step: @escaping (Double) -> Void, completion: @escaping () -> Void) {
        var p = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            p += 0.02
            if p >= 1 {
                timer.invalidate()
                step(1)
                completion()
            } else {
                step(p)
            }
        }
    }
}
