---
name: tauri-permission-review
description: Security review of any diff touching Tauri capabilities, CSP, or renderer-reachable surface. Use whenever capabilities/*.json or the tauri.conf.json security section changes, or when a new command accepts caller-controlled paths/URLs.
---

# Tauri Permission Review

A gate, not a formality. Policy: docs/ai/06; hard rules:
.claude/rules/tauri-permissions.md.

## Procedure

1. **Collect the exact diff**: capabilities files, `tauri.conf.json`
   security section, and the `invoke_handler` command list (new/changed
   commands are permission grants in disguise).

2. **Classify every added/changed line:**

   | Class | Meaning | Action |
   |-------|---------|--------|
   | GRANT | new plugin permission | justify or replace with a command |
   | WIDEN | CSP source list grows | product decision — document in 06 |
   | SURFACE | new/changed command | hostile-argument analysis (step 4) |
   | TIGHTEN | anything narrowing | approve, note in changelog |

3. **For each GRANT**, answer in writing:
   - Which feature requires it (link the feature spec)?
   - Why can't a typed command with per-call validation do it? (`fs:*`,
     `shell:*`, `http:*` → the answer is nearly always "it can" → reject.)
   - Justification comment added next to the permission line?

4. **For each SURFACE (command) — hostile-argument analysis:**
   - Paths: extension allowlist applied? Traversal (`..`, absolute paths to
     app-internal dirs) considered? Write vs read distinction respected?
   - URLs: routed through the guarded fetch (SSRF checks, size caps,
     timeout, per-hop redirect re-validation)? Or documented as
     operator-configured (the one legitimate exemption)?
   - Payloads: size-bounded? Deserialization of attacker-shaped JSON safe
     (serde with unknown-field tolerance, no panics)?
   - Secrets: can any argument/return leak a secret or its length? Frontend
     must only ever see booleans about secrets.
   - Errors: do error messages leak paths/config that the renderer
     shouldn't learn?

5. **CSP check**: `script-src` still `'self'` alone; `connect-src` still
   IPC-only; any widening of img/media/font sources flagged as a WIDEN with
   a written product rationale.

6. **Verdict table** — one row per diff line: `line → class → verdict
   (approve / approve-with-comment / reject) → reasoning`. A single reject
   blocks the merge until resolved.

## Output

The verdict table + any justification comments that must be added to the
files before merge. If everything tightens or is justified: say so
explicitly — "reviewed, N grants justified, 0 rejected" — never a bare LGTM.
