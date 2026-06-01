import SwiftUI

@main
struct Arkai_MDApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            EditorView()
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
                Button("Save As…") { appDelegate.saveDocumentAs() }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }
    }
}
