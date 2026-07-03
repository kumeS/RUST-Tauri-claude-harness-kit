---
name: rust-error-design
description: Extend or refactor the backend error type and its user-facing behavior. Use when adding a dependency that can fail, when error messages reach users raw, or when deciding retry semantics for a new failure mode.
---

# Rust Error Design

Keeps the single-enum error model coherent as the app grows. Baseline
pattern: docs/ai/02 §2.

## The model (recap)

One `AppError` enum (thiserror). Variants per failure *category* — not per
call site, not per dependency. `#[from]` for stdlib sources; manual `From`
for third-party. Serialized to a human-readable string at the IPC boundary so
the frontend can display it directly.

## Procedure

1. **Categorize the new failure.** Does it fit an existing variant (Io,
   Serde, Network, Keyring, Config, UnsupportedFormat)? Only add a variant
   for a genuinely new *category* the user experiences differently — "what
   should the user DO about it" is the category test. Same remedy → same
   variant.

2. **Write the message for the user, not the debugger.**
   - Name the thing, not the type: "Could not read the reference file" not
     "pdf_extract error".
   - Include the actionable detail (file name, format, status code) and the
     remedy when known ("Local endpoints such as Ollama can leave the key
     blank").
   - NEVER include secrets, full internal paths, or raw config dumps.
   - The `#[error("...")]` string is UI copy. Review it as UI copy.

3. **Map upstream errors precisely.** A `From` impl may inspect the source:
   HTTP status → rate-limit vs auth vs model-not-found messages differ
   because the user's remedy differs. Don't flatten distinct remedies into
   one generic Network message.

4. **Decide retry semantics** and record them where the call happens:
   - Idempotent + transient (429/5xx before any output): shared retry with
     backoff, honor Retry-After, cap the backoff.
   - Streaming after first token: NO retry (duplication) — fail fast.
   - Non-idempotent (writes, sends): no automatic retry; surface + let the
     user decide.
   - A failure that leaves partial state: clean up before returning, or
     report exactly what remains (never both silent and partial).

5. **Guard the degenerate success.** Empty-but-Ok results (empty stream,
   zero-byte file, empty extraction) are failures wearing a success type —
   detect and convert them to errors at the boundary where emptiness becomes
   meaningful.

6. **Test the mapping**: one test per new mapping/variant asserting the
   user-visible string (its actionable content, scoped assertion), plus the
   degenerate-success guard. Failure-path tests are the point — the happy
   path already has tests.

7. **Frontend audit**: every `catch` shows the message via the standard
   notification tier (error toast, 7s, dismissible) or an inline surface —
   check the new error isn't swallowed or double-reported.

## Output

The variant/mapping diff + a two-column table: `failure scenario → exact
user-visible message`, reviewed as UI copy.
