# Codebase Audit — Source of This Kit

Audited: 2026-07-04 (read-only). Source: `aixTextEditor` — Tauri 2 + Rust +
React 19 + TypeScript + Zustand + Tailwind, macOS-first desktop app: an
LLM-augmented, chunk-based editor for academic papers and long-form reports.

This audit separates **facts observed in code** from **recommendations**, and
classifies every finding: [A] Universal / [B] Project Pattern /
[C] Project-specific / [D] Needs confirmation.

---

## 1. Audit summary (facts)

**Stack** — Rust backend: 16 modules under `src-tauri/src/` (ai, cli, commands,
deck, error, fileio, imageio, lib, main, menu, models, net, pdf, pptx,
settings). Frontend: 19 TS/TSX modules + 20 components. State: single Zustand
store (~1500 lines). Styling: Tailwind with a small semantic token extension.

**Test inventory** — 84 Rust `#[test]` functions (pptx 25, fileio 19, ai 7,
settings 7, deck 6, models 5, net 5, cli 4, imageio 4, pdf 2; **zero** in
commands.rs / lib.rs / error.rs / menu.rs) + 41 vitest tests (store 13,
slides 16, aiActions 12). **No CI** — no `.github/` directory exists.

**Architecture (verified)**
- All disk/network/secret I/O lives in Rust; the webview only renders and
  edits. CSP `connect-src` allows only `'self' ipc: http://ipc.localhost`.
- 24 `#[tauri::command]` functions registered in one `invoke_handler` list.
- Single `AppError` enum (thiserror), `From` impls per source, serialized to a
  human-readable string for the frontend's `invoke().catch`.
- One canonical data model ("chunk"); editor view, slide view, relationship
  graph, and every export format are projections of the same chunk array.
- Deterministic core: document→deck conversion is explicitly "AI-free";
  AI operates only at the edges (per-paragraph actions, draft, analysis).
- Untrusted-content fetches go through one SSRF-guarded `safe_fetch`
  (blocks private/loopback/metadata IPs, re-validates each redirect hop,
  size caps + timeouts). Well unit-tested.
- Keys in OS keychain only; frontend receives `has_api_key: bool`, never the
  value. Write paths pass an extension allowlist. Capabilities file grants 10
  minimal permissions (no fs/shell/http plugins).
- `Document::normalize()` repairs malformed files on load (6 repair steps)
  and reports human-readable repair notes.
- Headless CLI (`capabilities`, `info`, `show`, `export`) reuses the same pure
  Rust functions as the GUI. Its self-describing manifest is now guarded by
  contract tests (manifest ↔ dispatch-table equality).

**Recent history (matters for provenance)** — Three generations of deep
analysis reports found, among other things: WYSIWYG parity bugs between the
TS preview and Rust export (twice), a vacuous regression test, a capabilities
manifest that advertised unimplemented features, stale AI-context data with an
unconsumed staleness flag, and "for agents" architecture with no agent-usable
entry point. Between analyses, the project fixed most of these: a ⌘K command
palette, a persistent HealthBar (save state, staleness, export warnings), an
AI review/integrity panel, summary-hash staleness with refresh-before-use,
client-side Mermaid rasterization so PPTX embeds diagram snapshots, native
CJK-capable PDF export, and manifest contract tests. Still open: headless AI
execution (LlmConfig is constructible only via Tauri `AppHandle`), MCP, CI.

---

## 2. Extracted reusable principles (what to port)

| # | Finding | Class | Where documented |
|---|---------|-------|------------------|
| 1 | Every promise (README claim, manifest entry, doc comment) gets a test or an explicit "planned" label | A | 01_principles §6, rules/testing.md |
| 2 | All I/O behind a typed backend boundary; UI never touches disk/network | B (universal for Tauri/Electron) | 02_architecture §1 |
| 3 | Deterministic core, AI at the edges | A | 01_principles §2 |
| 4 | One canonical model; views/exports are projections | A | 01_principles §3 |
| 5 | Warn-don't-block, but warnings need a *persistent* surface (toast-only warnings = silent data loss) | A | 03_ui_constitution, 05_taste |
| 6 | Freshness is state: derived data carries a content hash; consumers refresh-before-use | A | 07_state_model §4 |
| 7 | Dual implementations of one visual contract require contract tests (or a single source of truth) | A | 02_architecture §5, rules/testing.md |
| 8 | Scoped assertions: a string/XML `contains` test that can't fail is a bug (vacuous-test lesson) | A | rules/testing.md |
| 9 | Normalize-on-load with repair notes; never trust a file you didn't just write | A | 02_architecture §6 |
| 10 | Minimal permission grants + one SSRF-guarded fetch entry point + secrets in OS keychain | B | 06_permission_policy |
| 11 | Per-scope busy/in-flight state isolated per tab/context (background op can't repaint the wrong tab) | B | 07_state_model §2 |
| 12 | Errors: one enum, human-readable serialization, retry only where idempotent (before first streamed token) | B | rules/rust-error-design skill |
| 13 | Command palette + persistent health bar as the discoverability/status backbone | B | 03_ui_constitution |
| 14 | Non-destructive by default; destructive variants clearly separated (detach-vs-rewrite lesson) | A | 05_taste §1 |
| 15 | Auto + manual override + an explicit way back to Auto | A | 05_taste §3 |
| 16 | Client-side rendering handoff: when only the UI can rasterize (Mermaid), attach snapshots to the model for export, and warn honestly when absent | B | 02_architecture §7 |

## 3. Things to AVOID porting ([C] Project-specific)

- **The chunk data model itself** (paragraph-as-chunk, heading levels 1–3,
  slide layouts, subtitle flags) — domain-specific to a document editor.
- **Concrete token values** (ink `#1f2933`, accent `#2563eb`, 44rem prose
  width, Georgia serif) — port the token *structure*, not the palette.
- **macOS window-close-hides-app lifecycle** (Rust-owned `prevent_close` +
  Reopen rebuild) — correct for a macOS document app; wrong default elsewhere.
- **`say`-based TTS, voice-name tables, CJK width tables** — platform/locale
  specific.
- **OpenRouter-specific request/response shape handling** (4-way image-URL
  response fallback) — provider-specific defensive code.
- **The 60-line/3000-char document-map caps** — tuned to this app's prompt
  budget; the *pattern* (explicit caps + truncation disclosure) is [A], the
  numbers are [C].
- **Homebrew Formula/Casks, Artistic-2.0 license text, product naming.**

## 4. [D] Needs confirmation (could not be settled from code)

1. **Atomic writes for user documents** — session file uses temp+rename, but
   the main document save appears to be a plain write. Whether this is
   acceptable depends on the target app's data-loss tolerance. (REC: default
   to temp+rename everywhere.)
2. **Dark mode** — source app is light-only (`color-scheme: light`). New
   projects must decide before tokens are chosen.
3. **CI provider** — source has none (repo may be private/local-only; CI
   choice depends on hosting). Kit assumes GitHub Actions in wording; adapt.
4. **Windows/Linux parity** — several features are macOS-gated with explicit
   errors on other OSes. Port targets must decide their platform matrix.
5. **i18n strategy** — UI copy is English; document content is
   multilingual-aware (CJK fonts/widths/tokenizers). Whether UI itself needs
   i18n is a product decision.
6. **The "headless twin" requirement** — the source project's stated goal
   (every GUI capability also reachable via CLI/MCP) is still unfinished
   there (AI config requires a live `AppHandle`). Decide early whether your
   project commits to it; it is much cheaper designed-in than retrofitted.

---

## 5. Priority order used for generation (and recommended reading order)

1. `CLAUDE.md` — the always-loaded constitution (small on purpose)
2. `docs/ai/01_project_principles.md` — everything else derives from these
3. `.claude/rules/testing.md` — highest defect-prevention leverage
4. `docs/ai/02_architecture_patterns.md` + `07_state_model_patterns.md`
5. `docs/ai/03_ui_constitution.md` + `04_design_tokens.md` + rules/ui.md
6. `docs/ai/06_tauri_permission_policy.md` + rules/tauri-permissions.md
7. `docs/ai/05_feature_taste_guide.md` + `08_review_checklist.md`
8. `.claude/skills/*` — procedures that operationalize all of the above
