# Rules: Rust Backend

Hard constraints for backend changes. Rationale in docs/ai/02.

1. **Core functions take data, not runtime handles.** Domain logic lives in
   pure modules with `fn(input) -> Result<T, AppError>`. `AppHandle` (or any
   framework handle) appears ONLY in the command layer. If a core function
   needs config, it takes the config struct as a parameter.
2. **Commands are glue.** A `#[tauri::command]` resolves paths/config, calls
   one core function, maps errors. If a command accumulates logic or branches,
   extract downward. (Commands having zero tests is acceptable only while
   they stay trivial.)
3. **No `unwrap`/`expect` outside tests.** Failures become `AppError`
   variants. New third-party error sources get a `From` impl and a variant
   with a human-readable, user-actionable message.
4. **Lossy pipelines return report structs** (`{output, warnings, counts}`)
   with specific, counted warnings — never silent degradation, never a bare
   `Ok(())` from an operation that dropped content.
5. **New optional model fields**: serde-optional (`skip_serializing_if`,
   `default`) for back-compat, AND handled in the load-time `normalize()`
   repair pass (invalid value → coerce + repair note), AND mirrored in the TS
   types in the same change.
6. **Untrusted-content URLs go through the guarded fetch** (`safe_fetch`).
   Adding a raw `reqwest` call for content-derived URLs fails review.
   Operator-configured endpoints are the documented exception.
7. **Caller-supplied write paths pass the extension allowlist** check.
8. **Streaming retries only before the first emitted token**; after first
   delta, fail fast (no duplicated output). Non-streaming calls use the
   shared retry/backoff (honor Retry-After; cap the backoff). Empty streams
   fail loudly — never commit an empty result over existing content.
9. **Atomic writes** (temp + rename) for any file whose corruption loses
   user data.
10. **Module docs state constraints, not narration.** The doc comment says
    what invariants the module keeps and what its known limits are (and
    labels unbuilt work "planned"), so self-description never over-claims.
11. **Tests are colocated** (`#[cfg(test)] mod tests`) and every public
    behavior change lands with a test in the same module — especially
    parsers, converters, and anything with a TS mirror (contract test).
12. **Platform-gated features** (`#[cfg(target_os)]`) return an explicit,
    user-readable error on unsupported platforms — never a silent no-op.
