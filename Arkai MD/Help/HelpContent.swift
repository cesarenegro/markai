import SwiftUI

struct HelpContent: View {
    let topic: HelpTopic
    @Binding var selection: HelpTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            switch topic {
            case .welcome:         welcome
            case .editor:          editor
            case .formatting:      formatting
            case .preview:         preview
            case .diagrams:        diagrams
            case .skills:          skills
            case .enhance:         enhance
            case .themes:          themes
            case .settings:        settings
            case .integration:     integration
            case .shortcuts:       shortcuts
            case .privacy:         privacy
            case .troubleshooting: troubleshooting
            case .about:           about
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Welcome
    @ViewBuilder private var welcome: some View {
        H1("Welcome to mARK.AI")
        P("mARK.AI is a focused Markdown editor for macOS — for people who turn raw text into knowledge, and increasingly, into reusable skills for AI agents.")
        P("Everything is **local-first**. Nothing leaves your machine unless you explicitly ask for it. There are no accounts, no telemetry, no in-app browser.")

        H2("What you get")
        Bullet("A distraction-free Markdown editor with live preview")
        Bullet("Mermaid diagram rendering with one-click SVG / PNG export")
        Bullet("A “Make Skill” builder that converts any document into a structured Anthropic SKILL.md or generic AGENTS.md")
        Bullet("8 carefully calibrated themes, system-aware")
        Bullet("Native macOS Services for right-click conversion in any app")

        H2("Where to start")
        HStack(spacing: 14) {
            TopicLink(topic: .editor, selection: $selection)
            TopicLink(topic: .skills, selection: $selection)
            TopicLink(topic: .themes, selection: $selection)
        }
        .padding(.top, 4)

        Callout.tip("Press ⌘? from anywhere in the app to open this help. Press ⌘/ to see every keyboard shortcut at a glance.")
    }

    // MARK: - Editor
    @ViewBuilder private var editor: some View {
        H1("The Editor")
        P("The editor has two modes: **Source** (plain Markdown) and **Preview** (rendered HTML with diagrams). Use the segmented control at the top of the window or press ⇧⌘P to switch.")

        H2("Source mode")
        P("Monospaced text editor with native macOS Find bar (⌘F), undo/redo, smart paste, and word selection. No smart quote substitution — Markdown punctuation is preserved as you type.")

        H2("Preview mode")
        P("Markdown is rendered to HTML by the Down library (CommonMark) inside a sandboxed WKWebView. Mermaid code blocks become diagrams. Links open in your default browser.")

        H2("Status bar")
        P("At the bottom: current filename, live word count, and an auto-save indicator.")
        Bullet("**editing…** — the document has unsaved changes")
        Bullet("**saved Xs ago** — last successful save")
        Bullet("— — — no file URL yet (Save As first)")

        H2("Auto-save")
        P("Every 2 seconds, if the document has been modified and has a file URL, mARK.AI writes the file atomically. For new documents you must use **Save As…** (⇧⌘S) first.")

        Callout.note("Auto-save uses an atomic write — your file is never partially written even on power loss.")
    }

    // MARK: - Formatting
    @ViewBuilder private var formatting: some View {
        H1("Formatting Markdown")
        P("Every Markdown action is reachable from three places: the **Format** menu, the **Format Bar** above the editor, and a keyboard shortcut. All actions **toggle** — press the shortcut again on the same selection to remove the wrap.")

        H2("Inline")
        VStack(spacing: 0) {
            ShortcutRow("Bold (`**text**`)", "⌘B")
            ShortcutRow("Italic (`*text*`)", "⌘I")
            ShortcutRow("Strikethrough (`~~text~~`)", "⇧⌘X")
            ShortcutRow("Inline Code (`` `code` ``)", "⌘E")
            ShortcutRow("Link (`[text](url)`)", "⌘K")
        }

        H2("Headings")
        P("Heading shortcuts work on the **entire line(s)** containing your cursor — no need to select.")
        VStack(spacing: 0) {
            ShortcutRow("Heading 1–6", "⌘1 … ⌘6")
            ShortcutRow("Paragraph (remove heading)", "⌘0")
        }

        H2("Blocks")
        VStack(spacing: 0) {
            ShortcutRow("Block Quote (`> `)", "⌃⌘Q")
            ShortcutRow("Unordered List (`- `)", "⇧⌘8")
            ShortcutRow("Ordered List (`1. `)", "⇧⌘7")
            ShortcutRow("Task List (`- [ ] `)", "⇧⌘T")
            ShortcutRow("Horizontal Rule (`---`)", "⌘-")
        }

        H2("The Format Bar")
        P("Sitting just above the editor in Source mode, the format bar exposes the same actions as icon buttons. Hide it with **View → Hide Format Bar** (⌥⌘B) for a cleaner writing surface.")

        Callout.tip("List shortcuts cycle: pressing the same list type again on the same line removes the prefix. This lets you toggle list / no-list without retyping.")
    }

    // MARK: - Preview
    @ViewBuilder private var preview: some View {
        H1("Live Preview")
        P("The preview pane renders your Markdown as HTML in a sandboxed WKWebView. Everything you see is generated locally — there is no remote rendering, no telemetry.")

        H2("Toggle")
        P("Press ⇧⌘P or use the **Source / Preview** segmented control at the top of the window.")

        H2("Live updates")
        P("The preview re-renders as you type. There is no manual refresh button — every keystroke updates the rendered output (debounced internally to remain smooth on large documents).")

        H2("Links")
        P("Click any link in the preview to open it in your default browser. mARK.AI never embeds a browser in-app for security and privacy.")

        H2("Theme behavior")
        P("Preview always follows your **system** appearance (light or dark). Custom themes affect the editor surface only — keeping the preview faithful to how readers will see exported HTML elsewhere.")

        TopicLink(topic: .diagrams, selection: $selection)
    }

    // MARK: - Diagrams
    @ViewBuilder private var diagrams: some View {
        H1("Mermaid Diagrams")
        P("mARK.AI ships with Mermaid.js bundled locally. Any fenced code block tagged `mermaid` is rendered as a live diagram in the preview.")

        H2("Basic syntax")
        CodeBlock("```mermaid\ngraph TD\n    A[Start] --> B{Decision}\n    B -->|Yes| C[OK]\n    B -->|No| D[KO]\n```")

        H2("Supported diagram types")
        Bullet("`graph` / `flowchart` — flow diagrams")
        Bullet("`sequenceDiagram` — sequence / interaction")
        Bullet("`classDiagram` — UML-style classes")
        Bullet("`stateDiagram` / `stateDiagram-v2` — state machines")
        Bullet("`erDiagram` — entity-relationship")
        Bullet("`gantt`, `pie`, `mindmap`, `timeline`, `quadrantChart`, `journey`")

        H2("Smart detection of embedded mermaid")
        P("AI tools often hand you a complete `.md` file wrapped inside a `python`, `text`, or `bash` code block. Markdown forbids nested fences, so the inner `mermaid` block becomes plain text and won't render.")
        P("mARK.AI detects this and shows a small **“Render as diagram”** button above the offending code block. Click it to render the embedded diagram in place — without modifying your source.")
        Callout.tip("Detection also fires for code blocks whose first line looks like mermaid syntax (`graph TD`, `flowchart LR`, `sequenceDiagram`, etc.), even when the fence has no language tag.")

        H2("Export")
        P("Hover a rendered diagram to reveal a toolbar in the top-right with two actions:")
        Bullet("**SVG** — exports a vector `.svg` file using the live SVG produced by Mermaid. Open in any vector tool (Sketch, Illustrator, browser).")
        Bullet("**PNG** — rasterizes the diagram via the WebView's Canvas API at 2× and exports a `.png` with a solid white background. Quality is preserved (fonts, fills, strokes) because rendering happens in the browser engine, not in Cocoa.")

        Callout.note("PNG export is canvas-based on purpose — macOS's NSImage SVG renderer ignores CSS class selectors, producing broken output (black blobs, missing text). The browser engine gets it right.")
    }

    // MARK: - Skills
    @ViewBuilder private var skills: some View {
        H1("Creating Agent Skills")
        P("An **agent skill** is a reusable file that teaches an AI agent how to handle a specific kind of task. It is operational, not documental — it tells the agent *what to do*, *when*, and what to avoid.")

        H2("SKILL.md vs AGENTS.md")
        P("Two related but different standards:")
        Bullet("**Anthropic SKILL.md** — a portable skill with a YAML front-matter (`name`, `description`) and a structured body. Drop it into `~/.claude/skills/<name>/SKILL.md`.")
        Bullet("**AGENTS.md** — Linux Foundation standard. A README-for-agents at the root of a project, describing build commands, code style, conventions. Read by Claude Code, Codex, Cursor, etc.")
        P("mARK.AI's Make Skill produces files compatible with both — pick the **Platform** in the modal.")

        H2("Make Skill workflow")
        Numbered(1, "Paste or open a source document (web page, PDF text, raw notes)")
        Numbered(2, "Press **Make Skill** in the top bar — or ⇧⌘A — or use the File menu")
        Numbered(3, "Review the auto-extracted name, description, platform, and output format")
        Numbered(4, "Optionally click **✨ Enhance with AI** to have Claude restructure the body for you")
        Numbered(5, "Click **Save…** — choose single `.skill.md` file or folder with `SKILL.md` inside")

        H2("The scaffold")
        P("Without AI enhancement, mARK.AI generates a scaffolded body with the official Anthropic structure already in place:")
        CodeBlock("# <Title>\n\nYou are an expert at <TODO>…\n\n## When to use this skill\n## How to apply\n## Examples\n## Boundaries\n## Reference material  ← your imported content")
        P("You fill in the TODOs manually. This takes 5 minutes and produces a real skill — much better than dumping raw text and calling it a skill.")

        H2("Output formats")
        Bullet("**Single file** — `<name>.skill.md` with YAML front-matter. Portable, email-friendly.")
        Bullet("**Folder** — creates `<name>/SKILL.md`. Drop-in ready for `~/.claude/skills/`.")

        ExternalLink("Anthropic SKILL.md best practices", "https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices")

        TopicLink(topic: .enhance, selection: $selection)
    }

    // MARK: - Enhance with AI
    @ViewBuilder private var enhance: some View {
        H1("Enhance with AI")
        P("Manual scaffolding produces a usable skill. **Enhance with AI** turns it into a polished one by sending your source content to Claude, with a prompt that enforces Anthropic's skill-authoring structure.")

        H2("Setup")
        Numbered(1, "Get an API key from the Anthropic console")
        Numbered(2, "Open Settings (⌘,) → **AI** tab")
        Numbered(3, "Paste the key in the SecureField → click **Save Key**")
        Numbered(4, "The key is stored in macOS Keychain — never written to UserDefaults or any plaintext file")
        ExternalLink("Get an Anthropic API Key", "https://console.anthropic.com/settings/keys")

        H2("How it works")
        P("Open **Make Skill** on any document. With a key configured, a **✨ Enhance with AI** button appears at the bottom of the modal.")
        P("Click it: mARK.AI sends your cleaned source content to the Anthropic Messages API using `claude-sonnet-4-6` (balance of quality and cost). The system prompt instructs Claude to:")
        Bullet("Extract a kebab-case `name` and a what+when `description`")
        Bullet("Produce a body following the official SKILL.md section structure")
        Bullet("Include concrete examples (input → output)")
        Bullet("Add boundaries (what the agent must NOT do)")
        P("The response is JSON-decoded and pre-fills the modal — you review and click Save.")

        H2("Privacy")
        P("Your key is read from Keychain at the moment of the request, used in the `x-api-key` header, and never persisted elsewhere. Your content is only sent when **you explicitly click Enhance**.")

        Callout.note("Enhance with AI uses tokens from your Anthropic account. Monitor usage in your console. A typical 2-page document costs a few cents.")
    }

    // MARK: - Themes
    @ViewBuilder private var themes: some View {
        H1("Themes")
        P("mARK.AI ships with **8 themes**, each calibrated with a paired text color tuned for contrast against its background. No neon, no fluorescent text — every combination passes WCAG AA readability.")

        H2("Available themes")
        Bullet("**System** — follows macOS appearance (light/dark)")
        Bullet("**Pinky** `#EC849A` — warm rose")
        Bullet("**Navy** `#384166` — deep indigo (dark)")
        Bullet("**Desert** `#A1D8B5` — sage mint")
        Bullet("**Black Forest** `#283F23` — deep forest (dark)")
        Bullet("**Qatar** `#F1EDEA` — warm cream")
        Bullet("**Relax** `#3EBCB3` — turquoise")
        Bullet("**Typhoon** `#070836` — midnight navy (dark)")

        H2("How to switch")
        P("Open Settings (⌘,) → **Appearance** tab → click any swatch. The editor updates **instantly** — no apply/cancel.")

        H2("What changes")
        P("Each theme controls four surfaces:")
        Bullet("**Background** of the source editor")
        Bullet("**Text** color")
        Bullet("**Accent** color (applied via `.tint()` to buttons, cursor, selection)")
        Bullet("**Bar background** — top bar, format bar, status bar use a slightly darker (or lighter, for very dark themes) variant for visual separation")

        Callout.note("Preview always follows the **system** appearance, regardless of your editor theme. This keeps preview faithful to how others will see your exported HTML.")
    }

    // MARK: - Settings
    @ViewBuilder private var settings: some View {
        H1("Settings")
        P("Open Settings with ⌘, from anywhere in the app.")

        H2("Appearance")
        P("Theme selection — see ")
        TopicLink(topic: .themes, selection: $selection)

        H2("Default App")
        P("This pane tells you which app currently opens `.md`, `.skill.md`, and `.txt` files on your Mac.")
        P("Sandboxed apps **cannot** set themselves as default for a file type — this is a macOS architectural restriction, not a bug. The pane gives you the universal manual workflow:")
        Numbered(1, "Click **Choose .md file…** — the file is revealed in Finder")
        Numbered(2, "Right-click the file → **Get Info** (⌘I)")
        Numbered(3, "Under **Open with**, pick mARK.AI")
        Numbered(4, "Click **Change All…** → confirm")

        H2("AI")
        P("Paste your Anthropic API key here to enable **Enhance with AI** in Make Skill. The key is stored in macOS Keychain.")
        Bullet("**Replace** — wipes the key so you can paste a new one")
        Bullet("**Remove** — deletes the key from Keychain entirely")
    }

    // MARK: - Integration
    @ViewBuilder private var integration: some View {
        H1("macOS Integration")
        P("mARK.AI plugs into macOS in three ways: Services, file associations, and a URL scheme.")

        H2("Right-click Services")
        P("Three Services are registered system-wide. In any app — Safari, Notes, Mail, Pages — select some text or a file, right-click, choose **Services**:")
        Bullet("**mARK.AI: New Markdown from Selection** — opens a new document containing the selected text")
        Bullet("**mARK.AI: Make Agent Skill from Selection** — opens Make Skill modal pre-filled with the selection")
        Bullet("**mARK.AI: Make Agent Skill from File** — accepts a `.md` / `.txt` file URL in Finder, opens Make Skill modal")
        Callout.tip("If a Service doesn't appear, open **System Settings → Keyboard → Keyboard Shortcuts → Services** and ensure mARK.AI's entries are enabled.")

        H2("File associations")
        P("mARK.AI registers as a handler for `.md` (Markdown) and `.skill.md` (custom UTI `com.arkitecna.markai.skill`). Double-click in Finder opens the file directly.")

        H2("URL scheme")
        P("The scheme `arkaimd://` is reserved. Currently used internally by the future Share Extensions. You can craft custom links of the form:")
        CodeBlock("arkaimd://open?path=/absolute/path/to/file.md")
    }

    // MARK: - Shortcuts
    @ViewBuilder private var shortcuts: some View {
        H1("Keyboard Shortcuts")
        P("Every action in mARK.AI is reachable from the keyboard. Press ⌘? to open Help; ⌘, for Settings.")

        H2("File")
        VStack(spacing: 0) {
            ShortcutRow("New document", "⌘N")
            ShortcutRow("Open…", "⌘O")
            ShortcutRow("Save", "⌘S")
            ShortcutRow("Save As…", "⇧⌘S")
            ShortcutRow("Create Agent Skill…", "⇧⌘A")
            ShortcutRow("Close window", "⌘W")
        }

        H2("Edit")
        VStack(spacing: 0) {
            ShortcutRow("Undo / Redo", "⌘Z / ⇧⌘Z")
            ShortcutRow("Cut / Copy / Paste", "⌘X / ⌘C / ⌘V")
            ShortcutRow("Paste & Match Style", "⌥⇧⌘V")
            ShortcutRow("Select All", "⌘A")
            ShortcutRow("Find", "⌘F")
            ShortcutRow("Find Next / Previous", "⌘G / ⇧⌘G")
        }

        H2("Format — Inline")
        VStack(spacing: 0) {
            ShortcutRow("Bold", "⌘B")
            ShortcutRow("Italic", "⌘I")
            ShortcutRow("Strikethrough", "⇧⌘X")
            ShortcutRow("Inline Code", "⌘E")
            ShortcutRow("Link…", "⌘K")
        }

        H2("Format — Headings & Blocks")
        VStack(spacing: 0) {
            ShortcutRow("Heading 1–6", "⌘1 … ⌘6")
            ShortcutRow("Paragraph", "⌘0")
            ShortcutRow("Block Quote", "⌃⌘Q")
            ShortcutRow("Unordered List", "⇧⌘8")
            ShortcutRow("Ordered List", "⇧⌘7")
            ShortcutRow("Task List", "⇧⌘T")
            ShortcutRow("Horizontal Rule", "⌘-")
        }

        H2("View")
        VStack(spacing: 0) {
            ShortcutRow("Toggle Source / Preview", "⇧⌘P")
            ShortcutRow("Hide / Show Format Bar", "⌥⌘B")
            ShortcutRow("Enter Full Screen", "⌃⌘F")
        }

        H2("Application")
        VStack(spacing: 0) {
            ShortcutRow("Settings", "⌘,")
            ShortcutRow("Help", "⌘?")
            ShortcutRow("Hide mARK.AI", "⌘H")
            ShortcutRow("Hide Others", "⌥⌘H")
            ShortcutRow("Minimize", "⌘M")
            ShortcutRow("Quit", "⌘Q")
        }
    }

    // MARK: - Privacy
    @ViewBuilder private var privacy: some View {
        H1("Privacy & Security")
        P("mARK.AI is **local-first**. Nothing leaves your machine unless you explicitly click **Enhance with AI** — and even then, only the content you chose is sent.")

        H2("Anthropic API key")
        P("Stored in the macOS Keychain as a generic password under the service `com.arkitecna.markai`, account `anthropic-api-key`. Never written to UserDefaults, never logged, never readable by other apps.")
        InlineCode("kSecClassGenericPassword")

        H2("Sandbox")
        P("mARK.AI is fully sandboxed and runs with the macOS Hardened Runtime. Its declared entitlements are:")
        Bullet("`com.apple.security.app-sandbox` — sandboxed execution")
        Bullet("`com.apple.security.files.user-selected.read-write` — read/write only files you explicitly pick via Open/Save panels")
        Bullet("`com.apple.security.network.client` — outgoing HTTPS connections")
        Bullet("`com.apple.security.application-groups` — reserved for future Share Extensions")

        H2("Why network?")
        P("Two reasons. First, **WKWebView** (which renders the preview) requires this entitlement to spawn its WebContent child process, **even for purely local content** — a documented macOS architecture requirement. Second, **Enhance with AI** calls the Anthropic Messages API over HTTPS — only when you click the button.")

        H2("What we don't do")
        Bullet("No analytics SDK")
        Bullet("No telemetry pings")
        Bullet("No anonymous diagnostic data")
        Bullet("No third-party crash reporters")
        Bullet("No in-app browser")
        Bullet("No accounts, no sign-in")
        Bullet("No fingerprinting")

        H2("Full policies")
        ExternalLink("Privacy Policy", "https://arkai.dev/app/PPmarkai")
        ExternalLink("License Agreement (Apple standard EULA)", "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    }

    // MARK: - Troubleshooting
    @ViewBuilder private var troubleshooting: some View {
        H1("Troubleshooting")

        H2("Mermaid diagram doesn't render")
        P("The most common cause: the diagram is **inside another code block** — e.g. AI gave you a `.md` template wrapped in a ```` ```python ```` fence. CommonMark forbids nested fences, so the inner mermaid is treated as plain text.")
        P("mARK.AI detects this and shows a **“Render as diagram”** button on the wrapping code block — click it.")
        Bullet("If the button doesn't appear: the embedded block must start with a recognizable mermaid keyword (`graph`, `flowchart`, `sequenceDiagram`, etc.)")
        Bullet("Verify the mermaid syntax itself by pasting it standalone")
        TopicLink(topic: .diagrams, selection: $selection)

        H2("Source text appears black on a dark theme")
        P("Should be fixed in the current build. If you ever see it: switch themes once (Settings → Appearance), or close and reopen the document. The editor will re-apply foreground attributes to every character on next render.")

        H2("“App couldn't be loaded” when setting default")
        P("macOS does not allow sandboxed apps to set themselves as default file handlers — this is an Apple-side restriction. Use the manual workflow:")
        Numbered(1, "Find a `.md` file in Finder")
        Numbered(2, "Right-click → Get Info (⌘I)")
        Numbered(3, "Under **Open with**, pick mARK.AI")
        Numbered(4, "Click **Change All…**")

        H2("Enhance with AI returns an error")
        Bullet("**401 / 403** — API key is invalid or expired. Replace it in Settings → AI.")
        Bullet("**429** — rate limited. Wait a few seconds and retry.")
        Bullet("**Parse error** — the model returned non-JSON output (rare). Retry; if persistent, simplify the source.")

        H2("API key won't save")
        P("Verify Keychain isn't locked. Open the **Keychain Access** app, search for `anthropic-api-key` — you should see an entry under the login keychain. If not, your Keychain may be in an unusual state — log out and back in.")
    }

    // MARK: - About
    @ViewBuilder private var about: some View {
        H1("About mARK.AI")
        P("Version **1.0** — © 2026 Arkitecna. All rights reserved.")
        P("mARK.AI is built around a single principle: every additional button must justify itself.")

        H2("Credits")
        P("mARK.AI uses the following open-source libraries, all licensed under MIT:")
        Bullet("**Down** — Markdown → HTML rendering (CommonMark)")
        ExternalLink("github.com/iwasrobbed/Down", "https://github.com/iwasrobbed/Down")
        Bullet("**Yams** — YAML parsing")
        ExternalLink("github.com/jpsim/Yams", "https://github.com/jpsim/Yams")
        Bullet("**Highlightr** — syntax highlighting")
        ExternalLink("github.com/raspu/Highlightr", "https://github.com/raspu/Highlightr")
        Bullet("**Mermaid.js** — diagram rendering")
        ExternalLink("github.com/mermaid-js/mermaid", "https://github.com/mermaid-js/mermaid")

        H2("Source code")
        ExternalLink("github.com/cesarenegro/markai", "https://github.com/cesarenegro/markai")

        H2("Report an issue")
        ExternalLink("Open a GitHub issue", "https://github.com/cesarenegro/markai/issues/new")

        H2("Legal")
        ExternalLink("Privacy Policy", "https://arkai.dev/app/PPmarkai")
        ExternalLink("License Agreement (Apple standard EULA)", "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")

        H2("Acknowledgements")
        P("The credits panel inside **About mARK.AI** (in the application menu) shows the full attribution loaded from the bundled `Credits.html`.")
    }
}

#Preview {
    @Previewable @State var sel: HelpTopic = .welcome
    return HelpContent(topic: .welcome, selection: $sel)
        .padding()
        .frame(width: 700, height: 800)
}
