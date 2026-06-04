import AppKit
import SwiftUI

struct MarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String
    let controller: EditorController
    let theme: AppTheme

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.allowsUndo = true
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.textContainerInset = NSSize(width: 8, height: 8)

        textView.string = text
        controller.textView = textView
        applyTheme(to: textView, scrollView: scrollView)
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            let selection = textView.selectedRange()
            textView.string = text
            let clamped = min(selection.location, (text as NSString).length)
            textView.selectedRange = NSRange(location: clamped, length: 0)
        }
        if controller.textView !== textView {
            controller.textView = textView
        }
        applyTheme(to: textView, scrollView: scrollView)
    }

    private func applyTheme(to textView: NSTextView, scrollView: NSScrollView) {
        if let bg = theme.backgroundNSColor {
            textView.drawsBackground = true
            textView.backgroundColor = bg
            scrollView.drawsBackground = true
            scrollView.backgroundColor = bg
        } else {
            textView.drawsBackground = false
            scrollView.drawsBackground = false
        }

        if let fg = theme.foregroundNSColor {
            textView.textColor = fg
            textView.insertionPointColor = theme.accentNSColor ?? fg
            let selBg = fg.withAlphaComponent(0.25)
            textView.selectedTextAttributes = [
                .backgroundColor: selBg,
                .foregroundColor: fg
            ]
        } else {
            textView.textColor = nil
            textView.insertionPointColor = NSColor.textColor
            textView.selectedTextAttributes = [:]
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let new = textView.string
            if new != text { text = new }
        }
    }
}
