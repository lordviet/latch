# ClipboardLatch

Minimal macOS clipboard history app for text snippets.

Current behavior:

- Global shortcut: `Cmd+Shift+V`
- Shows recent clipboard text history
- Supports pinning entries
- Choosing an entry copies it back to the system clipboard and triggers paste into the previously focused app

Run locally:

```bash
cd ClipboardLatch
swift run
```

The app stays in the menu bar. Use the global shortcut to open the history panel.

macOS note:

- The first time auto-paste runs, macOS may require Accessibility permission for the app or terminal that launched it so `Cmd+V` can be sent back to the previously active app.
