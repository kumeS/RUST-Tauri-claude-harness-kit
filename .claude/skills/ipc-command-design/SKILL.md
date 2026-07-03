---
name: ipc-command-design
description: Design and wire a new backend command (Tauri IPC or equivalent) end to end. Use when a feature needs the frontend to do something only the backend can — file/network/secret access, heavy computation, native APIs.
---

# IPC Command Design

The full path of a new capability, in order. Skipping steps is how glue
accumulates logic and manifests drift. Patterns: docs/ai/02.

## Procedure

1. **Core function first.** Write the pure function in the appropriate core
   module: takes plain data (+config structs), returns
   `Result<T, AppError>`, no framework handles, no globals. If it needs
   config, the config is a parameter — this is what keeps the function
   reachable from CLI/MCP/tests later. Decide NOW whether this capability
   should eventually be headless; if yes, nothing in the core layer may
   assume a GUI.

2. **Error mapping.** New failure sources → `From` impls + the right
   `AppError` variant (see rust-error-design skill). Message text must be
   user-actionable, not debug-y.

3. **Lossy? Report struct.** If the operation can drop/degrade content,
   define the report type (`{output, warnings, counts}`) before the happy
   path, and enumerate the loss modes as warnings.

4. **Thin command.** The `#[tauri::command]` resolves runtime context
   (config dir, settings, key), validates caller-supplied inputs (paths →
   extension allowlist; URLs → guarded fetch; sizes → caps), calls the core
   function, returns. If you're writing an `if` about domain state in the
   command, move it down.

5. **Register** in the single `invoke_handler` list. If a self-describing
   manifest (CLI capabilities etc.) exists, update it in the SAME change —
   the contract test should force this.

6. **Frontend wrapper**: one typed function in the api module (never inline
   `invoke("...")` at call sites). Result/report types mirrored in TS in the
   same change.

7. **Surface it**: store action → UI control per rules/ui.md → **palette
   entry** (rule 3). Busy scope decided (per-item vs global). Async result
   routed through the context router (07 §2) so completions can't repaint a
   switched/closed context.

8. **Streaming?** Use the channel-events pattern (Update/Done), retries only
   before the first token, empty-stream guard, per-context stream state.

9. **Tests** (same change): core-function unit tests incl. failure paths;
   contract/manifest test updated; round-trip test if it's an
   import/export pair. The command itself stays glue-thin and untested by
   rule — if you feel the command needs a test, that's the signal logic
   leaked upward.

10. **Docs**: module doc states the new invariant/limits; CHANGELOG entry in
    user-outcome language; anything not yet reachable headless is labeled
    honestly wherever capabilities are described.

## Output

The wired capability + a checklist echo (steps 1–10 each marked done/N-A
with one-line evidence).
