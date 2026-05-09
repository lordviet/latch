import AppKit
import Combine
import Foundation

@MainActor
final class ClipboardStore: ObservableObject {
    @Published private(set) var entries: [ClipboardEntry] = []

    private let pasteboard = NSPasteboard.general
    private let historyLimit = 50
    private let defaultsKey = "clipboard.entries"
    private var lastChangeCount: Int
    private var timer: Timer?

    init() {
        lastChangeCount = pasteboard.changeCount
        loadEntries()
        startMonitoring()
        captureCurrentPasteboardIfNeeded()
    }

    var pinnedEntries: [ClipboardEntry] {
        entries.filter(\.isPinned)
    }

    var recentEntries: [ClipboardEntry] {
        entries.filter { !$0.isPinned }
    }

    func togglePin(for entry: ClipboardEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[index].isPinned.toggle()
        persistEntries()
    }

    func activate(_ entry: ClipboardEntry) {
        pasteboard.clearContents()
        pasteboard.setString(entry.text, forType: .string)
        addOrPromote(text: entry.text, pinned: entry.isPinned)
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.captureCurrentPasteboardIfNeeded()
            }
        }
    }

    private func captureCurrentPasteboardIfNeeded() {
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        guard let text = pasteboard.string(forType: .string)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            return
        }

        addOrPromote(text: text, pinned: false)
    }

    private func addOrPromote(text: String, pinned: Bool) {
        if let existingIndex = entries.firstIndex(where: { $0.text == text }) {
            var entry = entries.remove(at: existingIndex)
            entry.isPinned = entry.isPinned || pinned
            entries.insert(entry, at: 0)
        } else {
            entries.insert(ClipboardEntry(text: text, isPinned: pinned), at: 0)
        }

        trimHistory()
        persistEntries()
    }

    private func trimHistory() {
        let pinned = entries.filter(\.isPinned)
        let unpinned = entries.filter { !$0.isPinned }
        entries = pinned + Array(unpinned.prefix(max(0, historyLimit - pinned.count)))
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let savedEntries = try? JSONDecoder().decode([ClipboardEntry].self, from: data) else {
            return
        }

        entries = savedEntries
    }

    private func persistEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
