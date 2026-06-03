import Foundation
import Down

enum MarkdownRenderer {
    static func render(_ markdown: String) -> String {
        do {
            let down = Down(markdownString: markdown)
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
}
