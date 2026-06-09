//
//  CLISetupView.swift
//  Mole — shown when the Mole engine (CLI) isn't installed.
//
//  Detects the engine, installs it via Homebrew with one click, and offers
//  download / copy-command fallbacks. Once installed, the app proceeds to the
//  workspace and (because detection is real) never prompts again.
//

import SwiftUI
import AppKit

struct CLISetupView: View {
    @Environment(AppState.self) private var app
    @Environment(\.openURL) private var openURL
    @State private var copied = false

    var body: some View {
        ZStack {
            Color.nebulaWindowBg.ignoresSafeArea()
            content
                .frame(maxWidth: 520)
                .padding(Spacing.xxxl)
        }
        .onAppear {
            if case .checking = app.cliState { app.checkCLI() }
        }
    }

    @ViewBuilder private var content: some View {
        switch app.cliState {
        case .checking:   checking
        case .installing: installing
        case .missing, .installed: missing   // .installed shows briefly until RootView swaps
        }
    }

    // MARK: Checking

    private var checking: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView().controlSize(.large)
            Text("Checking for the Mole engine…")
                .font(.nebulaSection).foregroundStyle(.nebulaText2)
        }
    }

    // MARK: Installing

    private var installing: some View {
        VStack(spacing: Spacing.lg) {
            BrandTile(size: 72, corner: 18)
            ProgressView().controlSize(.large)
            Text("Installing the Mole engine…").font(.nebulaSection)
            Text("Running `\(MoleCLI.homebrewCommand)` — this can take a minute.")
                .font(.nebulaBody).foregroundStyle(.nebulaText2).multilineTextAlignment(.center)
            if !app.installLog.isEmpty {
                Text(app.installLog)
                    .font(.nebulaMono).foregroundStyle(.nebulaText3)
                    .lineLimit(1).truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.md).padding(.vertical, Spacing.sm)
                    .background(Color.nebulaSurface3, in: .rect(cornerRadius: Radius.md))
            }
        }
    }

    // MARK: Missing — the install screen

    private var missing: some View {
        VStack(spacing: Spacing.lg) {
            BrandTile(size: 84, corner: 22)

            VStack(spacing: Spacing.sm) {
                Text("Install the Mole engine").font(.nebulaTitle).tracking(-0.5)
                Text("Mole's app is a friendly front-end for the open-source **Mole** command-line engine. Install it once and Mole handles the rest — no Terminal required.")
                    .font(.nebulaBody).foregroundStyle(.nebulaText2)
                    .multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }

            if app.installFailed {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.nebulaWarning)
                    Text("Automatic install didn't finish — Homebrew may not be installed. Use **Download** or run the command in Terminal.")
                        .font(.nebulaCaption).foregroundStyle(.nebulaText2)
                }
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.nebulaWarning.opacity(0.14), in: .rect(cornerRadius: Radius.md))
            }

            // Primary one-click install (real, via Homebrew)
            Button {
                app.installCLI()
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "arrow.down.circle.fill")
                    Text("Install Mole engine")
                }
                .font(.nebulaCallout)
                .frame(maxWidth: .infinity).frame(height: 44)
                .foregroundStyle(.white)
                .background(LinearGradient.nebulaGradient, in: .rect(cornerRadius: Radius.lg))
            }
            .buttonStyle(.plain)

            // Fallbacks
            HStack(spacing: Spacing.sm) {
                Button { openURL(MoleCLI.releasesURL) } label: {
                    Label("Download from GitHub", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity).frame(height: 36)
                }
                .buttonStyle(.bordered)

                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(MoleCLI.homebrewCommand, forType: .string)
                    withAnimation { copied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) { withAnimation { copied = false } }
                } label: {
                    Label(copied ? "Copied!" : "Copy command",
                          systemImage: copied ? "checkmark" : "doc.on.doc")
                        .frame(maxWidth: .infinity).frame(height: 36)
                }
                .buttonStyle(.bordered)
            }

            Text(MoleCLI.homebrewCommand)
                .font(.nebulaMono).foregroundStyle(.nebulaText2)
                .padding(.horizontal, Spacing.md).padding(.vertical, Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.nebulaSurface3, in: .rect(cornerRadius: Radius.md))

            HStack(spacing: Spacing.lg) {
                Button("Recheck") { app.checkCLI() }
                    .buttonStyle(.plain).font(.nebulaCallout).foregroundStyle(.nebulaAccent)
                Button("Continue in demo mode →") { withAnimation(Motion.snappy) { app.cliDemoMode = true } }
                    .buttonStyle(.plain).font(.nebulaCallout).foregroundStyle(.nebulaText3)
            }
            .padding(.top, Spacing.xs)
        }
    }
}

#Preview { CLISetupView().environment(AppState()).frame(width: 900, height: 700) }
