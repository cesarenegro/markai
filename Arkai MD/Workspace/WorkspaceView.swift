import SwiftUI

struct WorkspaceView: View {
    @Environment(EditorState.self) private var editorState
    @Environment(VaultState.self) private var vault
    let controller: EditorController
    let onSave: () -> Void
    let onMakeSkill: () -> Void

    @State private var showInspector: Bool = true

    var body: some View {
        @Bindable var editorState = editorState
        NavigationSplitView {
            VaultSidebar(
                vault: vault,
                onSelectNote: { url in
                    selectNote(url)
                }
            )
            .frame(minWidth: 220)
        } detail: {
            HSplitView {
                EditorView(
                    controller: controller,
                    onSave: onSave,
                    onMakeSkill: onMakeSkill
                )

                if showInspector {
                    InspectorPane(
                        selectedNoteURL: vault.selectedNoteURL,
                        toggleInspector: { showInspector.toggle() }
                    )
                    .frame(minWidth: 220, idealWidth: 280, maxWidth: 420)
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    Button {
                        editorState.showGraphSheet = true
                    } label: {
                        Image(systemName: "circle.hexagongrid")
                    }
                    .help("Show Graph")

                    Button {
                        showInspector.toggle()
                    } label: {
                        Image(systemName: "sidebar.right")
                    }
                    .help(showInspector ? "Hide Inspector" : "Show Inspector")
                }
            }
        }
        .sheet(isPresented: $editorState.showGraphSheet) {
            GraphView()
        }
        .onAppear {
            vault.restoreVaultIfAvailable()
            if let url = vault.selectedNoteURL {
                selectNote(url)
            }
        }
        .onChange(of: vault.selectedNoteURL) { _, newValue in
            guard let url = newValue else { return }
            selectNote(url)
        }
    }

    private func selectNote(_ url: URL) {
        if editorState.isDirty, editorState.fileURL != nil {
            editorState.save()
        }
        editorState.open(url: url)
    }
}

private struct VaultSidebar: View {
    @Bindable var vault: VaultState
    let onSelectNote: (URL) -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    vault.openVaultPanel()
                } label: {
                    Label(vaultLabel, systemImage: "folder")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.plain)
                .help("Open Vault…")

                Spacer()

                Button {
                    vault.refreshIndex()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .help("Refresh Index")
            }

            TextField("Search", text: $vault.searchQuery)
                .textFieldStyle(.roundedBorder)

            List(selection: $vault.selectedNoteURL) {
                ForEach(vault.filteredNotes) { note in
                    Text(note.title)
                        .tag(note.url as URL?)
                }
            }
            .onChange(of: vault.selectedNoteURL) { _, newValue in
                guard let url = newValue else { return }
                onSelectNote(url)
            }
        }
        .padding(10)
    }

    private var vaultLabel: String {
        vault.vaultURL?.lastPathComponent ?? "Open Vault…"
    }
}

private struct InspectorPane: View {
    @Environment(EditorState.self) private var editorState
    @Environment(VaultState.self) private var vault

    let selectedNoteURL: URL?
    let toggleInspector: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Inspector")
                    .font(.headline)
                Spacer()
                Button(action: toggleInspector) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
            }

            if let selectedNoteURL {
                GroupBox("Properties") {
                    let frontmatter = FrontmatterExtractor.parse(from: editorState.content).frontmatter
                    if frontmatter.isEmpty {
                        Text("No frontmatter")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(frontmatter.keys.sorted(), id: \.self) { key in
                                HStack(alignment: .firstTextBaseline) {
                                    Text(key)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 90, alignment: .leading)
                                    Text(frontmatter[key] ?? "")
                                        .textSelection(.enabled)
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                GroupBox("Links") {
                    let outgoing = vault.outgoingLinks(from: editorState.content)
                    if outgoing.isEmpty {
                        Text("No links")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(outgoing, id: \.self) { key in
                                Button {
                                    if let target = vault.resolveWikiLinkTargetPath(for: key) {
                                        vault.selectedNoteURL = target
                                    }
                                } label: {
                                    Text("[[\(key)]]")
                                }
                                .buttonStyle(.link)
                                .disabled(vault.resolveWikiLinkTargetPath(for: key) == nil)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                GroupBox("Backlinks") {
                    let backlinks = vault.backlinks(to: selectedNoteURL)
                    if backlinks.isEmpty {
                        Text("No backlinks")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(backlinks) { note in
                                Button {
                                    vault.selectedNoteURL = note.url
                                } label: {
                                    Text(note.title)
                                }
                                .buttonStyle(.link)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                Text("No note selected")
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
    }
}
