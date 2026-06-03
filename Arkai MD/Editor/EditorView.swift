import SwiftUI

struct EditorView: View {
    @Environment(EditorState.self) private var state

    var body: some View {
        @Bindable var state = state
        VStack(spacing: 0) {
            Picker("Mode", selection: $state.viewMode) {
                ForEach(ViewMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 200)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.bar)

            Divider()

            Group {
                switch state.viewMode {
                case .source:
                    SourceTextEditor()
                case .preview:
                    PreviewPane()
                }
            }

            Divider()
            StatusBar()
        }
    }
}

private struct SourceTextEditor: View {
    @Environment(EditorState.self) private var state

    var body: some View {
        TextEditor(text: Binding(
            get: { state.content },
            set: { state.setContent($0) }
        ))
        .font(.system(.body, design: .monospaced))
        .scrollContentBackground(.hidden)
        .padding(8)
    }
}

private struct PreviewPane: View {
    @Environment(EditorState.self) private var state
    @State private var renderedHTML: String = ""

    var body: some View {
        PreviewWebView(renderedHTML: renderedHTML)
            .onAppear { renderedHTML = MarkdownRenderer.render(state.content) }
            .onChange(of: state.content) { _, newValue in
                renderedHTML = MarkdownRenderer.render(newValue)
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
