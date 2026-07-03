<!-- Claude Harness Kit — PR template.
     Destination: .github/pull_request_template.md
     Condensed from docs/ai/08_review_checklist.md — the full walk lives
     there; this is the merge-gate summary. -->

## What & why

<!-- One paragraph, user-outcome language. Link the feature-spec block if one
     exists (it should, for features). -->

## Suites

- [ ] `cargo test --lib` green (quote failures verbatim, don't summarize)
- [ ] `npm test` green
- [ ] `npm run build` (typecheck) green

## Harness gates (delete lines that genuinely don't apply)

- [ ] **Parity** — every dual-rendered contract (preview/export, TS/Rust
      mirror, manifest/dispatch) changed on BOTH sides here, contract test
      updated
- [ ] **Promises** — no README/manifest/doc-comment/UI copy now over- or
      under-states the code; new claims have guards or "planned" labels
- [ ] **Tests can fail** — each new test's assertions are scoped; I can name
      the code change that would break each one
- [ ] **Staleness** — new derived/cached data has an invalidation story AND
      an action-site consumer
- [ ] **Loss reports** — lossy paths return specific warnings on a
      persistent surface (not toast-only)
- [ ] **States** — new surfaces ship empty/loading/error states
- [ ] **Undo/routing** — new mutations are committed to history (or
      documented exempt); async completions route by context id
- [ ] **Permissions/CSP** — untouched, or `tauri-permission-review` verdict
      table attached
- [ ] **UI rules** — palette entry added for new commands; no icon-only
      buttons; destructive actions separated with explicit verb labels
- [ ] **CJK/i18n** — text measuring/diffing/font paths exercised with
      non-Latin input

## Out of scope / follow-ups

<!-- Anything noticed but deliberately not fixed — filed, not dropped. -->
