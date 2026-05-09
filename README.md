# Latch

Minimal macOS clipboard manager focused on fast text history first, then richer clipboard types.

Current status:

- Native SwiftUI menu bar app
- Global shortcut: `Cmd+Shift+V`
- Text clipboard history
- Pin and unpin entries
- Restore an entry to the clipboard and paste it into the previously focused app

## Project Layout

- `ClipboardLatch/`: Swift package containing the app source
- `scripts/build_app.sh`: builds a local `.app` bundle into `dist/`

## Run During Development

```bash
cd ClipboardLatch
swift run
```

If you run it this way, macOS Accessibility permission applies to the terminal app that launched it.

## Build a Real App Bundle

```bash
./scripts/build_app.sh
open dist/ClipboardLatch.app
```

Once you launch the real app, grant Accessibility permission to `ClipboardLatch.app` instead of your terminal so simulated paste works reliably.

## Next Steps

- Package and verify the standalone app flow
- Add launch-at-login support
- Extend clipboard entries to support images

