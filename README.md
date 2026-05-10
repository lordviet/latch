# Latch

Minimal macOS clipboard manager focused on fast text history first, then richer clipboard types.

Current status:

- Native macOS menu bar app using SwiftUI/AppKit
- Global shortcut: `Cmd+Shift+V`
- Text clipboard history
- Pin and unpin entries
- Restore an entry to the clipboard and paste it into the previously focused app
- Native status bar menu with About, Settings, and Quit
- Custom bundled app icon sourced from `ClipboardLatch/latch-icon.png`

## Project Layout

- `ClipboardLatch/`: Swift package containing the app source
- `scripts/build_app.sh`: low-level bundling script for the standalone app
- `Makefile`: top-level developer entrypoint for build/run/open/clean

## Run During Development

```bash
cd ClipboardLatch
swift run
```

If you run it this way, macOS Accessibility permission applies to the terminal app that launched it.

## Build a Real App Bundle

```bash
make build
make open
```

Once you launch the real app, grant Accessibility permission to `ClipboardLatch.app` instead of your terminal so simulated paste works reliably.

You can still call `./scripts/build_app.sh` directly, but `make` is the primary interface now.

## Next Steps

- Add configurable global shortcut support
- Add launch-at-login support
- Add a dedicated monochrome menu bar icon asset
- Extend clipboard entries to support images
