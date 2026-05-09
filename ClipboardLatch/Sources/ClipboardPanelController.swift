import AppKit
import ApplicationServices
import SwiftUI

@MainActor
final class ClipboardPanelController: NSWindowController, NSWindowDelegate {
    private var previouslyActiveApp: NSRunningApplication?
    private let store: ClipboardStore

    init(store: ClipboardStore) {
        self.store = store
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.title = "ClipboardLatch"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.center()

        super.init(window: panel)
        panel.delegate = self
        updateContentView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showPanel() {
        guard let window else { return }
        previouslyActiveApp = NSWorkspace.shared.frontmostApplication
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.hide(nil)
    }

    private func updateContentView() {
        let rootView = ClipboardHistoryView(store: store) { [weak self] entry in
            self?.store.activate(entry)
            self?.pasteIntoPreviousAppAndClose()
        }

        window?.contentView = NSHostingView(rootView: rootView)
    }

    private func pasteIntoPreviousAppAndClose() {
        window?.orderOut(nil)

        guard let targetApp = previouslyActiveApp else {
            return
        }

        targetApp.activate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.sendCommandV()
        }
    }

    private func sendCommandV() {
        guard let source = CGEventSource(stateID: .hidSystemState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false) else {
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
