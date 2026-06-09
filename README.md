<div align="center">

# Mole

**A premium, native macOS app for cleaning, optimizing, and understanding your Mac.**

A SwiftUI reimagining of the open-source [Mole](https://github.com/tw93/mole) CLI as a polished desktop product.

![Platform](https://img.shields.io/badge/platform-macOS%2015%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![UI](https://img.shields.io/badge/UI-SwiftUI-2396F3)
![License](https://img.shields.io/badge/license-MIT-green)
[![CI](https://github.com/Ali338991/Mole-Interface/actions/workflows/ci.yml/badge.svg)](https://github.com/Ali338991/Mole-Interface/actions/workflows/ci.yml)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## What is Mole?

Mole keeps a Mac clean, fast, and legible — it reclaims wasted space, removes apps completely, runs system maintenance, visualizes where storage went, and monitors live system health, all from one calm, native app.

It's a SwiftUI front-end built on the feature set of the [Mole CLI](https://github.com/tw93/mole), designed to feel like a piece of Apple's own software.

> **Status: design / UI preview.** This is a UI-complete prototype running on realistic mock data — no files are read, moved, or deleted yet. Every scan, clean, and optimize action is simulated against in-memory fixtures, so it's safe to run and demo. Real system integration points are marked with `// INTEGRATION:` comments in the source.

## Features

- **Dashboard** — system health score, reclaimable space, and recommended actions at a glance.
- **Smart Clean** — caches, logs, Xcode junk, leftovers, and more, grouped by safety with Trash-routing and a confirm step.
- **Applications** — full inventory with update badges, an uninstall-confidence score, and a related-files preview for complete removal.
- **Disk Analyzer** — interactive treemap, sunburst, largest-files table, and a storage-by-age timeline.
- **System Monitor** — live CPU / GPU / memory / disk / network / battery / temperature / fan cards with sparklines and process insights.
- **Developer Cleanup** — age-aware reclamation of `node_modules`, DerivedData, Docker layers, and build artifacts.
- **Optimize** — one-click maintenance (rebuild Spotlight / Launch Services, flush DNS) with a Safe / Advanced toggle.
- **Menu bar mode**, **command palette (⌘K)**, **light & dark** themes.

## Design system

Mole ships with a complete, documented design system — indigo-violet brand, Apple-semantic colors, an 8-pt grid, SF Pro type ramp, and a reusable component library — all in `Nebula/DesignSystem/` and `Nebula/Components/`. See [`DESIGN_SPEC.md`](DESIGN_SPEC.md) and [`MOLE_FEATURE_REFERENCE.md`](MOLE_FEATURE_REFERENCE.md).

## Requirements

- macOS 15 (Sequoia) or later
- Xcode 16 or later (to build from source)
- No third-party Swift dependencies (SwiftUI, Swift Charts, Observation)

> **No manual prerequisites.** Mole's app is a front-end for the open-source [Mole engine (CLI)](https://github.com/tw93/mole). You don't need to install it beforehand — on first launch the app detects whether the engine is present and, if not, installs it for you with **one click** (with *Download from GitHub* and *copy command* fallbacks). See [The Mole engine](#the-mole-engine).

## The Mole engine

The app needs the Mole command-line engine to perform real operations. The first time you open Mole, it runs a quick check:

- **Engine found** → you go straight to the dashboard.
- **Engine missing** → the **Install the Mole engine** screen appears. Tap **Install Mole engine** and Mole sets it up — no Terminal needed. Prefer to do it yourself? Use **Download from GitHub** or **Copy Homebrew command**.

You can also tap **Continue in demo mode** to explore the interface on mock data without the engine. The install command and detection paths live in [`Nebula/Models/MoleCLI.swift`](Nebula/Models/MoleCLI.swift) — update them to match the engine's official distribution.

## Build & run

```bash
git clone https://github.com/Ali338991/Mole-Interface.git
cd Mole-Interface
open Nebula.xcodeproj
```

Then press **▶ (⌘R)** in Xcode. On first launch you'll see a short onboarding, then the dashboard. A Mole icon also appears in the menu bar.

## How to use

Everything below runs on **safe mock data** — nothing on your disk is touched yet.

1. **Onboarding** — on first launch, step through the welcome screens and tap *Run first scan* (or *Skip*).
2. **Install the engine** — if the Mole engine isn't found, tap **Install Mole engine** (one click) on the setup screen. Once it's ready, the app continues automatically. (Or *Continue in demo mode* to just explore the UI.)
3. **Dashboard** — read your health score and pick one of the recommended actions, or jump anywhere from the sidebar.
3. **Switch screens** — use the **sidebar** on the left, or press **⌘K** to open the command palette and jump/act instantly.
4. **Smart Clean** — review categories grouped by safety, toggle what to remove, flip **Dry run** to preview, then **Review & Clean** (a confirm sheet shows what goes to Trash vs. permanent).
5. **Applications** — search/filter apps, select one to see its size, related files, and uninstall-confidence, then **Uninstall** for a complete removal.
6. **Disk Analyzer** — switch between **Treemap / Sunburst / Largest files / Timeline**; click a treemap block to drill in.
7. **System Monitor** — watch the live metric cards; click one to expand its history. Use **Pause** to freeze.
8. **Developer Cleanup** — toggle **Stale only**, pick projects, and reclaim regenerable build artifacts.
9. **Optimize** — choose **Safe** or **Advanced**, select tasks, and **Run recommended**.
10. **Appearance** — use the **☾ / ☀ toggle** in the toolbar to switch light/dark. Open **Settings** from the gear in the sidebar footer (or **⌘,**).
11. **Menu bar** — the Mole icon in the macOS menu bar gives quick metrics and actions without opening the window.

## Project structure

```
Nebula.xcodeproj         # the Xcode project (open this)
Nebula/
├── App/                 # entry point + navigation shell
├── DesignSystem/        # colors, typography, spacing, motion, materials
├── Components/          # reusable UI (cards, rings, bars, logo, …)
├── Navigation/          # sidebar, command palette
├── Models/              # observable state, domain models, mock data
├── Features/            # one folder per screen
└── MenuBar/             # menu-bar popover
DESIGN_SPEC.md           # full design specification
MOLE_FEATURE_REFERENCE.md# complete feature reference
```

> Note: the Xcode project is currently named `Nebula` (the original codename) while the app brands itself as **Mole**. This is cosmetic and can be renamed in Xcode later.

## Roadmap

- [ ] Wire real cleanup to the Mole CLI / system APIs (behind the `// INTEGRATION:` points)
- [ ] Privileged helper + entitlements for real file operations
- [ ] Pixel-finish remaining feature screens
- [ ] App notarization & distribution

## Contributing

Contributions are welcome! Please read the [Contributing Guide](CONTRIBUTING.md) to get started, and note our [Code of Conduct](CODE_OF_CONDUCT.md). Found a security issue? See [SECURITY.md](SECURITY.md).

Because this app performs destructive operations once integrated, contributions touching deletion paths must preserve the safety contract: route to Trash by default, never touch protected system paths, support dry-run, and always confirm before permanent removal.

Use the issue templates to file [bugs](.github/ISSUE_TEMPLATE/bug_report.yml) or [feature requests](.github/ISSUE_TEMPLATE/feature_request.yml). See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Credits

- Built on the feature set of [**Mole**](https://github.com/tw93/mole) by [tw93](https://github.com/tw93) — please review its license before reusing any of its code.
- Built with SwiftUI and Swift Charts.

## License

[MIT](LICENSE) © 2026 Ali Ansari
