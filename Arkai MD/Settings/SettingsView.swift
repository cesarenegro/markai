import AppKit
import CoreServices
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    var body: some View {
        TabView {
            AppearancePane()
                .tabItem { Label("Appearance", systemImage: "paintbrush") }
            DefaultAppPane()
                .tabItem { Label("Default App", systemImage: "doc.text") }
            APIKeysPane()
                .tabItem { Label("AI", systemImage: "sparkles") }
        }
        .frame(width: 560, height: 380)
    }
}

// MARK: - Appearance

private struct AppearancePane: View {
    @AppStorage("appTheme") private var themeID: String = AppTheme.system.id

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Theme")
                    .font(.headline)
                Text("Choose a palette for the editor. Bars and preview adapt automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AppTheme.all) { theme in
                        ThemeSwatch(theme: theme, isSelected: theme.id == themeID)
                            .onTapGesture { themeID = theme.id }
                    }
                }
            }
            .padding(20)
        }
    }
}

private struct ThemeSwatch: View {
    let theme: AppTheme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomLeading) {
                preview
                    .frame(height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.accentColor : Color.secondary.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white, Color.accentColor)
                        .padding(6)
                        .font(.title3)
                }
            }
            Text(theme.displayName)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private var preview: some View {
        if theme.isSystem {
            HStack(spacing: 0) {
                Color(NSColor.windowBackgroundColor)
                Color(NSColor.controlBackgroundColor)
            }
            .overlay(
                Text("System")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
            )
        } else {
            ZStack {
                theme.backgroundColor ?? Color.gray
                VStack(alignment: .leading, spacing: 4) {
                    Text("Aa")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundStyle(theme.foregroundColor ?? .primary)
                    HStack(spacing: 4) {
                        Circle().fill(theme.primaryColor).frame(width: 10, height: 10)
                        if let accent = theme.accentColor {
                            Circle().fill(accent).frame(width: 10, height: 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(8)
            }
        }
    }
}

// MARK: - Default App

private struct DefaultAppPane: View {
    @State private var rows: [DefaultAppEntry] = []

    private static let entries: [(label: String, identifier: String)] = [
        ("Markdown (.md)", "net.daringfireball.markdown"),
        ("AI Skill (.skill.md)", "com.arkitecna.markai.skill"),
        ("Plain Text (.txt)", "public.plain-text")
    ]

    var body: some View {
        Form {
            Section {
                Label(
                    "macOS doesn’t allow sandboxed apps to set themselves as the default for file types — it’s a system restriction, not a bug in mARK.AI. Use the Finder workflow below.",
                    systemImage: "info.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Section {
                ForEach(rows) { row in
                    DefaultAppRow(row: row)
                }
            } header: {
                Text("Current default app").font(.subheadline)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How to make mARK.AI the default for .md files").font(.subheadline.bold())
                    HStack(alignment: .top) {
                        Text("1.").bold()
                        Text("Click the button below to pick a .md file (you’ll then see it highlighted in Finder)")
                    }
                    HStack(alignment: .top) {
                        Text("2.").bold()
                        Text("In Finder, right-click on the file → Get Info (⌘I)")
                    }
                    HStack(alignment: .top) {
                        Text("3.").bold()
                        Text("In the “Open with:” section, choose mARK.AI")
                    }
                    HStack(alignment: .top) {
                        Text("4.").bold()
                        Text("Click “Change All…” → confirm. From now on, every .md file opens in mARK.AI.")
                    }
                }
                .font(.caption)

                HStack {
                    Spacer()
                    Button { pickAndReveal() } label: {
                        Label("Choose .md file…", systemImage: "doc.text.magnifyingglass")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding(16)
        .onAppear { refresh() }
    }

    private func refresh() {
        rows = Self.entries.compactMap { item in
            guard let type = UTType(item.identifier) else { return nil }
            let currentURL = NSWorkspace.shared.urlForApplication(toOpen: type)
            let bundleID = Bundle.main.bundleIdentifier ?? ""
            let mine = currentURL.flatMap { Bundle(url: $0)?.bundleIdentifier } == bundleID
            return DefaultAppEntry(
                id: item.identifier,
                label: item.label,
                contentType: type,
                currentApp: currentURL.flatMap(AppInfo.init),
                isMine: mine
            )
        }
    }

    private func pickAndReveal() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        if let mdType = UTType("net.daringfireball.markdown") {
            panel.allowedContentTypes = [mdType, .plainText]
        }
        panel.prompt = "Select"
        panel.message = "Pick any .md file. It will be revealed in Finder so you can right-click → Get Info."
        guard panel.runModal() == .OK, let url = panel.url else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}

private struct DefaultAppEntry: Identifiable {
    let id: String
    let label: String
    let contentType: UTType
    let currentApp: AppInfo?
    let isMine: Bool
}

private struct AppInfo {
    let name: String
    let icon: NSImage

    init?(url: URL) {
        let bundle = Bundle(url: url)
        let name = bundle?.infoDictionary?["CFBundleDisplayName"] as? String
            ?? bundle?.infoDictionary?["CFBundleName"] as? String
            ?? url.deletingPathExtension().lastPathComponent
        self.name = name
        self.icon = NSWorkspace.shared.icon(forFile: url.path)
    }
}

private struct DefaultAppRow: View {
    let row: DefaultAppEntry

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.label)
                    .font(.body)
                HStack(spacing: 4) {
                    if let app = row.currentApp {
                        Image(nsImage: app.icon)
                            .resizable()
                            .frame(width: 14, height: 14)
                        Text(app.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("No default")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
            if row.isMine {
                Label("mARK.AI", systemImage: "checkmark.seal.fill")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(.green)
                    .font(.caption.bold())
            }
        }
    }
}

// MARK: - AI

private struct APIKeysPane: View {
    @State private var newKey: String = ""
    @State private var savedKeyMasked: String = ""
    @State private var feedback: String?

    var body: some View {
        Form {
            Section("Anthropic Claude") {
                if savedKeyMasked.isEmpty {
                    SecureField("sk-ant-…", text: $newKey, prompt: Text("Paste your API key"))
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Spacer()
                        Button("Save Key") { saveKey() }
                            .disabled(newKey.isEmpty)
                            .keyboardShortcut(.return, modifiers: .command)
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text(savedKeyMasked)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Replace") {
                            APIKeyStore.remove()
                            refresh()
                        }
                        Button("Remove", role: .destructive) {
                            APIKeyStore.remove()
                            refresh()
                            feedback = "Key removed from Keychain."
                        }
                    }
                }

                if let feedback {
                    Text(feedback)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Stored in macOS Keychain. Used only when you click ‘Enhance with AI’ in Create Skill. Get yours at console.anthropic.com.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .padding(16)
        .onAppear { refresh() }
    }

    private func saveKey() {
        let trimmed = newKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let ok = APIKeyStore.set(trimmed)
        if ok {
            newKey = ""
            feedback = "Key saved."
            refresh()
        } else {
            feedback = "Failed to save key to Keychain — check console for details."
        }
    }

    private func refresh() {
        if let key = APIKeyStore.get() {
            savedKeyMasked = APIKeyStore.mask(key)
        } else {
            savedKeyMasked = ""
        }
    }
}

#Preview {
    SettingsView()
}
