import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let state = EditorState()
    let vault = VaultState()
    let editor = EditorController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        state.startAutosave()
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
    }

    @objc func serviceNewMarkdownFromSelection(
        _ pasteboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString>
    ) {
        guard let text = readText(from: pasteboard) else {
            error.pointee = "Could not read text from pasteboard"
            return
        }
        Task { @MainActor in
            self.state.newDocument()
            self.state.setContent(text)
            self.bringAppToFront()
        }
    }

    @objc func serviceMakeSkillFromSelection(
        _ pasteboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString>
    ) {
        guard let text = readText(from: pasteboard) else {
            error.pointee = "Could not read text from pasteboard"
            return
        }
        Task { @MainActor in
            self.state.newDocument()
            self.state.setContent(text)
            self.state.showCreateSkillSheet = true
            self.bringAppToFront()
        }
    }

    @objc func serviceMakeSkillFromFile(
        _ pasteboard: NSPasteboard,
        userData: String?,
        error: AutoreleasingUnsafeMutablePointer<NSString>
    ) {
        guard let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
              let url = urls.first else {
            error.pointee = "No file received"
            return
        }
        do {
            let text = try String(contentsOf: url, encoding: .utf8)
            Task { @MainActor in
                self.state.open(url: url)
                self.state.setContent(text)
                self.state.showCreateSkillSheet = true
                self.bringAppToFront()
            }
        } catch {
            self.state.newDocument()
            print("[AppDelegate] read service file failed: \(error)")
        }
    }

    private func readText(from pasteboard: NSPasteboard) -> String? {
        if let utf8 = pasteboard.string(forType: .string) { return utf8 }
        if let data = pasteboard.data(forType: .string),
           let s = String(data: data, encoding: .utf8) { return s }
        return nil
    }

    private func bringAppToFront() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { !$0.isMiniaturized }) {
            window.makeKeyAndOrderFront(nil)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.isFileURL {
                openFileInWorkspace(url)
            } else if url.scheme == "arkaimd" {
                handleCustomURL(url)
            }
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openFileInWorkspace(URL(fileURLWithPath: filename))
        return true
    }

    private func handleCustomURL(_ url: URL) {
        guard url.host == "open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let path = components.queryItems?.first(where: { $0.name == "path" })?.value
        else { return }
        openFileInWorkspace(URL(fileURLWithPath: path))
    }

    private func openFileInWorkspace(_ url: URL) {
        let parent = url.deletingLastPathComponent()
        if vault.vaultURL != parent {
            vault.setVault(url: parent)
        }
        vault.selectedNoteURL = url
        state.open(url: url)
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
        openFileInWorkspace(url)
    }

    func saveDocument() {
        if state.fileURL != nil {
            state.save()
        } else {
            saveDocumentAs()
        }
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
