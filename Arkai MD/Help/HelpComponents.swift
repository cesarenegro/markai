import SwiftUI

struct H1: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 26, weight: .bold))
            .padding(.bottom, 4)
    }
}

struct H2: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold))
            .padding(.top, 14)
            .padding(.bottom, 2)
    }
}

struct H3: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .padding(.top, 8)
    }
}

struct P: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(.init(text))
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct Bullet: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
                .frame(width: 10, alignment: .leading)
            Text(.init(text))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct Numbered: View {
    let n: Int
    let text: String
    init(_ n: Int, _ text: String) { self.n = n; self.text = text }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(n).")
                .foregroundStyle(.secondary)
                .frame(width: 18, alignment: .leading)
            Text(.init(text))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct InlineCode: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(Color.secondary.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

struct CodeBlock: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(.callout, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.secondary.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct Callout: View {
    let symbol: String
    let title: String
    let message: String
    let tint: Color

    init(symbol: String, title: String, message: String, tint: Color) {
        self.symbol = symbol; self.title = title; self.message = message; self.tint = tint
    }

    static func tip(_ message: String) -> Callout {
        .init(symbol: "lightbulb.fill", title: "Tip", message: message, tint: .yellow)
    }
    static func note(_ message: String) -> Callout {
        .init(symbol: "info.circle.fill", title: "Note", message: message, tint: .blue)
    }
    static func warning(_ message: String) -> Callout {
        .init(symbol: "exclamationmark.triangle.fill", title: "Warning", message: message, tint: .orange)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: symbol)
                .foregroundStyle(tint)
                .font(.body.weight(.semibold))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(.init(message))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .background(tint.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct ShortcutRow: View {
    let label: String
    let shortcut: String
    init(_ label: String, _ shortcut: String) { self.label = label; self.shortcut = shortcut }
    var body: some View {
        HStack {
            Text(.init(label))
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct ExternalLink: View {
    let title: String
    let url: String
    init(_ title: String, _ url: String) { self.title = title; self.url = url }
    var body: some View {
        Button {
            if let u = URL(string: url) {
                NSWorkspace.shared.open(u)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right.square")
                Text(title)
            }
        }
        .buttonStyle(.link)
    }
}

struct TopicLink: View {
    let topic: HelpTopic
    @Binding var selection: HelpTopic

    var body: some View {
        Button {
            selection = topic
        } label: {
            HStack(spacing: 4) {
                Image(systemName: topic.icon)
                Text(topic.title)
            }
        }
        .buttonStyle(.link)
    }
}
