//
//  MoleCLI.swift
//  Mole — engine (CLI) detection + install
//
//  The app is a front-end for the open-source Mole engine (binary: `mo`).
//  This type detects an existing install and installs it via Homebrew.
//
//  Note: the app is NOT sandboxed, so it can run /bin/zsh as a login shell to
//  pick up the user's PATH (including Homebrew) and run installs.
//

import Foundation

enum MoleCLI {
    static let repoURL     = URL(string: "https://github.com/tw93/mole")!
    static let releasesURL = URL(string: "https://github.com/tw93/mole/releases")!

    /// Official install methods (see github.com/tw93/mole).
    static let homebrewCommand = "brew install mole"
    static let scriptCommand   = "curl -fsSL https://raw.githubusercontent.com/tw93/mole/main/install.sh | bash"

    /// Locations checked to detect an existing `mo` install.
    static let knownBinaryPaths = ["/opt/homebrew/bin/mo", "/usr/local/bin/mo"]

    /// True if the `mo` binary is on the system.
    static func isInstalled() -> Bool {
        if knownBinaryPaths.contains(where: { FileManager.default.isExecutableFile(atPath: $0) }) {
            return true
        }
        return runShell("command -v mo").code == 0
    }

    /// Installs the engine via Homebrew, streaming output lines. Returns true
    /// only if the binary is present afterward.
    @discardableResult
    static func runInstall(onOutput: @escaping (String) -> Void) -> Bool {
        let result = runShellStreaming(homebrewCommand, onOutput: onOutput)
        return result.code == 0 && isInstalled()
    }

    // MARK: - Process helpers

    private static func loginShell(_ command: String) -> Process {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/zsh")
        // Login shell + explicit Homebrew paths so PATH is complete when
        // launched from Finder.
        p.arguments = ["-lc", "export PATH=\"/opt/homebrew/bin:/usr/local/bin:$PATH\"; \(command)"]
        return p
    }

    static func runShell(_ command: String) -> (code: Int32, output: String) {
        let proc = loginShell(command)
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = pipe
        do { try proc.run() } catch { return (-1, "\(error)") }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        proc.waitUntilExit()
        return (proc.terminationStatus, String(data: data, encoding: .utf8) ?? "")
    }

    static func runShellStreaming(_ command: String,
                                  onOutput: @escaping (String) -> Void) -> (code: Int32, output: String) {
        let proc = loginShell(command)
        let pipe = Pipe()
        proc.standardOutput = pipe
        proc.standardError = pipe
        var full = ""
        let handle = pipe.fileHandleForReading
        handle.readabilityHandler = { fh in
            let d = fh.availableData
            guard !d.isEmpty, let s = String(data: d, encoding: .utf8) else { return }
            full += s
            let last = s.split(whereSeparator: \.isNewline).last.map(String.init) ?? s
            let line = last.trimmingCharacters(in: .whitespacesAndNewlines)
            if !line.isEmpty { DispatchQueue.main.async { onOutput(line) } }
        }
        do { try proc.run() } catch { return (-1, "\(error)") }
        proc.waitUntilExit()
        handle.readabilityHandler = nil
        return (proc.terminationStatus, full)
    }
}
