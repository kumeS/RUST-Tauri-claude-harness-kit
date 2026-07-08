# 08 — Pre-Merge Review Checklist

Walk this before declaring any change done. Each item traces to a defect
class that actually occurred in the source project.

## Correctness

- [ ] **Parity**: does this change touch anything rendered by more than one
      code path (preview + export, TS + Rust mirror, manifest + dispatch)?
      If yes: were BOTH sides changed in this same change-set, and does a
      contract test cover the agreement? *(Defect class: WYSIWYG drift — hit
      twice in source.)*
- [ ] **Vacuous tests**: for each new test, can you name the exact code
      change that would make it fail? String/XML assertions scoped to the
      specific element, not the whole output? *(Defect class: the full-slide
      `contains()` test that could never fail.)*
- [ ] **Promise sync**: does any README line, manifest field, doc comment, or
      UI copy now over- or under-state what the code does? Self-describing
      manifests re-tested? *(Defect class: advertised-but-unimplemented PDF
      export; stale "never converted" comment.)*
- [ ] **Staleness**: does this change introduce derived/cached data? Then:
      what invalidates it, and which *action site* consults freshness before
      use? A flag alone is not an answer. *(Defect class: analysisStale
      consumed only by a side panel.)*
- [ ] **Undo**: is every new mutation either committed to history or
      documented as deliberately non-undoable?
- [ ] **Context routing**: can any new async completion land after its
      tab/context closed or switched? Does it route through the patch router
      with a context id?

## Robustness

- [ ] **Error/empty/loading states** designed for every new surface?
- [ ] **Failure paths tested**, not just success (the warning fires, the
      fallback renders, the repair note appears)?
- [ ] **Lossy paths report**: specific counts + reasons, persisted to the
      report surface, never toast-only?
- [ ] **Parser hardening**: any new parsing of model/LLM output — tested
      against preambles, code fences, nested markers, empty input? *(Source
      keeps these as pure functions with 12 dedicated tests.)*
- [ ] **CJK/i18n**: text measurement, fonts (screen AND export), tokenization
      — verified with non-Latin input? *(Defect class: CJK diff collapsing
      whole paragraphs into one token.)*

## Security

- [ ] Permission/CSP diff? → run the `tauri-permission-review` skill.
- [ ] New outbound fetch of content-derived URLs → through the guarded fetch?
- [ ] New command taking caller paths → extension allowlist, no traversal?
- [ ] Secrets still keychain-only, frontend still boolean-only?

## UX (see rules/ui.md for the hard rules; taste layer: docs/ai/11)

- [ ] New command registered in the palette?
- [ ] Destructive action separated + explicit verb labels?
- [ ] Success shown by state change, not celebration?
- [ ] Icon-only buttons: none added?
- [ ] New/reshaped surface: `design-exploration` record exists (variants
      considered, direction stated)? Anti-slop sweep done (11 §8)? Spacing
      via `gap`, not margin stacking?

## Process

- [ ] Full test suites run (backend + frontend + typecheck/build) — results
      reported verbatim, failures quoted, not summarized as "mostly passing".
- [ ] Independent verification dispatched (`code-review` +
      `adversarial-reviewer` for behavior changes; `permission-auditor` /
      `design-critic` for their domains) and every Blocking finding
      answered — fixed or rebutted?
- [ ] Non-ASCII deliverables (docs in CJK etc.): scanned for
      confusable-character contamination (Cyrillic lookalikes, wrong-variant
      Han characters). *(Defect class: 见/也 artifacts in generated Japanese
      docs — invisible to casual reading, mechanical to grep.)*
- [ ] CHANGELOG entry written in user-outcome language?
- [ ] Anything you noticed but didn't fix: filed/flagged, not silently
      dropped?
