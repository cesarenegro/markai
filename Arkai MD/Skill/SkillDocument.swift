import Foundation

struct SkillDocument: Equatable {
    var name: String
    var description: String
    var platform: Platform
    var tags: [String]
    var body: String
    var rawSource: String = ""

    enum Platform: String, CaseIterable, Identifiable {
        case claude
        case gemini
        case generic

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .claude:  return "Claude (Anthropic SKILL.md)"
            case .gemini:  return "Gemini (Google Gems)"
            case .generic: return "Generic AGENTS.md"
            }
        }
    }

    enum OutputFormat: String, CaseIterable, Identifiable {
        case singleFile
        case folder

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .singleFile: return "Single .skill.md file (portable)"
            case .folder:     return "Folder with SKILL.md (drop-in for ~/.claude/skills/)"
            }
        }
    }
}
