//
//  CommandPalette.swift
//  Nebula — ⌘K fuzzy navigation/action accelerator (Raycast-style overlay).
//

import SwiftUI

struct CommandPalette: View {
    @Environment(AppState.self) private var app
    @Environment(\.openSettings) private var openSettings
    @State private var query = ""
    @FocusState private var fieldFocused: Bool

    private var results: [PaletteCommand] {
        let all = app.paletteCommands
        guard !query.isEmpty else { return all }
        return all.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search screens and actions…", text: $query)
                    .textFieldStyle(.plain)
                    .font(.nebulaSection)
                    .focused($fieldFocused)
                    .onSubmit { run(results.first) }
                Text("esc").nebulaCaptionStyle()
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.nebulaHairlineStrong, in: .rect(cornerRadius: 5))
            }
            .padding(Spacing.lg)

            Divider()

            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(results) { cmd in
                        Button { run(cmd) } label: {
                            HStack(spacing: Spacing.md) {
                                Image(systemName: cmd.symbol)
                                    .frame(width: 22)
                                    .foregroundStyle(.tint)
                                Text(cmd.title).font(.nebulaBody)
                                Spacer()
                                if cmd.destination != nil {
                                    Image(systemName: "arrow.turn.down.left")
                                        .font(.system(size: 10)).foregroundStyle(.tertiary)
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                    if results.isEmpty {
                        Text("No matches").nebulaCaptionStyle().padding(Spacing.lg)
                    }
                }
                .padding(Spacing.sm)
            }
            .frame(maxHeight: 320)
        }
        .frame(width: 560)
        .floatingSurface()
        .onAppear { fieldFocused = true }
        .onExitCommand { close() }
    }

    private func run(_ cmd: PaletteCommand?) {
        guard let cmd else { return }
        if let dest = cmd.destination {
            app.navigate(to: dest)
        } else {
            openSettings()
        }
        close()
    }

    private func close() {
        withAnimation(Motion.snappy) { app.showCommandPalette = false }
        query = ""
    }
}
