import AppKit
import SwiftUI

@main
struct Arkai_MDApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            EditorView(
                controller: appDelegate.editor,
                onSave: { appDelegate.saveDocument() },
                onMakeSkill: { appDelegate.state.showCreateSkillSheet = true }
            )
            .frame(minWidth: 600, minHeight: 400)
            .environment(appDelegate.state)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New") { appDelegate.state.newDocument() }
                    .keyboardShortcut("n", modifiers: .command)
                Button("Open…") { appDelegate.openDocument() }
                    .keyboardShortcut("o", modifiers: .command)
            }
            CommandGroup(replacing: .saveItem) {
                Button("Save") { appDelegate.saveDocument() }
                    .keyboardShortcut("s", modifiers: .command)
                Button("Save As…") { appDelegate.saveDocumentAs() }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
                Divider()
                Button("Create Agent Skill…") {
                    appDelegate.state.showCreateSkillSheet = true
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
            }
            CommandMenu("Format") {
                Button("Bold") { appDelegate.editor.bold() }
                    .keyboardShortcut("b", modifiers: .command)
                Button("Italic") { appDelegate.editor.italic() }
                    .keyboardShortcut("i", modifiers: .command)
                Button("Strikethrough") { appDelegate.editor.strikethrough() }
                    .keyboardShortcut("x", modifiers: [.command, .shift])
                Button("Inline Code") { appDelegate.editor.inlineCode() }
                    .keyboardShortcut("e", modifiers: .command)
                Button("Link…") { appDelegate.editor.link() }
                    .keyboardShortcut("k", modifiers: .command)

                Divider()

                Menu("Heading") {
                    Button("Heading 1") { appDelegate.editor.heading(1) }
                        .keyboardShortcut("1", modifiers: .command)
                    Button("Heading 2") { appDelegate.editor.heading(2) }
                        .keyboardShortcut("2", modifiers: .command)
                    Button("Heading 3") { appDelegate.editor.heading(3) }
                        .keyboardShortcut("3", modifiers: .command)
                    Button("Heading 4") { appDelegate.editor.heading(4) }
                        .keyboardShortcut("4", modifiers: .command)
                    Button("Heading 5") { appDelegate.editor.heading(5) }
                        .keyboardShortcut("5", modifiers: .command)
                    Button("Heading 6") { appDelegate.editor.heading(6) }
                        .keyboardShortcut("6", modifiers: .command)
                    Divider()
                    Button("Paragraph") { appDelegate.editor.heading(0) }
                        .keyboardShortcut("0", modifiers: .command)
                }

                Divider()

                Button("Block Quote") { appDelegate.editor.blockQuote() }
                    .keyboardShortcut("q", modifiers: [.command, .control])
                Button("Unordered List") { appDelegate.editor.unorderedList() }
                    .keyboardShortcut("8", modifiers: [.command, .shift])
                Button("Ordered List") { appDelegate.editor.orderedList() }
                    .keyboardShortcut("7", modifiers: [.command, .shift])
                Button("Task List") { appDelegate.editor.taskList() }
                    .keyboardShortcut("t", modifiers: [.command, .shift])

                Divider()

                Button("Horizontal Rule") { appDelegate.editor.horizontalRule() }
                    .keyboardShortcut("-", modifiers: .command)
            }
            CommandMenu("View") {
                Button(appDelegate.state.viewMode == .source ? "Show Preview" : "Show Source") {
                    appDelegate.state.toggleViewMode()
                }
                .keyboardShortcut("p", modifiers: [.command, .shift])

                Button(appDelegate.state.showFormatBar ? "Hide Format Bar" : "Show Format Bar") {
                    appDelegate.state.showFormatBar.toggle()
                }
                .keyboardShortcut("b", modifiers: [.command, .option])
            }

            CommandGroup(replacing: .help) {
                HelpMenuCommands()
            }
        }

        Window("mARK.AI Help", id: "help") {
            HelpView()
        }
        .defaultSize(width: 980, height: 640)
        .defaultPosition(.center)

        Settings {
            SettingsView()
        }
    }
}

private struct HelpMenuCommands: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("mARK.AI Help") {
            openWindow(id: "help")
        }
        .keyboardShortcut("?", modifiers: .command)

        Divider()

        Button("mARK.AI on GitHub") {
            openExternal("https://github.com/cesarenegro/markai")
        }
        Button("Report an Issue…") {
            openExternal("https://github.com/cesarenegro/markai/issues/new")
        }

        Divider()

        Button("Privacy Policy") {
            openExternal("https://arkai.dev/app/PPmarkai")
        }
        Button("License Agreement (EULA)") {
            openExternal("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        }
    }

    private func openExternal(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }
}
