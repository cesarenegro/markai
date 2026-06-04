# mARK.AI — App Store Connect submission

> Copy-paste ready content for App Store Connect (appstoreconnect.apple.com).
> Each section header indicates the corresponding field in the portal.

---

## 1. App identity

| Field | Value |
|---|---|
| **App Name** | mARK.AI |
| **Bundle ID** | `com.arkitecna.markai` |
| **SKU** | `markai-macos-1` |
| **Primary language** | English (U.S.) |
| **Category** | Productivity |
| **Secondary category** | Developer Tools |
| **Platform** | macOS |
| **Minimum macOS** | 15.0 (Sequoia) |
| **Version** | 1.0 |
| **Build number** | 1 |
| **Marketing version (CFBundleShortVersionString)** | 1.0 |
| **Copyright** | © 2026 Arkitecna. All rights reserved. |

---

## 2. App Information → Subtitle

> max 30 chars

```
Markdown editor with AI skills
```

---

## 3. App Information → Promotional Text

> max 170 chars — can be changed without resubmitting

```
Edit Markdown with live preview, render Mermaid diagrams, and convert any document into a reusable AI Agent Skill — all without the bloat. Local-first, privacy-respecting.
```

---

## 4. App Information → Description

> max 4000 chars

```
mARK.AI is a focused Markdown editor for macOS, built for people who turn raw text into knowledge — and increasingly, into agent skills.

THE EDITOR
• Distraction-free source view with native Find bar
• Live preview with Mermaid diagram rendering
• Smart detection of Mermaid blocks inside other code fences — render them with one click without modifying your source
• Export diagrams as SVG (vector) or PNG (white-background raster) directly from the preview
• Format menu and floating format bar: bold, italic, strikethrough, inline code, links, headings 1–6, lists (bulleted / numbered / task), block quote, horizontal rule
• Auto-save every 2 seconds; word count and save indicator in the status bar
• 7 carefully calibrated themes: System, Pinky, Navy, Desert, Black Forest, Qatar, Relax, Typhoon — all with paired text colors tuned for contrast

THE AI SKILL CONVERTER
mARK.AI's signature feature converts a raw document — pasted from a web page, PDF or Word doc — into a properly structured Anthropic SKILL.md file or generic AGENTS.md.

• "Make Skill" generates a scaffold with the official Anthropic structure: When to use / How to apply / Examples / Boundaries / Reference material
• Optional "Enhance with AI" sends your content to Claude (using your own API key, stored securely in macOS Keychain) and returns a properly authored skill
• Choose output format: single portable .skill.md file, or a folder ready to drop into ~/.claude/skills/

PRIVACY & SECURITY
• 100% local-first. Nothing leaves your machine unless you explicitly click "Enhance with AI"
• Your Anthropic API key lives in macOS Keychain — never in plaintext
• No telemetry, no analytics, no accounts
• Sandboxed app with hardened runtime
• Free and open about what each network call does

WORKFLOW INTEGRATION
• Right-click Services in any app: "New Markdown from Selection", "Make Agent Skill from Selection", "Make Agent Skill from File"
• Register .md and .skill.md file types — opens directly in mARK.AI from Finder
• Custom URL scheme arkaimd:// for inter-app workflows

mARK.AI is built on the principle that every additional button must justify itself. It does one thing well: turning your raw thoughts and reference material into reusable, structured knowledge for both humans and AI agents.
```

---

## 5. App Information → Keywords

> max 100 chars, comma-separated, no spaces after commas

```
markdown,editor,mermaid,diagram,ai,skill,claude,gemini,agent,note,writer,minimal,productivity
```

---

## 6. App Information → Support URL

```
https://github.com/cesarenegro/markai
```

> (Update if you host elsewhere)

---

## 6.1 App Information → Privacy Policy URL (REQUIRED — Guideline 5.1.1)

```
https://arkai.dev/app/PPmarkai
```

> Apple rejects every submission that does not have a working privacy policy URL.

---

## 6.2 App Information → License Agreement (EULA)

Leave the "Custom EULA" field **empty** to use Apple's standard EULA:

```
https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

The link is also exposed inside the app (Help menu → License Agreement).

---

## 7. App Information → Marketing URL (optional)

```
(empty — or your landing page)
```

---

## 8. App Review Information

### Contact

| Field | Value |
|---|---|
| **First name** | Cesare |
| **Last name** | (your surname) |
| **Phone** | (your phone) |
| **Email** | yelhk.cpa@gmail.com |

### Demo account

> mARK.AI doesn't require sign-in. Leave demo account empty.

### Notes for Reviewer

> Copy this block verbatim into "Notes" — explains every entitlement and feature so reviewers don't reject for misunderstanding.

```
mARK.AI is a Markdown editor with optional AI skill generation. Notes for review:

NETWORK USAGE
The com.apple.security.network.client entitlement is required for TWO reasons:
1. WKWebView (used to render the Markdown preview with Mermaid diagrams) spawns its WebContent child process which requires the network.client entitlement to launch, even when only displaying bundled local resources. This is a documented macOS architecture requirement.
2. The optional "Enhance with AI" feature in "Make Skill" sends the user's selected content to the Anthropic Claude API (https://api.anthropic.com/v1/messages). This is OPT-IN per invocation — never automatic. The user must explicitly configure their own Claude API key in Settings → AI and then explicitly click the "Enhance with AI" button. No content is ever sent without explicit user action.

APPLICATION GROUPS
group.com.arkitecna.markai is declared in preparation for Share Extensions in version 1.1 (right-click Save as Markdown / Save as AI Skill from any application). In v1.0 it is reserved but unused; the same App ID prefix will be reused.

USER-SELECTED FILES READ-WRITE
Required for NSSavePanel / NSOpenPanel based document save and load. No other file access patterns are used.

KEYCHAIN
The Anthropic API key (if user provides one) is stored in macOS Keychain (kSecClassGenericPassword, service "com.arkitecna.markai", account "anthropic-api-key"). Standard usage.

NSSERVICES
Three Services menu items are registered for right-click in other apps. No private API is used.

THIRD-PARTY LIBRARIES (all MIT licensed, attributed in About → Credits):
- Down (Markdown → HTML)
- Yams (YAML parsing)
- Highlightr (syntax highlighting placeholder, future use)
- Mermaid.js (bundled, runs locally in WKWebView, no network)

NO TRACKING
No analytics SDK, no third-party telemetry, no anonymous ping, no in-app browsers, no fingerprinting.

LEGAL
Privacy Policy: https://arkai.dev/app/PPmarkai
EULA: Apple standard (https://www.apple.com/legal/internet-services/itunes/dev/stdeula/)
Both links are also accessible from the Help menu inside the app.

How to test "Enhance with AI": you can use your own Claude API key from console.anthropic.com, or skip this feature — all other functionality works without it.
```

---

## 9. App Privacy (App Store Connect → App Privacy section)

> Apple now requires every app to declare data practices. Below is the exact mapping for mARK.AI v1.0.

### Data Types Collected

**None** if user never uses "Enhance with AI". If they do, declare the following:

| Data Type | Collected? | Linked to user? | Used for tracking? | Purpose |
|---|---|---|---|---|
| Contact Info | NO | — | — | — |
| Health & Fitness | NO | — | — | — |
| Financial Info | NO | — | — | — |
| Location | NO | — | — | — |
| Sensitive Info | NO | — | — | — |
| Contacts | NO | — | — | — |
| User Content → Other User Content | **YES** (only via Enhance) | NO | NO | **App Functionality** |
| Browsing History | NO | — | — | — |
| Search History | NO | — | — | — |
| Identifiers | NO | — | — | — |
| Purchases | NO | — | — | — |
| Usage Data | NO | — | — | — |
| Diagnostics | NO | — | — | — |
| Other Data | NO | — | — | — |

### Privacy Q&A

When prompted by App Store Connect:

- **Do you or your third-party partners collect data from this app?** YES (only via Enhance feature — see below) or NO if you remove Enhance from v1.0 marketing.
- **Used to track the user?** NO
- **Linked to the user's identity?** NO
- **Optional disclosure**: "User Content is sent to Anthropic's API only when the user explicitly clicks 'Enhance with AI'. The Anthropic API key is provided by the user and stored locally in macOS Keychain."

---

## 10. Pricing & Availability

| Field | Value |
|---|---|
| **Price tier** | (your choice — Free / $4.99 / $9.99 / etc.) |
| **Availability** | (Worldwide or selected countries) |
| **Educational discount** | (your choice) |
| **Volume Purchase** | enabled |

---

## 11. Version Release

| Field | Value |
|---|---|
| **Automatically release this version** | YES (recommended) |
| **Manual release after approval** | (alternative) |
| **Phased release for automatic updates** | enabled (recommended) |

---

## 12. What's New in This Version (release notes)

> max 4000 chars — for v1.0, can be brief

```
First public release of mARK.AI.

Edit Markdown with live preview, render Mermaid diagrams, export them as SVG or PNG. Convert any document into a structured Anthropic SKILL.md or generic AGENTS.md with the "Make Skill" button — optionally enhanced by Claude if you have an API key.

Local-first. Sandboxed. No telemetry.
```

---

## 13. Screenshots required for macOS

Apple requires:

- **2880×1800** preferred resolution
- minimum **1280×800**
- 1 to 10 screenshots
- PNG or JPEG, RGB, no alpha

Suggested shots (5):

1. **Hero** — Source mode with a real markdown file, format bar visible, Pinky or Navy theme
2. **Preview with Mermaid** — A diagram rendered in preview, with the export toolbar on hover (SVG / PNG buttons visible)
3. **Smart detect** — A python code block containing a mermaid fence, "Render as diagram" button visible
4. **Create Skill modal** — pre-filled scaffold with Description, Platform picker, Output picker
5. **Settings → Appearance** — the 8-swatch theme grid

Use a sample document with non-Lorem Ipsum content (a real-looking markdown).

---

## 14. App Preview video (optional)

Apple accepts a 15–30 second video. If included:

- 1920×1080 or 2880×1800
- M4V, MP4, MOV
- Show: typing → preview → diagram render → export → Make Skill → Enhance with AI

---

## 15. Pre-submit checklist (do these before clicking Submit)

### Code-side (already done)

- [x] ITSAppUsesNonExemptEncryption = false in Info.plist
- [x] NSHumanReadableCopyright filled
- [x] Credits.html in Resources/ (auto-loaded by About panel)
- [x] Sandbox enabled
- [x] Hardened Runtime enabled
- [x] App icon all 10 sizes
- [x] CFBundleShortVersionString = 1.0, CFBundleVersion = 1

### Required manual testing (regola #9 — non saltare)

- [ ] Build for Release, archive, and run from the archived .app — not Debug
- [ ] Test on a **fresh macOS user account** (sandbox issues appear on first launch)
- [ ] Test all 3 NSServices in another app (Notes, Safari, TextEdit)
- [ ] Test "Enhance with AI" with a real Claude API key, end-to-end
- [ ] Test diagram export PNG + SVG on a real Mermaid diagram
- [ ] Test all 8 themes for readability
- [ ] Test window resize to minimum (600×400) — no broken UI
- [ ] Test dark mode system with theme = System
- [ ] Test opening a .md from Finder (after Finder Get Info → Open With → Change All)

### App Store Connect

- [ ] Upload screenshots (≥ 3, 1280×800 minimum)
- [ ] Fill description, keywords, promotional text from this doc
- [ ] Set price tier
- [ ] Fill App Privacy (User Content if Enhance is in v1.0)
- [ ] Fill App Review Information (contact + notes)
- [ ] Sign Paid Apps Agreement (if paid)
- [ ] Confirm tax info
- [ ] Submit binary via Xcode → Archive → Distribute → App Store Connect

---

## 16. Versioning policy (forward)

- **Patch (1.0.x)**: bug fixes only. CFBundleVersion = 2, 3, ...
- **Minor (1.x.0)**: new features. New CFBundleShortVersionString.
- **Major (x.0.0)**: breaking changes.

App Store Connect tracks build numbers — each upload increments it.

---

## 17. Common rejection reasons to pre-empt

- **2.1 App Completeness** — must work on first launch without errors. Test on fresh user.
- **2.3.7 Accurate Metadata** — screenshots must match actual UI. Don't show features you don't ship.
- **3.1.1 In-App Purchase** — N/A (no IAP in v1.0).
- **5.1.1 Data Collection and Storage** — make sure Privacy disclosure matches what app does.
- **5.2.2 Third-Party Content** — Credits.html attributes Down/Yams/Highlightr/Mermaid.
- **Guideline 2.5 — Software Requirements** — uses public APIs only ✓.
