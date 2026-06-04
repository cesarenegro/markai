import SwiftUI

struct FormatBar: View {
    let controller: EditorController

    var body: some View {
        HStack(spacing: 2) {
            group {
                FormatButton(symbol: "bold", help: "Bold (⌘B)") { controller.bold() }
                FormatButton(symbol: "italic", help: "Italic (⌘I)") { controller.italic() }
                FormatButton(symbol: "strikethrough", help: "Strikethrough (⇧⌘X)") { controller.strikethrough() }
                FormatButton(symbol: "curlybraces", help: "Inline Code (⌘E)") { controller.inlineCode() }
                FormatButton(symbol: "link", help: "Link (⌘K)") { controller.link() }
            }

            separator

            Menu {
                Button("Heading 1") { controller.heading(1) }
                    .keyboardShortcut("1", modifiers: .command)
                Button("Heading 2") { controller.heading(2) }
                    .keyboardShortcut("2", modifiers: .command)
                Button("Heading 3") { controller.heading(3) }
                    .keyboardShortcut("3", modifiers: .command)
                Button("Heading 4") { controller.heading(4) }
                Button("Heading 5") { controller.heading(5) }
                Button("Heading 6") { controller.heading(6) }
                Divider()
                Button("Paragraph") { controller.heading(0) }
                    .keyboardShortcut("0", modifiers: .command)
            } label: {
                Image(systemName: "textformat.size")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Heading")

            separator

            group {
                FormatButton(symbol: "list.bullet", help: "Unordered List (⇧⌘8)") { controller.unorderedList() }
                FormatButton(symbol: "list.number", help: "Ordered List (⇧⌘7)") { controller.orderedList() }
                FormatButton(symbol: "checklist", help: "Task List (⇧⌘T)") { controller.taskList() }
            }

            separator

            group {
                FormatButton(symbol: "text.quote", help: "Block Quote (⌃⌘Q)") { controller.blockQuote() }
                FormatButton(symbol: "minus", help: "Horizontal Rule (⌘-)") { controller.horizontalRule() }
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.bar)
    }

    private var separator: some View {
        Divider()
            .frame(height: 14)
            .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 2) { content() }
    }
}

private struct FormatButton: View {
    let symbol: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 13))
                .frame(width: 24, height: 22)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .help(help)
    }
}

#Preview {
    FormatBar(controller: EditorController())
        .frame(width: 600)
}
