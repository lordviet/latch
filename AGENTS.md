# AGENTS

## Repo Intent

This repository contains a lightweight macOS clipboard manager. The current product goal is a stable text-first experience with a global history picker and pinned entries. Image clipboard support is planned next, but not at the expense of reliability in the text flow.

## Technical Direction

- Keep the app native to macOS using SwiftUI/AppKit interop.
- Use AppKit-native menu bar integration (`NSStatusItem`) for primary menu behavior.
- Prefer small, explicit abstractions over framework-heavy structure.
- Preserve a clear separation between clipboard capture, persistence, UI, and paste automation.
- Optimize for real local usage on macOS before adding breadth.
- The built app bundle is `dist/Latch.app`; keep app naming, executable naming, and docs aligned around `Latch`.

## Architecture

- `ClipboardLatch/` is the Swift package for the app; the repository root owns project docs, scripts, and the `Makefile`.
- `LatchApp` is the SwiftUI entry point, but lifecycle work is delegated to `AppDelegate` through `@NSApplicationDelegateAdaptor`.
- `AppDelegate` owns the long-lived application objects: `ClipboardStore`, `ClipboardPanelController`, `HotKeyManager`, `SettingsWindowController`, and the `NSStatusItem` menu.
- `ClipboardStore` is the clipboard and persistence boundary. It polls `NSPasteboard.general`, stores text entries in `UserDefaults`, handles pinning, and restores selected entries back to the pasteboard.
- `ClipboardHistoryView` is the SwiftUI history UI. It renders pinned and recent entries from `ClipboardStore`, tracks selection, and sends use/pin actions back through explicit closures.
- `ClipboardPanelController` is the AppKit bridge for the picker window. It hosts `ClipboardHistoryView` in an `NSPanel`, remembers the previously focused app, and performs paste automation with Accessibility-gated `Cmd+V` events.
- `HotKeyManager` owns the current global shortcut registration through Carbon hot key APIs. It should remain small until shortcut configuration is introduced.
- `SettingsWindowController` currently hosts placeholder SwiftUI settings in an AppKit window; planned settings should build from this boundary.
- `scripts/build_app.sh` and the root `Makefile` build and bundle `dist/Latch.app`; generated build output should stay out of git.

## Working Rules

- Use `apply_patch` for manual file edits.
- Do not introduce Electron, Tauri, or web wrappers unless explicitly requested.
- Keep generated artifacts out of git.
- Favor deterministic scripts for building and bundling the app, exposed through a simple `Makefile`.
- Before adding new clipboard types, keep the text path working end-to-end.
- Default history UX should optimize for fast recent paste, so reopening the panel should start from the top item.
- Auto-paste depends on macOS Accessibility trust. Rebuilt ad-hoc signed bundles may need the old Accessibility entry removed and the new `Latch.app` granted again.

## Near-Term Roadmap

1. Maintain the standalone `.app` flow.
2. Add configurable global shortcut support.
3. Add launch-at-login support.
4. Add a dedicated monochrome menu bar icon asset.
5. Refactor clipboard entries to support multiple content types.
6. Add image capture, preview, pinning, and restore behavior.
