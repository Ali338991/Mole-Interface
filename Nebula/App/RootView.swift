//
//  RootView.swift
//  Nebula — hybrid sidebar + workspace shell, with the ⌘K palette overlaid.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        Group {
            if !app.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else if app.cliReady {
                workspace
            } else {
                CLISetupView()
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(app.appearance)
        .animation(Motion.snappy, value: app.hasCompletedOnboarding)
        .animation(Motion.snappy, value: app.cliReady)
    }

    private var workspace: some View {
        NavigationSplitView {
            Sidebar()
        } detail: {
            DetailRouter(destination: app.destination)
                .frame(minWidth: 760)
                .navigationTitle(app.destination.title)
                .navigationSubtitle(app.destination.subtitle)
                .toolbar { globalToolbar }
        }
        .navigationSplitViewStyle(.balanced)
        .overlay(alignment: .top) { paletteOverlay }
    }

    @ToolbarContentBuilder private var globalToolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button { withAnimation(Motion.snappy) { app.showCommandPalette = true } } label: {
                Image(systemName: "magnifyingglass")
            }
            .help("Search (⌘K)")
        }
        ToolbarItem(placement: .primaryAction) {
            Button { app.toggleAppearance() } label: {
                Image(systemName: app.appearance == .light ? "moon" : "sun.max")
            }
            .help("Toggle appearance")
        }
    }

    @ViewBuilder private var paletteOverlay: some View {
        if app.showCommandPalette {
            ZStack(alignment: .top) {
                Color.black.opacity(0.12)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(Motion.snappy) { app.showCommandPalette = false } }
                CommandPalette()
                    .padding(.top, 90)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            .zIndex(10)
        }
    }
}

/// Maps the current destination to its feature view. Cross-fades between screens.
struct DetailRouter: View {
    let destination: Destination

    var body: some View {
        ZStack {
            switch destination {
            case .dashboard:        DashboardView()
            case .smartClean:       SmartCleanView()
            case .applications:     ApplicationsView()
            case .optimize:         OptimizeView()
            case .diskAnalyzer:     DiskAnalyzerView()
            case .systemMonitor:    SystemMonitorView()
            case .developerCleanup: DeveloperCleanupView()
            }
        }
        .id(destination)
        .transition(.opacity.combined(with: .offset(y: 8)))
    }
}
