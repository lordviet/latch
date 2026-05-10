import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = ClipboardStore()

    private var panelController: ClipboardPanelController?
    private var hotKeyManager: HotKeyManager?
    private var settingsWindowController: NSWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureAppIcon()

        panelController = ClipboardPanelController(store: store)
        settingsWindowController = SettingsWindowController()
        configureStatusItem()
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

    func showAboutPanel() {
        presentFromMenuBar {
            NSApp.orderFrontStandardAboutPanel([
                NSApplication.AboutPanelOptionKey.applicationName: "Latch",
                NSApplication.AboutPanelOptionKey.applicationVersion: "0.1.0",
                NSApplication.AboutPanelOptionKey.version: "1"
            ])
        }
    }

    func showSettingsPanel() {
        presentFromMenuBar {
            self.settingsWindowController?.showWindow(nil)
            self.settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        }
    }

    private func activateForAuxiliaryUI() {
        NSApp.activate(ignoringOtherApps: true)
        NSRunningApplication.current.activate(options: [])
    }

    private func presentFromMenuBar(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.activateForAuxiliaryUI()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
            }
        }
    }

    private func configureStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "paperclip", accessibilityDescription: "Latch")
        statusItem.button?.image?.isTemplate = true

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About Latch", action: #selector(showAboutPanelAction), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(showSettingsPanelAction), keyEquivalent: ","))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitAction), keyEquivalent: "q"))
        menu.items.forEach { $0.target = self }

        statusItem.menu = menu
        self.statusItem = statusItem
    }

    @objc
    private func showAboutPanelAction() {
        showAboutPanel()
    }

    @objc
    private func showSettingsPanelAction() {
        showSettingsPanel()
    }

    @objc
    private func quitAction() {
        NSApp.terminate(nil)
    }

    private func configureAppIcon() {
        guard let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
              let icon = NSImage(contentsOfFile: iconPath) else {
            return
        }

        NSApp.applicationIconImage = icon
    }
}
