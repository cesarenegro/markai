import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let state = EditorState()

    func applicationDidFinishLaunching(_ notification: Notification) {
        state.startAutosave()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.isFileURL {
                state.open(url: url)
            } else if url.scheme == "arkaimd" {
                handleCustomURL(url)
            }
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let url = URL(fileURLWithPath: filename)
        state.open(url: url)
        return true
    }

    private func handleCustomURL(_ url: URL) {
        guard url.host == "open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let path = components.queryItems?.first(where: { $0.name == "path" })?.value
        else { return }
        state.open(url: URL(fileURLWithPath: path))
    }

    func openDocument() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if let mdType = UTType(filenameExtension: "md") {
            panel.allowedContentTypes = [mdType, .plainText]
        }
        guard panel.runModal() == .OK, let url = panel.url else { return }
        state.open(url: url)
    }

    func saveDocumentAs() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = state.fileURL?.lastPathComponent ?? "document.md"
        if let mdType = UTType(filenameExtension: "md") {
            panel.allowedContentTypes = [mdType]
        }
        guard panel.runModal() == .OK, let url = panel.url else { return }
        state.saveAs(url: url)
    }
}
