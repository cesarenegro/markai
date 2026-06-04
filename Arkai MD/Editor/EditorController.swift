import AppKit
import Foundation

@MainActor
final class EditorController {
    weak var textView: NSTextView?

    func bold()           { toggleWrap(prefix: "**") }
    func italic()         { toggleWrap(prefix: "*") }
    func strikethrough()  { toggleWrap(prefix: "~~") }
    func inlineCode()     { toggleWrap(prefix: "`") }

    func link() {
        guard let tv = textView else { return }
        let nsText = tv.string as NSString
        let range = tv.selectedRange()
        let selected = nsText.substring(with: range)
        let label = selected.isEmpty ? "text" : selected
        let replacement = "[\(label)](url)"
        tv.insertText(replacement, replacementRange: range)
        let urlStart = range.location + (label as NSString).length + 3
        tv.selectedRange = NSRange(location: urlStart, length: 3)
    }

    func heading(_ level: Int) {
        transformLines { line in
            let stripped = line.replacingOccurrences(of: "^#{1,6}\\s+", with: "", options: .regularExpression)
            if level == 0 { return stripped }
            return String(repeating: "#", count: level) + " " + stripped
        }
    }

    func blockQuote() {
        transformLines { line in
            if line.hasPrefix("> ") { return String(line.dropFirst(2)) }
            return "> " + line
        }
    }

    func unorderedList() {
        transformLines { line in
            if line.range(of: "^- (?!\\[)", options: .regularExpression) != nil {
                return line.replacingOccurrences(of: "^- ", with: "", options: .regularExpression)
            }
            let stripped = line.replacingOccurrences(
                of: "^(\\d+\\. |- \\[[ xX]\\] )",
                with: "",
                options: .regularExpression
            )
            return "- " + stripped
        }
    }

    func orderedList() {
        var counter = 1
        let lines = currentLineSlice()
        let allOrdered = lines.allSatisfy {
            $0.range(of: "^\\d+\\. ", options: .regularExpression) != nil || $0.isEmpty
        }
        if allOrdered {
            transformLines { line in
                line.replacingOccurrences(of: "^\\d+\\. ", with: "", options: .regularExpression)
            }
            return
        }
        transformLines { line in
            let stripped = line.replacingOccurrences(
                of: "^(- \\[[ xX]\\] |- |\\d+\\. )",
                with: "",
                options: .regularExpression
            )
            let result = "\(counter). \(stripped)"
            counter += 1
            return result
        }
    }

    func taskList() {
        transformLines { line in
            if line.range(of: "^- \\[[ xX]\\] ", options: .regularExpression) != nil {
                return line.replacingOccurrences(of: "^- \\[[ xX]\\] ", with: "", options: .regularExpression)
            }
            let stripped = line.replacingOccurrences(
                of: "^(\\d+\\. |- )",
                with: "",
                options: .regularExpression
            )
            return "- [ ] " + stripped
        }
    }

    func horizontalRule() {
        guard let tv = textView else { return }
        let nsText = tv.string as NSString
        let selRange = tv.selectedRange()
        let lineRange = nsText.lineRange(for: selRange)
        let insertLocation = lineRange.location + lineRange.length
        let prefix = (insertLocation > 0 && nsText.character(at: insertLocation - 1) == 0x0A) ? "" : "\n"
        let insertion = "\(prefix)---\n"
        tv.insertText(insertion, replacementRange: NSRange(location: insertLocation, length: 0))
    }

    private func toggleWrap(prefix: String, suffix: String? = nil) {
        guard let tv = textView else { return }
        let suffix = suffix ?? prefix
        let nsText = tv.string as NSString
        let range = tv.selectedRange()
        let selected = nsText.substring(with: range)

        let prefixLen = (prefix as NSString).length
        let suffixLen = (suffix as NSString).length

        if range.length >= prefixLen + suffixLen,
           selected.hasPrefix(prefix), selected.hasSuffix(suffix) {
            let unwrapped = String(selected.dropFirst(prefix.count).dropLast(suffix.count))
            tv.insertText(unwrapped, replacementRange: range)
            tv.selectedRange = NSRange(location: range.location, length: (unwrapped as NSString).length)
            return
        }

        let replacement = "\(prefix)\(selected)\(suffix)"
        tv.insertText(replacement, replacementRange: range)
        if range.length == 0 {
            tv.selectedRange = NSRange(location: range.location + prefixLen, length: 0)
        } else {
            tv.selectedRange = NSRange(location: range.location + prefixLen, length: range.length)
        }
    }

    private func transformLines(_ transform: (String) -> String) {
        guard let tv = textView else { return }
        let nsText = tv.string as NSString
        let selRange = tv.selectedRange()
        let lineRange = nsText.lineRange(for: selRange)
        let chunk = nsText.substring(with: lineRange)
        let hasTrailingNewline = chunk.hasSuffix("\n")
        let content = hasTrailingNewline ? String(chunk.dropLast()) : chunk
        let parts = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let transformed = parts.map(transform).joined(separator: "\n")
        let result = hasTrailingNewline ? transformed + "\n" : transformed
        tv.insertText(result, replacementRange: lineRange)
        tv.selectedRange = NSRange(location: lineRange.location, length: (result as NSString).length)
    }

    private func currentLineSlice() -> [String] {
        guard let tv = textView else { return [] }
        let nsText = tv.string as NSString
        let lineRange = nsText.lineRange(for: tv.selectedRange())
        let chunk = nsText.substring(with: lineRange)
        let content = chunk.hasSuffix("\n") ? String(chunk.dropLast()) : chunk
        return content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    }
}
