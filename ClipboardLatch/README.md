# Latch

Minimal macOS clipboard history app for text snippets.

Current behavior:

- Global shortcut: `Cmd+Shift+V`
- Shows recent clipboard text history
- Supports pinning entries
- Choosing an entry copies it back to the system clipboard and triggers paste into the previously focused app
- Reopening the panel selects the top item again and starts the list at the top

Run locally:

```bash
cd ClipboardLatch
swift run
```

The app stays in the menu bar. Use the global shortcut to open the history panel.

macOS note:

- The first time auto-paste runs, macOS may require Accessibility permission for the app or terminal that launched it so `Cmd+V` can be sent back to the previously active app.
- If auto-paste stops working after rebuilding the standalone app, remove the old `Latch` entry from Accessibility settings, quit the app, rebuild, reopen `dist/Latch.app`, and grant access again.
