import Foundation
import Down

enum MarkdownRenderer {
    static func render(
        _ markdown: String,
        wikiLinkResolver: ((String) -> URL?)? = nil,
        baseDirectory: URL? = nil
    ) -> String {
        do {
            let preprocessed = preprocessWikiLinks(in: markdown, wikiLinkResolver: wikiLinkResolver, baseDirectory: baseDirectory)
            let down = Down(markdownString: preprocessed)
            return try down.toHTML([.smartUnsafe, .unsafe])
        } catch {
            print("[MarkdownRenderer] render failed: \(error)")
            let escaped = markdown
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            return "<pre>\(escaped)</pre>"
        }
    }

    private static func preprocessWikiLinks(
        in markdown: String,
        wikiLinkResolver: ((String) -> URL?)?,
        baseDirectory: URL?
    ) -> String {
        let pattern = #"\[\[([^\]]+)\]\]"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return markdown }

        let ns = markdown as NSString
        let range = NSRange(location: 0, length: ns.length)
        let matches = regex.matches(in: markdown, options: [], range: range)
        guard !matches.isEmpty else { return markdown }

        var output = markdown
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2 else { continue }
            let raw = ns.substring(with: match.range(at: 1))
            let parts = raw.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: true)
            let targetRaw = parts.first.map(String.init) ?? raw
            let display = (parts.count > 1 ? String(parts[1]) : targetRaw)

            let fileURL: URL?
            if let wikiLinkResolver {
                fileURL = wikiLinkResolver(targetRaw)
            } else if let baseDirectory {
                fileURL = resolveWikiLink(targetRaw, in: baseDirectory)
            } else {
                fileURL = nil
            }

            guard let fileURL else { continue }

            var components = URLComponents()
            components.scheme = "arkaimd"
            components.host = "open"
            components.queryItems = [URLQueryItem(name: "path", value: fileURL.path)]
            guard let urlString = components.string else { continue }

            let replacement = "[\(display)](\(urlString))"
            if let swiftRange = Range(match.range, in: output) {
                output.replaceSubrange(swiftRange, with: replacement)
            }
        }

        return output
    }

    private static func resolveWikiLink(_ rawTarget: String, in baseDirectory: URL) -> URL? {
        let target = rawTarget.trimmingCharacters(in: .whitespacesAndNewlines)
        if target.isEmpty { return nil }

        if target.lowercased().hasSuffix(".md") || target.lowercased().hasSuffix(".markdown") {
            let url = baseDirectory.appendingPathComponent(target)
            return FileManager.default.fileExists(atPath: url.path) ? url : nil
        }

        let md = baseDirectory.appendingPathComponent(target).appendingPathExtension("md")
        if FileManager.default.fileExists(atPath: md.path) {
            return md
        }

        let markdown = baseDirectory.appendingPathComponent(target).appendingPathExtension("markdown")
        if FileManager.default.fileExists(atPath: markdown.path) {
            return markdown
        }

        return nil
    }
}
