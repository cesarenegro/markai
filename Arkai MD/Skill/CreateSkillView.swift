import SwiftUI

struct CreateSkillView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var document: SkillDocument
    @State private var outputFormat: SkillDocument.OutputFormat = .singleFile
    @State private var tagsInput: String
    @State private var isEnhancing = false
    @State private var enhanceError: String?

    init(initial: SkillDocument) {
        _document = State(initialValue: initial)
        _tagsInput = State(initialValue: initial.tags.joined(separator: ", "))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            Form {
                Section {
                    TextField("Name", text: $document.name, prompt: Text("kebab-case-skill-name"))
                        .help("Lowercase letters, numbers, hyphens only. Max 64 chars.")

                    TextField("Description", text: $document.description, axis: .vertical)
                        .lineLimit(2...4)
                        .help("Max 1024 chars. Format: what it does + when to use it.")

                    Picker("Platform", selection: $document.platform) {
                        ForEach(SkillDocument.Platform.allCases) { platform in
                            Text(platform.displayName).tag(platform)
                        }
                    }

                    TextField("Tags", text: $tagsInput, prompt: Text("comma, separated, tags"))

                    Picker("Output", selection: $outputFormat) {
                        ForEach(SkillDocument.OutputFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                }

                Section("Body preview") {
                    ScrollView {
                        Text(bodyPreview)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(height: 110)
                    .background(.quaternary.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .formStyle(.grouped)

            if let warning = validationWarning {
                Label(warning, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            if let err = enhanceError {
                Label(err, systemImage: "xmark.octagon.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(4)
            }

            HStack {
                enhanceButton
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save…") { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(blockingError != nil || isEnhancing)
            }
        }
        .padding(20)
        .frame(width: 580, height: 640)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Create Agent Skill")
                .font(.title2)
                .bold()
            Text("Generate a reusable skill for Claude, Gemini, or generic agents. The scaffold provides the structure — fill in the TODO sections, or click ‘Enhance with AI’ if you have an API key configured.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var enhanceButton: some View {
        if APIKeyStore.hasKey {
            Button {
                Task { await enhance() }
            } label: {
                if isEnhancing {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Enhancing…")
                    }
                } else {
                    Label("Enhance with AI", systemImage: "sparkles")
                }
            }
            .disabled(isEnhancing || document.rawSource.isEmpty)
            .help("Send the source material to Claude and generate a structured skill")
        } else {
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                Text("Add Claude API key in Settings to enable AI enhancement.")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var bodyPreview: String {
        let lines = document.body.components(separatedBy: .newlines)
        return lines.prefix(10).joined(separator: "\n")
    }

    private var blockingError: String? {
        if document.name.isEmpty { return "Name is required" }
        if !SkillBuilder.validateName(document.name) {
            return "Name must contain only lowercase letters, numbers and hyphens (max 64)"
        }
        if document.description.isEmpty { return "Description is required" }
        if document.description.count > 1024 {
            return "Description max 1024 chars (currently \(document.description.count))"
        }
        return nil
    }

    private var validationWarning: String? {
        if let err = blockingError { return err }
        let bodyLines = document.body.components(separatedBy: .newlines).count
        if bodyLines > 500 {
            return "Body is \(bodyLines) lines — Anthropic recommends ≤ 500 for performance."
        }
        return nil
    }

    private func enhance() async {
        guard let key = APIKeyStore.get(), !document.rawSource.isEmpty else { return }
        isEnhancing = true
        enhanceError = nil
        defer { isEnhancing = false }
        do {
            let enhanced = try await SkillEnhancer.enhance(
                rawSource: document.rawSource,
                platform: document.platform,
                apiKey: key
            )
            document.name = enhanced.name
            document.description = enhanced.description
            document.body = enhanced.body
        } catch {
            enhanceError = error.localizedDescription
        }
    }

    private func save() {
        document.tags = tagsInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let snapshot = document
        let format = outputFormat
        dismiss()
        Task { @MainActor in
            SkillExporter.export(snapshot, format: format)
        }
    }
}

#Preview {
    CreateSkillView(initial: SkillDocument(
        name: "example-skill",
        description: "Demonstrates the create-skill dialog. Use when previewing the modal layout in Xcode.",
        platform: .claude,
        tags: ["demo"],
        body: "# Example Skill\n\nThis is the body of the skill.\n",
        rawSource: "Some raw source material"
    ))
}
