# HANDOFF — mARK.AI (sessione del 2026-06-01)

## Stato attuale

**Fase 0**: parzialmente completata — file di configurazione creati ma **NON linkati** al target perché l'editor remoto blocca modifiche dirette al `.pbxproj` quando Xcode è aperto.

**Fase 1**: completata — editor SwiftUI base funzionante (open/save/auto-save/word count). Build passa con 0 errori.

## Cosa devi fare nell'UI di Xcode (5 minuti)

Apri il progetto in Xcode e applica queste modifiche nell'ordine. Tutte avvengono in **Project Navigator → target "Arkai MD"**.

### 1. Minimum Deployment

Tab **General** → sezione **Minimum Deployments** → macOS: cambia da `26.3` a **`15.0`**.

### 2. Signing & Capabilities

Tab **Signing & Capabilities**:

- **App Sandbox** è già attivo. Espandilo:
  - **File Access** → **User Selected File**: cambia da "Read Only" a **"Read/Write"**.
- Clicca **+ Capability** → **App Groups** → aggiungi `group.com.arkitecna.markai`.

### 3. Build Settings — punta ai file Info.plist e entitlements custom

Tab **Build Settings** → cerca queste chiavi (mostra "All" + "Combined"):

- **Info.plist File**: imposta a `Arkai MD/Info.plist`
- **Generate Info.plist File**: cambia da `YES` a **`NO`**
- **Code Signing Entitlements**: imposta a `Arkai MD/Arkai MD.entitlements`

> I file `Info.plist` e `Arkai MD.entitlements` esistono già in `Arkai MD/` — vanno solo linkati come build settings.

### 4. Aggiungi i 3 SPM packages

Menu **File → Add Package Dependencies…**, aggiungi uno alla volta:

| Package | URL | Prodotto da linkare |
|---|---|---|
| Down | `https://github.com/iwasrobbed/Down` | `Down` |
| Yams | `https://github.com/jpsim/Yams` | `Yams` |
| Highlightr | `https://github.com/raspu/Highlightr` | `Highlightr` |

Quando Xcode chiede "Add to Target", seleziona **Arkai MD**.

### 5. (Solo dopo) Build di verifica

Cmd+B. Dovrebbe passare. Se l'Info.plist linkato dà errori di chiavi mancanti (CFBundleIconFile, ecc.), avvisami al ritorno e li sistemiamo.

---

## Cosa ho creato io in questa sessione

```
Arkai MD/
├── Arkai_MDApp.swift              # entry point con AppDelegate adapter + menu commands
├── ContentView.swift              # ridotto a wrapper #Preview (da rinominare/rimuovere)
├── Info.plist                     # ⚠️ creato ma DA LINKARE (step 3)
├── Arkai MD.entitlements          # ⚠️ creato ma DA LINKARE (step 3)
├── App/
│   └── AppDelegate.swift          # NSApplicationDelegate: open file/URL, NSOpen/SavePanel
├── Editor/
│   ├── EditorState.swift          # @Observable: content, dirty, autosave loop
│   └── EditorView.swift           # TextEditor monospace + status bar
├── Model/                         # vuota — per MarkdownDocument & SkillDocument (Fase 2+)
├── Resources/
│   ├── mermaid.min.js             # v11 da jsdelivr (scaricato)
│   ├── preview.html               # template WKWebView con export SVG/PNG via webkit handler
│   └── styles.css                 # dark/light auto, diagram-container con toolbar hover
└── Assets.xcassets/AppIcon.appiconset/   # icona già generata (sessione precedente)
```

## Architettura Fase 1 — come funziona ora

- **Stato**: `EditorState` `@Observable` `@MainActor`. Iniettato come `.environment` dal main scene.
- **AppDelegate**: tiene il riferimento allo `EditorState`, gestisce `application(_:open:)` per `.md` doppio-click e per URL scheme `arkaimd://open?path=...`.
- **Apertura/salvataggio**: `NSOpenPanel` / `NSSavePanel` da menu File (⌘O, ⇧⌘S). ⌘N pulisce il documento.
- **Auto-save**: `Task` loop ogni 2s — se `isDirty && fileURL != nil` chiama `save()`. Errori loggati con prefix `[EditorState]` (regola #3 CLAUDE.md).
- **Status bar**: filename, word count, "editing…" o "saved Xs ago".

## Fasi successive (ordine consigliato)

| Fase | Cosa | Quando |
|---|---|---|
| **2 — Preview** | `WKWebView` representable, `MarkdownRenderer` (Down→HTML), toggle Source/Preview (⌘⇧P), bundle `preview.html` come resource | dopo step 1-4 di sopra |
| **3 — Mermaid export** | `WKScriptMessageHandler` per `exportDiagram`, SVG diretto, PNG con bg bianco via `NSImage` offscreen | subito dopo Fase 2 |
| **4 — Share Extensions** | nuovi target `MarkdownSaver.appex` + `AISkillSaver.appex`, App Group hand-off via URL scheme | dopo Fase 3 |
| **5 — Polish** | distraction-free mode (⌃⌘F), syntax highlighting con Highlightr, tema preview dinamico, ⌘B/⌘I/⌘K shortcuts | infine |

## Note tecniche

- **`PBXFileSystemSynchronizedRootGroup`** (Xcode 26+): tutti i file dentro `Arkai MD/` vengono auto-inclusi nel target. Quindi i nuovi `.swift` e le risorse sono già compilati senza toccare il pbxproj. ✓
- **Info.plist e .entitlements**: anche se sono nella cartella sync'd, **non** influenzano il build finché non vengono **referenziati** come build setting. Per questo i passi 1-3 sopra sono necessari.
- **Auto-save senza File ID**: se l'utente non ha mai salvato il documento (`fileURL == nil`), l'auto-save non parte (non c'è dove scrivere). Cmd+Shift+S obbligatorio per il primo salvataggio.
- **mermaid.min.js**: scaricato da `https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js`. Per offline va bene così. Se serve aggiornare → ri-curl.

## File non più rilevanti

- `ContentView.swift` ora contiene solo un `#Preview`. Si può rimuovere in una sessione futura (CLAUDE.md regola #5: niente cleanup opportunistico, lo segnalo qui ma non l'ho fatto).
