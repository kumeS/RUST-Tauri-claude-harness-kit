# {{PROJECT_NAME}}

{{ONE_PARAGRAPH: what this app is, who it is for, and the one-sentence product
personality — e.g. "quiet, dense but not cramped, macOS-native restraint".}}

## Stack & commands

- Backend: Rust (Tauri 2) — all disk/network/secret I/O lives here.
  Source: `src-tauri/src/`.
- Frontend: React + TypeScript. State: {{Zustand / other}}. Styling:
  {{Tailwind with semantic tokens / other}}.
- Backend tests: `cargo test --lib` (run in `src-tauri/`)
- Frontend tests: `npm test`  ·  Typecheck+build: `npm run build`
- {{Adjust paths if the app lives in a subdirectory of this repo.}}

Run all three before claiming any task is done; report failures verbatim.

## Non-negotiable invariants

1. **All I/O in Rust.** The webview never reads disk, opens sockets, or holds
   secrets. New capabilities are new typed commands, not new frontend
   permissions. Secrets: OS keychain only; the frontend sees booleans.
2. **Every promise gets a test.** Anything user-visible we claim (README,
   capabilities manifest, UI copy, doc comments) is either covered by a test
   that fails when it breaks, or explicitly labeled "planned". Writing the
   claim and the guard is one task.
3. **One canonical data model.** Views, panels, and exports are projections
   of the same model. Two code paths rendering one contract (preview vs
   export, manifest vs dispatch table) get a contract test.
4. **Deterministic core, AI at the edges.** Model→output conversions are pure
   and reproducible; AI reshapes content before/after the pipeline, never
   inside it.
5. **Warn, don't block — persistently.** Lossy operations complete with a
   structured warning report (`{output, warnings, counts}`) shown on a
   persistent surface (health bar / report panel), never toast-only.
6. **Freshness is state.** Derived data (summaries, caches, analyses) carries
   a content hash; the code that *uses* it checks staleness at the point of
   use. A staleness flag nobody consumes is decoration.

## Where the details live (read on demand)

- Principles & rationale ......... docs/ai/01_project_principles.md
- Architecture patterns .......... docs/ai/02_architecture_patterns.md
- UI constitution & tokens ....... docs/ai/03_ui_constitution.md, 04_design_tokens.md
- Feature taste .................. docs/ai/05_feature_taste_guide.md
- Permissions / CSP policy ....... docs/ai/06_tauri_permission_policy.md
- State model patterns ........... docs/ai/07_state_model_patterns.md
- Pre-merge checklist ............ docs/ai/08_review_checklist.md
- Enforced rules ................. .claude/rules/{ui,rust,tauri-permissions,testing}.md

## Working agreement for AI sessions

- **New feature?** Run the `feature-spec` skill first: prose intent →
  acceptance criteria → tests → implementation. Never implement directly
  from an unconverted prose request.
- **Touching capabilities/CSP?** Run the `tauri-permission-review` skill.
- **New IPC command?** Follow the `ipc-command-design` skill end to end
  (pure core fn → thin command → error mapping → registration → typed
  frontend wrapper → palette entry → tests).
- **UI change?** Obey `.claude/rules/ui.md`; finish with the `ui-polish`
  skill on the touched surface.
- **Dual implementations** (preview + export of one visual, TS/Rust type
  mirrors) are edited by ONE session in lockstep, then verified
  adversarially — never split across parallel agents.
- **Before "done":** walk docs/ai/08_review_checklist.md, run all suites,
  quote any failure. A red suite means not done.

## Project-specific notes

{{Platform matrix (macOS-only? which features are OS-gated?), release
process & signing, data-file format + back-compat policy, domain vocabulary.
Keep this short — push details into docs/ai/.}}
