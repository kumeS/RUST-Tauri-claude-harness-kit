# 02 — Architecture Patterns

Concrete patterns with provenance. [FACT] = observed in source; [REC] =
derived recommendation.

## 1. Three-layer backend [B]

```
pure core modules  →  thin command layer  →  frontend api wrapper
(no runtime deps)     (#[tauri::command],     (one typed function per
                       AppHandle only here)    command, one file)
```

- Core modules (file I/O, converters, AI client, net guard) take plain data
  and return `Result<T, AppError>`. No `AppHandle`, no globals. [FACT]
- The command layer is glue only: resolve config/paths from the runtime
  handle, call the core function, map the error. If a command grows logic,
  extract it down. [FACT: commands.rs holds ~0 domain logic and 0 tests —
  acceptable *only because* it stays trivial.]
- The frontend wraps every command in one typed function in a single `api.ts`
  so call sites never `invoke("string")` directly. [FACT]

**Why:** the core layer is what makes headless surfaces (CLI/MCP) and tests
cheap. The source project's one regret: LLM *config loading* lives in the
command layer (AppHandle-bound), so AI verbs can't run headless. [REC: config
loading belongs in the core layer with an injectable source.]

## 2. Single error enum, human-readable at the boundary [B]

One `AppError` enum (thiserror) with a variant per failure *category* (Io,
Serde, Network, Keyring, Config, UnsupportedFormat, Other), `#[from]` for
stdlib sources, manual `From` for third-party ones. It serializes to a plain
human-readable string so the frontend's `catch` can show it directly. [FACT]
See the `rust-error-design` skill for extension procedure.

## 3. Streaming with retry-before-first-token [B]

SSE/token streaming retries transient failures (429/5xx, with Retry-After or
capped exponential backoff) **only until the first delta arrives**; after
that, failures surface immediately — retrying mid-stream would duplicate
emitted text. Non-streaming calls retry the whole request. A shared
finalize guard rejects empty streams loudly rather than committing "".
[FACT — note this was originally asymmetric (streaming had *no* retry) and
was repaired; port the repaired version.]

## 4. Structured warning reports for lossy pipelines [A]

Every lossy converter returns `{ output, warnings: Vec<String>, counts }`
rather than silently degrading. Warnings are specific ("2 extra images were
left out — only one image per slide"), and the report is persisted for the
health surface (see 07/03). [FACT]

## 5. Dual implementations need contract tests [A]

When two code paths render one visual contract (TS live preview + Rust export
in the source app), drift is a *structural* inevitability, not a discipline
failure — it happened twice there despite careful review. Options in order of
preference: [REC]
1. Single source of truth (one implementation, other side consumes output).
2. Contract tests: golden fixtures both sides must reproduce.
3. At minimum: header comments cross-linking the mirrored files + a review
   rule that edits must land in lockstep in one session.

The same applies to self-describing manifests: test `manifest == dispatch
table` so capability claims can't drift. [FACT: source added exactly this.]

## 6. Normalize-on-load with repair notes [A]

Loading user data runs an idempotent repair pass (empty containers, duplicate
ids, out-of-range values, unknown enum values coerced, dangling references
pruned, order re-sequenced) and returns human-readable notes. The frontend
marks the document dirty when repairs occurred so the cleaned version gets
saved. [FACT] Write repairs as independent steps; test each in isolation
*and* consider one test with several problems at once. [REC — source lacks
the combined-problems test.]

## 7. Client-side rendering handoff [B]

Some artifacts only the webview can render (Mermaid→SVG/PNG in source). For
exports, the frontend rasterizes and attaches a snapshot to the model
(`rendered_image` data URL); the backend embeds the snapshot if present and
emits an honest warning if absent ("export from the app to include them" —
headless exports can't rasterize). [FACT] Generalize: when a capability is
frontend-only, make its *absence* explicit in backend output, never silent.

## 8. Atomic writes for anything you'd hate to lose [A]

Temp-file + rename for state files. [FACT: session autosave does this;
main document save did NOT at audit time — flagged [D]. REC: default to
atomic everywhere a crash mid-write corrupts user data.]

## 9. Safe outbound fetch as the single entry point [B]

One `safe_fetch(url, limits)` used by every content-derived fetch: scheme
allowlist, private/loopback/metadata IP blocking (incl. IPv4-mapped IPv6),
manual redirect following with re-validation per hop, Content-Length
pre-check plus streaming-abort size cap, timeout. Operator-configured
endpoints (the user's own AI endpoint) may bypass it by design — document
that distinction. [FACT]

## 10. Panels lazy-load; boundaries reset by key [B]

Heavy panels (graph viz, review) load via `React.lazy` on first open. The
error boundary wraps the main editing surface and is **keyed on view
identity** (tab id + mode) so a crash in one view can't trap the user in a
dead boundary after switching. [FACT]
