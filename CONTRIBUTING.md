# Contributing to Mole

Thanks for your interest in improving Mole! This document explains how to propose changes.

## Ways to contribute

- **Report bugs** — open an issue using the Bug Report template.
- **Request features** — open an issue using the Feature Request template.
- **Improve docs** — fixes to the README or design docs are very welcome.
- **Submit code** — pick an open issue (or open one to discuss first), then send a pull request.

## Development setup

1. Requirements: **macOS 15+** and **Xcode 16+**.
2. Fork and clone the repo:
   ```bash
   git clone https://github.com/<your-username>/Mole-Interface.git
   cd Mole-Interface
   open Nebula.xcodeproj
   ```
3. Build & run with **⌘R**. The app runs entirely on in-memory mock data — no system files are touched.

## Project layout

```
Nebula/
├── App/            # entry point + navigation shell
├── DesignSystem/   # colors, typography, spacing, motion, materials
├── Components/     # reusable UI (cards, rings, bars, logo, …)
├── Navigation/     # sidebar, command palette
├── Models/         # observable state, domain models, mock data
├── Features/       # one folder per screen
└── MenuBar/        # menu-bar popover
```

## Coding guidelines

- Swift + SwiftUI, targeting macOS 15. Prefer first-party frameworks over dependencies.
- Use the design-system tokens (`Color.nebula*`, `Font.nebula*`, `Spacing`, `Radius`, `Motion`) instead of hard-coded values.
- Keep view bodies small; extract subviews for readability and good diffing.
- Match the existing style; run **Editor ▸ Structure ▸ Re-Indent** before committing.

## Safety contract (important)

Once real system integration lands, Mole performs destructive operations. Any contribution that touches deletion or cleanup paths **must** preserve these guarantees:

- Route recoverable removals to the **Trash** by default.
- **Never** modify protected system paths.
- Support **dry-run** previews.
- Require **explicit confirmation** before any permanent removal.

PRs that weaken these guarantees will not be merged.

## Pull request process

1. Create a branch: `git checkout -b feature/short-description`.
2. Make focused commits with clear messages.
3. Ensure the project builds (`⌘B`) with no new warnings.
4. Open a PR against `main`, fill in the template, and link any related issue.
5. A maintainer will review. Be responsive to feedback — small, scoped PRs merge fastest.

## Code of Conduct

By participating, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).
