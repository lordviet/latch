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
                            onUse: { use(entry) }
                        )
                        .tag(entry.id)
                    }
                }
            }
            .frame(minHeight: 320)

            HStack {
                Text("Open: Cmd+Shift+V | Pin: Cmd+P")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

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
}

private struct ClipboardRow: View {
    let entry: ClipboardEntry
    let onPinToggle: () -> Void
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
        }
        .padding(.vertical, 4)
    }
}
