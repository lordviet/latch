# AGENTS

## Repo Intent

This repository contains a lightweight macOS clipboard manager. The current product goal is a stable text-first experience with a global history picker and pinned entries. Image clipboard support is planned next, but not at the expense of reliability in the text flow.

## Technical Direction

- Keep the app native to macOS using SwiftUI/AppKit interop.
- Use AppKit-native menu bar integration (`NSStatusItem`) for primary menu behavior.
- Prefer small, explicit abstractions over framework-heavy structure.
- Preserve a clear separation between clipboard capture, persistence, UI, and paste automation.
- Optimize for real local usage on macOS before adding breadth.

## Working Rules

- Use `apply_patch` for manual file edits.
- Do not introduce Electron, Tauri, or web wrappers unless explicitly requested.
- Keep generated artifacts out of git.
- Favor deterministic scripts for building and bundling the app, exposed through a simple `Makefile`.
- Before adding new clipboard types, keep the text path working end-to-end.

## Near-Term Roadmap

1. Maintain the standalone `.app` flow.
2. Add configurable global shortcut support.
3. Add launch-at-login support.
4. Add a dedicated monochrome menu bar icon asset.
5. Refactor clipboard entries to support multiple content types.
6. Add image capture, preview, pinning, and restore behavior.
