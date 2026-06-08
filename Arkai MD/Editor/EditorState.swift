import Foundation
import Observation

enum ViewMode: String, CaseIterable, Identifiable {
    case source = "Source"
    case preview = "Preview"
    var id: String { rawValue }
}

@MainActor
@Observable
final class EditorState {
    var content: String = ""
    var fileURL: URL? = nil
    var isDirty: Bool = false
    var lastSavedAt: Date? = nil
    var viewMode: ViewMode = .source
    var showFormatBar: Bool = true
    var showCreateSkillSheet: Bool = false
    var showGraphSheet: Bool = false

    var lastIOErrorMessage: String? = nil
    var showIOErrorAlert: Bool = false

    private var autosaveTask: Task<Void, Never>?

    var wordCount: Int {
        content.split { $0.isWhitespace || $0.isNewline }.count
    }

    var displayName: String {
        fileURL?.lastPathComponent ?? "Untitled"
    }

    func newDocument() {
        content = ""
        fileURL = nil
        isDirty = false
        lastSavedAt = nil
    }

    func open(url: URL) {
        do {
            let text = try withSecurityScopedAccess(url) {
                try String(contentsOf: url, encoding: .utf8)
            }
            content = text
            fileURL = url
            isDirty = false
            lastSavedAt = Date()
        } catch {
            let message = "Could not open file:\n\(url.path)\n\n\(error.localizedDescription)"
            lastIOErrorMessage = message
            showIOErrorAlert = true
            print("[EditorState] open failed for \(url.path): \(error)")
        }
    }

    func setContent(_ newContent: String) {
        guard newContent != content else { return }
        content = newContent
        isDirty = true
    }

    func saveAs(url: URL) {
        fileURL = url
        save()
    }

    func save() {
        guard let url = fileURL else { return }
        do {
            try withSecurityScopedAccess(url) {
                try content.write(to: url, atomically: true, encoding: .utf8)
            }
            isDirty = false
            lastSavedAt = Date()
        } catch {
            let message = "Could not save file:\n\(url.path)\n\n\(error.localizedDescription)"
            lastIOErrorMessage = message
            showIOErrorAlert = true
            print("[EditorState] save failed for \(url.path): \(error)")
        }
    }

    func toggleViewMode() {
        viewMode = (viewMode == .source) ? .preview : .source
    }

    func startAutosave() {
        autosaveTask?.cancel()
        autosaveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard let self else { return }
                if self.isDirty, self.fileURL != nil {
                    self.save()
                }
            }
        }
    }
}

private func withSecurityScopedAccess<T>(_ url: URL, _ work: () throws -> T) rethrows -> T {
    let didStart = url.startAccessingSecurityScopedResource()
    defer {
        if didStart {
            url.stopAccessingSecurityScopedResource()
        }
    }
    return try work()
}
