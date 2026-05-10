import AppKit
import ApplicationServices
import SwiftUI

@MainActor
final class ClipboardPanelController: NSWindowController, NSWindowDelegate {
    private var previouslyActiveApp: NSRunningApplication?
    private var selectedEntryID: ClipboardEntry.ID?
    private var didRequestAccessibilityPermission = false
    private let store: ClipboardStore
    private let currentProcessIdentifier = ProcessInfo.processInfo.processIdentifier

    init(store: ClipboardStore) {
        self.store = store
        let panel = ClipboardPanel(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.title = "Latch"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.center()

        super.init(window: panel)
        panel.delegate = self
        panel.onReturnKey = { [weak self] in
            self?.useSelectedEntry()
        }
        updateContentView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showPanel(forceFront: Bool = false) {
        guard let window else { return }
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           frontmostApp.processIdentifier != currentProcessIdentifier {
            previouslyActiveApp = frontmostApp
        }
        updateContentView()
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.orderFrontRegardless()
        window.makeKey()
        if forceFront {
            window.level = .modalPanel
        } else {
            window.level = .floating
        }
        DispatchQueue.main.async {
            window.makeKeyAndOrderFront(nil)
        }
    }

    func windowWillClose(_ notification: Notification) {
        NSApp.hide(nil)
    }

    private func updateContentView() {
        let rootView = ClipboardHistoryView(
            store: store,
            onUse: { [weak self] entry in
                self?.use(entry)
            },
            onSelectionChange: { [weak self] selection in
                self?.selectedEntryID = selection
            }
        )

        window?.contentView = NSHostingView(rootView: rootView)
    }

    private func useSelectedEntry() {
        let selectedEntry = selectedEntryID.flatMap { selectedID in
            store.entries.first { $0.id == selectedID }
        }

        guard let entry = selectedEntry ?? store.entries.first else { return }
        use(entry)
    }

    private func use(_ entry: ClipboardEntry) {
        selectedEntryID = entry.id
        store.activate(entry)
        pasteIntoPreviousAppAndClose()
    }

    private func pasteIntoPreviousAppAndClose() {
        guard ensureAccessibilityPermission() else {
            NSSound.beep()
            return
        }

        window?.orderOut(nil)

        guard let targetApp = previouslyActiveApp else {
            NSApp.hide(nil)
            return
        }

        NSApp.hide(nil)
        targetApp.activate()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.sendCommandV()
        }
    }

    private func ensureAccessibilityPermission() -> Bool {
        if AXIsProcessTrusted() {
            return true
        }

        guard !didRequestAccessibilityPermission else {
            return false
        }

        didRequestAccessibilityPermission = true
        let options = [
            "AXTrustedCheckOptionPrompt" as CFString: true
        ] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
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

private final class ClipboardPanel: NSPanel {
    var onReturnKey: (() -> Void)?

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76:
            onReturnKey?()
        default:
            super.keyDown(with: event)
        }
    }
}
