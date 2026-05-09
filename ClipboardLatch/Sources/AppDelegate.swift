import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = ClipboardStore()

    private var panelController: ClipboardPanelController?
    private var hotKeyManager: HotKeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        panelController = ClipboardPanelController(store: store)
        hotKeyManager = HotKeyManager { [weak self] in
            Task { @MainActor in
                self?.showHistoryPanel()
            }
        }
        hotKeyManager?.register()
    }

    func showHistoryPanel() {
        panelController?.showPanel()
    }
}
