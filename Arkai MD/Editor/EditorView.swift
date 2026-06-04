import SwiftUI

struct EditorView: View {
    @Environment(EditorState.self) private var state
    @AppStorage("appTheme") private var themeID: String = AppTheme.system.id
    let controller: EditorController
    let onSave: () -> Void
    let onMakeSkill: () -> Void

    private var theme: AppTheme { AppTheme.lookup(themeID) }

    var body: some View {
        @Bindable var state = state
        VStack(spacing: 0) {
            TopBar(
                viewMode: $state.viewMode,
                isDirty: state.isDirty,
                theme: theme,
                onSave: onSave,
                onMakeSkill: onMakeSkill
            )

            Divider()

            Group {
                switch state.viewMode {
                case .source:
                    VStack(spacing: 0) {
                        if state.showFormatBar {
                            FormatBar(controller: controller)
                                .modifier(BarBackground(theme: theme))
                                .foregroundStyle(theme.foregroundColor ?? .primary)
                            Divider()
                        }
                        SourceTextEditor(controller: controller, theme: theme)
                    }
                case .preview:
                    PreviewPane()
                }
            }

            Divider()
            StatusBar(theme: theme)
        }
        .tint(theme.accentColor ?? Color.accentColor)
        .sheet(isPresented: $state.showCreateSkillSheet) {
            CreateSkillView(initial: SkillBuilder.extract(from: state.content))
        }
    }
}

private struct BarBackground: ViewModifier {
    let theme: AppTheme

    func body(content: Content) -> some View {
        if let bg = theme.barBackgroundColor {
            content.background(bg)
        } else {
            content.background(.bar)
        }
    }
}

private struct TopBar: View {
    @Binding var viewMode: ViewMode
    let isDirty: Bool
    let theme: AppTheme
    let onSave: () -> Void
    let onMakeSkill: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Picker("Mode", selection: $viewMode) {
                ForEach(ViewMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 200)

            Spacer()

            Button(action: onSave) {
                Label("Save", systemImage: isDirty ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                    .labelStyle(.titleAndIcon)
            }
            .help("Save document (⌘S)")

            Button(action: onMakeSkill) {
                Label("Make Skill", systemImage: "wand.and.stars")
                    .labelStyle(.titleAndIcon)
            }
            .help("Convert current document into an Agent Skill (⇧⌘A)")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .foregroundStyle(theme.foregroundColor ?? .primary)
        .modifier(BarBackground(theme: theme))
    }
}

private struct SourceTextEditor: View {
    @Environment(EditorState.self) private var state
    let controller: EditorController
    let theme: AppTheme

    var body: some View {
        MarkdownTextEditor(
            text: Binding(
                get: { state.content },
                set: { state.setContent($0) }
            ),
            controller: controller,
            theme: theme
        )
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
    let theme: AppTheme

    var body: some View {
        HStack(spacing: 12) {
            Text(state.displayName)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer()
            Text("\(state.wordCount) words")
            Text(savedLabel)
                .monospacedDigit()
                .opacity(state.isDirty ? 1.0 : 0.85)
        }
        .font(.caption)
        .opacity(theme.foregroundColor == nil ? 1.0 : 0.85)
        .foregroundStyle(theme.foregroundColor ?? .secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .modifier(BarBackground(theme: theme))
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
    EditorView(
        controller: EditorController(),
        onSave: {},
        onMakeSkill: {}
    )
    .environment(EditorState())
    .frame(width: 700, height: 500)
}
