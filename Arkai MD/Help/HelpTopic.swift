import Foundation

enum HelpTopic: String, CaseIterable, Identifiable, Hashable {
    case welcome
    case editor
    case formatting
    case preview
    case diagrams
    case skills
    case enhance
    case themes
    case settings
    case integration
    case shortcuts
    case privacy
    case troubleshooting
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .welcome:         return "Welcome"
        case .editor:          return "The Editor"
        case .formatting:      return "Formatting Markdown"
        case .preview:         return "Live Preview"
        case .diagrams:        return "Mermaid Diagrams"
        case .skills:          return "Creating Agent Skills"
        case .enhance:         return "Enhance with AI"
        case .themes:          return "Themes"
        case .settings:        return "Settings"
        case .integration:     return "macOS Integration"
        case .shortcuts:       return "Keyboard Shortcuts"
        case .privacy:         return "Privacy & Security"
        case .troubleshooting: return "Troubleshooting"
        case .about:           return "About & Credits"
        }
    }

    var icon: String {
        switch self {
        case .welcome:         return "sparkles"
        case .editor:          return "doc.text"
        case .formatting:      return "textformat"
        case .preview:         return "eye"
        case .diagrams:        return "chart.line.uptrend.xyaxis"
        case .skills:          return "wand.and.stars"
        case .enhance:         return "brain"
        case .themes:          return "paintbrush"
        case .settings:        return "gear"
        case .integration:     return "macwindow.on.rectangle"
        case .shortcuts:       return "command"
        case .privacy:         return "lock.shield"
        case .troubleshooting: return "wrench.adjustable"
        case .about:           return "info.circle"
        }
    }

    var groupTitle: String {
        switch self {
        case .welcome, .editor, .formatting:        return "Basics"
        case .preview, .diagrams:                   return "Preview & Diagrams"
        case .skills, .enhance:                     return "Agent Skills"
        case .themes, .settings, .integration:      return "Customization"
        case .shortcuts, .privacy:                  return "Reference"
        case .troubleshooting, .about:              return "Help & Info"
        }
    }

    static var groups: [(name: String, topics: [HelpTopic])] {
        let ordered: [HelpTopic] = allCases
        let groupOrder = ["Basics", "Preview & Diagrams", "Agent Skills", "Customization", "Reference", "Help & Info"]
        return groupOrder.map { name in
            (name, ordered.filter { $0.groupTitle == name })
        }
    }
}
