import SwiftUI

struct ClipboardHistoryView: View {
    @ObservedObject var store: ClipboardStore
    let onUse: (ClipboardEntry) -> Void
    let onSelectionChange: (ClipboardEntry.ID?) -> Void

    @State private var selection: ClipboardEntry.ID?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clipboard History")
                .font(.title3.weight(.semibold))

            List(selection: $selection) {
                if !store.pinnedEntries.isEmpty {
                    Section("Pinned") {
                        ForEach(store.pinnedEntries) { entry in
                            ClipboardRow(
                                entry: entry,
                                onPinToggle: { store.togglePin(for: entry) },
                                onDelete: { delete(entry) },
                                onUse: { use(entry) }
                            )
                            .tag(entry.id)
                        }
                    }
                }

                Section("Recent") {
                    ForEach(store.recentEntries) { entry in
                        ClipboardRow(
                            entry: entry,
                            onPinToggle: { store.togglePin(for: entry) },
                            onDelete: { delete(entry) },
                            onUse: { use(entry) }
                        )
                        .tag(entry.id)
                    }
                }
            }
            .frame(minHeight: 320)

            HStack {
                Text("Open: Cmd+Shift+V | Pin: Cmd+P | Delete: Del")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    deleteSelected()
                } label: {
                    Image(systemName: "trash")
                }
                .keyboardShortcut(.delete, modifiers: [])
                .disabled(selection == nil)
                .help("Delete Selected")

                Button("Paste Selected") {
                    guard let selection,
                          let entry = store.entries.first(where: { $0.id == selection }) else {
                        return
                    }
                    use(entry)
                }
                .keyboardShortcut(.return, modifiers: [])
                .disabled(selection == nil)
            }
        }
        .padding(16)
        .frame(width: 560, height: 420)
        .onAppear {
            resetSelection()
        }
        .onChange(of: selection) { _, newSelection in
            onSelectionChange(newSelection)
        }
    }

    private func resetSelection() {
        let topEntryID = store.entries.first?.id
        selection = topEntryID
        onSelectionChange(topEntryID)
    }

    private func use(_ entry: ClipboardEntry) {
        selection = entry.id
        onUse(entry)
    }

    private func delete(_ entry: ClipboardEntry) {
        let nextSelection = nextSelection(afterDeleting: entry.id, from: orderedEntriesForSelection())

        selection = nextSelection
        store.delete(entry)
    }

    private func deleteSelected() {
        guard let selection,
              let entry = orderedEntriesForSelection().first(where: { $0.id == selection }) else {
            return
        }

        delete(entry)
    }

    private func orderedEntriesForSelection() -> [ClipboardEntry] {
        store.pinnedEntries + store.recentEntries
    }

    private func nextSelection(
        afterDeleting entryID: ClipboardEntry.ID,
        from entries: [ClipboardEntry]
    ) -> ClipboardEntry.ID? {
        guard let deletedIndex = entries.firstIndex(where: { $0.id == entryID }) else {
            return entries.first?.id
        }

        if entries.count <= 1 {
            return nil
        }

        if deletedIndex < entries.index(before: entries.endIndex) {
            return entries[entries.index(after: deletedIndex)].id
        }

        return entries[entries.index(before: deletedIndex)].id
    }
}

private struct ClipboardRow: View {
    let entry: ClipboardEntry
    let onPinToggle: () -> Void
    let onDelete: () -> Void
    let onUse: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                onPinToggle()
            } label: {
                Image(systemName: entry.isPinned ? "pin.fill" : "pin")
                    .foregroundStyle(entry.isPinned ? .orange : .secondary)
            }
            .buttonStyle(.borderless)
            .help(entry.isPinned ? "Unpin Entry" : "Pin Entry")

            Button(action: onUse) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.text)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    Text(entry.createdAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Delete Entry")
        }
        .padding(.vertical, 4)
    }
}
