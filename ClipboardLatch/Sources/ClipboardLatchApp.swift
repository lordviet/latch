import SwiftUI

@main
struct ClipboardLatchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("ClipboardLatch", systemImage: "paperclip") {
            Button("Show Clipboard History") {
                NSApp.activate(ignoringOtherApps: true)
                (NSApp.delegate as? AppDelegate)?.showHistoryPanel()
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .menuBarExtraStyle(.window)

        Settings {
            VStack(alignment: .leading, spacing: 12) {
                Text("ClipboardLatch")
                    .font(.title2.bold())
                Text("Use Cmd+Shift+V to open your clipboard history. Click the pin icon to keep an entry at the top.")
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(width: 420)
        }
    }
}
