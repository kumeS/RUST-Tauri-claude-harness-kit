# 01 — Project Principles

Eight principles. Each was followed (or violated, then repaired) in the source
codebase; provenance notes show the receipts. Classes: [A] universal,
[B] generalize-then-use.

## 1. All I/O in the backend [B — universal within Tauri/Electron-class apps]

The webview renders and edits; Rust owns disk, network, secrets, and process
lifecycle. The CSP then only needs `connect-src 'self' ipc:`, and the
capability file stays minimal because file access rides through your own
commands, not granted plugins.
**Provenance [FACT]:** source app has 24 commands, 10 minimal permissions, no
fs/shell/http plugin grants; API keys live in the OS keychain and the frontend
only ever sees a boolean.

## 2. Deterministic core, AI at the edges [A]

Any conversion the user relies on (model→export, model→view) is pure,
reproducible, and AI-free. AI reshapes *content* before or after the pipeline
(rewrite a paragraph, summarize a section) but never sits inside it, so the
same input always produces the same output.
**Provenance [FACT]:** document→slide conversion is documented "Deterministic,
AI-free" in code; AI actions are all per-chunk/pre-pipeline.
**Why it matters:** reproducibility is what makes exports testable at all.

## 3. One canonical model; everything else is a projection [A]

Editor view, slide view, analysis graph, and all export formats read the same
model. Feature data added for one projection (slide layout, subtitle flags)
lives in optional metadata and never mutates canonical content — so switching
projections is lossless by construction.
**Provenance [FACT]:** mode switching flips one field and never rewrites
chunks; slide-only fields are optional metadata; a vitest test locks this in.

## 4. Warn, don't block — on a persistent surface [A]

Lossy operations complete and return a structured report (counts + specific
warnings) instead of failing. But transient toasts are NOT an acceptable
surface for loss reports.
**Provenance [FACT + repair arc]:** exports always returned warning reports,
but they surfaced as 3.5s toasts; the post-mortem flagged "silent-feeling data
loss"; the fix stores the last export report and pins it in a persistent
health bar with a details popup. Port the *repaired* version.

## 5. Back-compat via optional fields + normalize-on-load [A]

New model fields are optional/serde-defaulted so old files load forever.
Loading always runs a repair pass (dedupe ids, clamp ranges, drop dangling
references, re-sequence) and reports what it fixed — the app never trusts a
file it didn't just write, including its own.
**Provenance [FACT]:** 6-step `normalize()` with repair notes, unit-tested;
every added feature field to date has been optional.

## 6. Every promise gets a test — or a "planned" label [A, the root principle]

README claims, self-describing manifests, doc comments, UI copy: each is a
promise. Each needs either a test that fails when the promise breaks, or an
explicit "not yet implemented" marker.
**Provenance [violation → repair, FACT]:** the CLI manifest once advertised a
PDF export that didn't exist and 9 AI verbs with no headless path; a stale doc
comment described behavior the code no longer had. The repair added contract
tests (manifest list == dispatch table, verified in CI-less local runs) and an
honest `aiActionsRunVia: "gui"` field. The pattern generalizes: **manifest
contract tests** for anything self-describing.

## 7. Freshness is state [A]

Derived data (summaries, analyses, caches) records what it was derived *from*
(content hash or revision). Whoever consumes the derived data checks freshness
at the point of use and refreshes or warns.
**Provenance [violation → repair, FACT]:** AI context once froze at the last
manual analyze with a staleness flag consumed only by a side panel — actions
fired with stale context, silently. The repair: per-item content hashes, a
refresh-stale-items pass before AI actions, and stale counts surfaced in the
persistent health bar.
**Corollary:** a staleness flag that no action site consults is decoration.

## 8. Human and machine entrances lead to the same functions [A, aspirational]

Every capability should be reachable both from the GUI and from a headless
surface (CLI/MCP), through the same pure core functions. Config loading must
therefore not require a GUI runtime handle.
**Provenance [FACT — still unfinished in source]:** the CLI reuses pure
functions for inspect/convert/export, but AI verbs remain GUI-only because
LLM config is only constructible via Tauri `AppHandle`. Design the config
seam headless-first; the source project shows the cost of not doing so.
