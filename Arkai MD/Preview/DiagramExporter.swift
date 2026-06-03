import AppKit
import UniformTypeIdentifiers

@MainActor
enum DiagramExporter {
    static func exportSVG(_ svg: String) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = UTType(filenameExtension: "svg").map { [$0] } ?? []
        panel.nameFieldStringValue = "diagram.svg"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try svg.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("[DiagramExporter] svg write failed: \(error)")
        }
    }

    static func exportPNG(_ data: Data) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "diagram.png"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try data.write(to: url)
        } catch {
            print("[DiagramExporter] png write failed: \(error)")
        }
    }
}
