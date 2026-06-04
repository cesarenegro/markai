import AppKit
import Foundation
import UniformTypeIdentifiers

@MainActor
enum SkillExporter {
    @discardableResult
    static func export(_ document: SkillDocument, format: SkillDocument.OutputFormat) -> URL? {
        switch format {
        case .singleFile: return exportSingleFile(document)
        case .folder:     return exportFolder(document)
        }
    }

    static func render(_ document: SkillDocument) -> String {
        var frontMatter = "---\n"
        frontMatter += "name: \(document.name)\n"
        frontMatter += "description: \(yamlInlineString(document.description))\n"
        if document.platform != .generic {
            frontMatter += "platform: \(document.platform.rawValue)\n"
        }
        if !document.tags.isEmpty {
            let items = document.tags.map { yamlInlineString($0) }.joined(separator: ", ")
            frontMatter += "tags: [\(items)]\n"
        }
        frontMatter += "---\n\n"
        return frontMatter + document.body + "\n"
    }

    private static func exportSingleFile(_ document: SkillDocument) -> URL? {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(document.name).skill.md"
        if let mdType = UTType(filenameExtension: "md") {
            panel.allowedContentTypes = [mdType]
        }
        panel.canCreateDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        do {
            try render(document).write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("[SkillExporter] single-file write failed: \(error)")
            return nil
        }
    }

    private static func exportFolder(_ document: SkillDocument) -> URL? {
        let open = NSOpenPanel()
        open.canChooseDirectories = true
        open.canChooseFiles = false
        open.allowsMultipleSelection = false
        open.canCreateDirectories = true
        open.prompt = "Create Here"
        open.message = "Skill folder “\(document.name)” will be created inside the chosen directory."
        guard open.runModal() == .OK, let parent = open.url else { return nil }
        let folder = parent.appendingPathComponent(document.name, isDirectory: true)
        let skill = folder.appendingPathComponent("SKILL.md")
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try render(document).write(to: skill, atomically: true, encoding: .utf8)
            return skill
        } catch {
            print("[SkillExporter] folder write failed: \(error)")
            return nil
        }
    }

    private static func yamlInlineString(_ value: String) -> String {
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: " ")
        return "\"\(escaped)\""
    }
}
