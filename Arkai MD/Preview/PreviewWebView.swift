import SwiftUI
import WebKit

enum ExportFormat: String {
    case svg, png
}

struct PreviewWebView: NSViewRepresentable {
    let renderedHTML: String

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(context.coordinator, name: "exportDiagram")
        config.userContentController = controller

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        if #available(macOS 13.3, *) {
            webView.isInspectable = true
        }
        context.coordinator.webView = webView
        context.coordinator.pendingHTML = renderedHTML

        if let url = Bundle.main.url(forResource: "preview", withExtension: "html"),
           let baseURL = Bundle.main.resourceURL {
            webView.loadFileURL(url, allowingReadAccessTo: baseURL)
        } else {
            print("[PreviewWebView] preview.html missing from app bundle")
        }
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingHTML = renderedHTML
        if context.coordinator.isPageLoaded {
            context.coordinator.injectPendingHTML()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    @MainActor
    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        weak var webView: WKWebView?
        var pendingHTML: String?
        var isPageLoaded = false
        var lastInjectedHTML: String?

        nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isPageLoaded = true
                self.injectPendingHTML()
            }
        }

        nonisolated func webView(_ webView: WKWebView,
                                 didFail navigation: WKNavigation!,
                                 withError error: Error) {
            print("[PreviewWebView] navigation failed: \(error)")
        }

        nonisolated func webView(_ webView: WKWebView,
                                 decidePolicyFor navigationAction: WKNavigationAction,
                                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated,
               let url = navigationAction.request.url {
                Task { @MainActor in NSWorkspace.shared.open(url) }
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func injectPendingHTML() {
            guard let webView, let html = pendingHTML, html != lastInjectedHTML else { return }
            guard let encoded = jsonEncode(html) else { return }
            lastInjectedHTML = html
            let js = "window.__renderMarkdown(\(encoded));"
            webView.evaluateJavaScript(js) { _, error in
                if let error {
                    print("[PreviewWebView] injection failed: \(error)")
                }
            }
        }

        private func jsonEncode(_ string: String) -> String? {
            guard let data = try? JSONSerialization.data(withJSONObject: [string], options: []),
                  let array = String(data: data, encoding: .utf8) else { return nil }
            let start = array.index(after: array.startIndex)
            let end = array.index(before: array.endIndex)
            return String(array[start..<end])
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            guard message.name == "exportDiagram",
                  let dict = message.body as? [String: Any],
                  let formatRaw = dict["format"] as? String,
                  let format = ExportFormat(rawValue: formatRaw)
            else { return }
            switch format {
            case .svg:
                if let svg = dict["svg"] as? String {
                    DiagramExporter.exportSVG(svg)
                }
            case .png:
                if let base64 = dict["pngBase64"] as? String,
                   let data = Data(base64Encoded: base64) {
                    DiagramExporter.exportPNG(data)
                }
            }
        }
    }
}
