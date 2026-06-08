import AppKit
import Foundation
import Observation
import Yams

struct VaultNote: Identifiable, Hashable {
    var id: URL { url }
    let url: URL
    let title: String
    let key: String
    let frontmatter: [String: String]
    let outgoingWikiLinkKeys: [String]
    let searchText: String
}

@MainActor
@Observable
final class VaultState {
    var vaultURL: URL? = nil
    var notes: [VaultNote] = []
    var selectedNoteURL: URL? = nil
    var searchQuery: String = ""

    private let vaultBookmarkKey = "vaultBookmark"
    private var isAccessingVault = false

    private var noteURLByKey: [String: URL] = [:]
    private var backlinkSourcesByTargetKey: [String: Set<URL>] = [:]
    private var refreshTask: Task<Void, Never>?

    var filteredNotes: [VaultNote] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return notes }
        return notes.filter { note in
            note.title.lowercased().contains(query) || note.searchText.contains(query)
        }
    }

    func openVaultPanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.prompt = "Open"
        panel.message = "Choose a folder to use as your vault"

        guard panel.runModal() == .OK, let url = panel.url else { return }
        setVault(url: url)
    }

    func setVault(url: URL) {
        stopAccessingVaultIfNeeded()

        vaultURL = url
        UserDefaults.standard.set(url.path, forKey: "vaultPath")

        if let bookmark = try? url.bookmarkData(
            options: [.withSecurityScope],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        ) {
            UserDefaults.standard.set(bookmark, forKey: vaultBookmarkKey)
        }

        startAccessingVaultIfPossible(url)
        refreshIndex()
    }

    func restoreVaultIfAvailable() {
        guard vaultURL == nil else { return }

        if let bookmark = UserDefaults.standard.data(forKey: vaultBookmarkKey) {
            var isStale = false
            if let url = try? URL(
                resolvingBookmarkData: bookmark,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            ) {
                if isStale {
                    UserDefaults.standard.removeObject(forKey: vaultBookmarkKey)
                }
                vaultURL = url
                startAccessingVaultIfPossible(url)
                refreshIndex()
                return
            }
        }

        guard let path = UserDefaults.standard.string(forKey: "vaultPath") else { return }
        let url = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        vaultURL = url
        startAccessingVaultIfPossible(url)
        refreshIndex()
    }

    func refreshIndex() {
        refreshTask?.cancel()
        guard let vaultURL else {
            notes = []
            noteURLByKey = [:]
            backlinkSourcesByTargetKey = [:]
            return
        }

        refreshTask = Task {
            let scanned = await Self.scanVault(at: vaultURL)
            if Task.isCancelled { return }
            notes = scanned.notes
            noteURLByKey = scanned.noteURLByKey
            backlinkSourcesByTargetKey = scanned.backlinkSourcesByTargetKey

            if let selected = selectedNoteURL, FileManager.default.fileExists(atPath: selected.path) {
                return
            }
            selectedNoteURL = notes.first?.url
        }
    }

    func revealVaultInFinder() {
        guard let vaultURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([vaultURL])
    }

    func resolveWikiLinkTargetPath(for key: String) -> URL? {
        noteURLByKey[key]
    }

    func resolveWikiLinkTargetPath(forRawTarget rawTarget: String) -> URL? {
        let key = Self.normalizeWikiLinkKey(rawTarget)
        guard !key.isEmpty else { return nil }
        return noteURLByKey[key]
    }

    func backlinks(to noteURL: URL) -> [VaultNote] {
        let key = Self.noteKey(for: noteURL)
        let sources = backlinkSourcesByTargetKey[key] ?? []
        if sources.isEmpty { return [] }
        let noteByURL = Dictionary(uniqueKeysWithValues: notes.map { ($0.url, $0) })
        return sources.compactMap { noteByURL[$0] }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func outgoingLinks(from markdown: String) -> [String] {
        WikiLinkExtractor.extractKeys(from: markdown)
    }

    private static func scanVault(at url: URL) async -> (notes: [VaultNote], noteURLByKey: [String: URL], backlinkSourcesByTargetKey: [String: Set<URL>]) {
        let fm = FileManager.default
        var urls: [URL] = []
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles, .skipsPackageDescendants])

        while let next = enumerator?.nextObject() as? URL {
            guard next.pathExtension.lowercased() == "md" || next.pathExtension.lowercased() == "markdown" else { continue }
            urls.append(next)
        }

        urls.sort { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }

        var notes: [VaultNote] = []
        var noteURLByKey: [String: URL] = [:]
        var backlinkSourcesByTargetKey: [String: Set<URL>] = [:]

        for fileURL in urls {
            if Task.isCancelled { break }
            let content = (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
            let frontmatter = FrontmatterExtractor.parse(from: content).frontmatter
            let outgoingKeys = WikiLinkExtractor.extractKeys(from: content)

            let title = fileURL.deletingPathExtension().lastPathComponent
            let key = noteKey(for: fileURL)

            var searchText = content.lowercased()
            if searchText.count > 200_000 {
                searchText = String(searchText.prefix(200_000))
            }

            let note = VaultNote(
                url: fileURL,
                title: title,
                key: key,
                frontmatter: frontmatter,
                outgoingWikiLinkKeys: outgoingKeys,
                searchText: searchText
            )
            notes.append(note)

            if noteURLByKey[key] == nil {
                noteURLByKey[key] = fileURL
            }

            for targetKey in outgoingKeys {
                backlinkSourcesByTargetKey[targetKey, default: []].insert(fileURL)
            }
        }

        return (notes, noteURLByKey, backlinkSourcesByTargetKey)
    }

    private static func noteKey(for url: URL) -> String {
        url.deletingPathExtension().lastPathComponent.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func normalizeWikiLinkKey(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.lowercased().hasSuffix(".md") {
            s.removeLast(3)
        } else if s.lowercased().hasSuffix(".markdown") {
            s.removeLast(9)
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func startAccessingVaultIfPossible(_ url: URL) {
        guard !isAccessingVault else { return }
        if url.startAccessingSecurityScopedResource() {
            isAccessingVault = true
        }
    }

    private func stopAccessingVaultIfNeeded() {
        guard isAccessingVault else { return }
        vaultURL?.stopAccessingSecurityScopedResource()
        isAccessingVault = false
    }
}

enum WikiLinkExtractor {
    static func extractKeys(from markdown: String) -> [String] {
        let pattern = #"\[\[([^\]]+)\]\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let ns = markdown as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: markdown, options: [], range: range)

        var keys: [String] = []
        keys.reserveCapacity(matches.count)

        for match in matches {
            guard match.numberOfRanges >= 2 else { continue }
            let raw = ns.substring(with: match.range(at: 1))
            let target = raw.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: true).first.map(String.init) ?? raw
            let normalized = normalizeKey(target)
            if !normalized.isEmpty {
                keys.append(normalized)
            }
        }
        return keys
    }

    private static func normalizeKey(_ raw: String) -> String {
        var s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.lowercased().hasSuffix(".md") {
            s.removeLast(3)
        }
        return s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

enum FrontmatterExtractor {
    static func parse(from markdown: String) -> (frontmatter: [String: String], body: String) {
        let trimmed = markdown
        guard trimmed.hasPrefix("---\n") || trimmed.hasPrefix("---\r\n") else {
            return ([:], markdown)
        }

        let lines = markdown.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        guard lines.first == "---" else { return ([:], markdown) }

        var yamlLines: [Substring] = []
        var endIndex: Int? = nil

        for i in 1..<lines.count {
            if lines[i] == "---" || lines[i] == "..." {
                endIndex = i
                break
            }
            yamlLines.append(lines[i])
        }

        guard let endIndex else { return ([:], markdown) }

        let yaml = yamlLines.joined(separator: "\n")
        var bodyLines = Array(lines[(endIndex + 1)...])
        if bodyLines.first == "" { bodyLines.removeFirst() }
        let body = bodyLines.joined(separator: "\n")

        guard let dict = try? Yams.load(yaml: String(yaml)) as? [String: Any] else {
            return ([:], body)
        }

        var frontmatter: [String: String] = [:]
        for (k, v) in dict {
            frontmatter[k] = String(describing: v)
        }
        return (frontmatter, body)
    }
}
