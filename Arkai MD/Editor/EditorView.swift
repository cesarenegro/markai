import SwiftUI

struct EditorView: View {
    @Environment(EditorState.self) private var state

    var body: some View {
        @Bindable var state = state
        VStack(spacing: 0) {
            TextEditor(text: Binding(
                get: { state.content },
                set: { state.setContent($0) }
            ))
            .font(.system(.body, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(8)

            Divider()
            StatusBar()
        }
    }
}

private struct StatusBar: View {
    @Environment(EditorState.self) private var state

    var body: some View {
        HStack(spacing: 12) {
            Text(state.displayName)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text("\(state.wordCount) words")
                .foregroundStyle(.secondary)
            Text(savedLabel)
                .foregroundStyle(state.isDirty ? .orange : .secondary)
                .monospacedDigit()
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.bar)
    }

    private var savedLabel: String {
        if state.isDirty { return "editing…" }
        guard let date = state.lastSavedAt else { return "—" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "saved " + formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    EditorView()
        .environment(EditorState())
        .frame(width: 700, height: 500)
}
