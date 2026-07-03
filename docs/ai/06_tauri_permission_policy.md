# 06 — Tauri Permission & CSP Policy

[B] — Tauri 2 specific; the *stance* generalizes to any capability-gated
runtime (Electron contextBridge, browser extensions).

## Stance

The permission file is a public statement of what the renderer can do if
fully compromised. Keep that statement boring.

## Rules

1. **No blanket plugin grants.** `fs:*`, `shell:*`, `http:*` plugin
   permissions are effectively "renderer can do anything" — never grant them.
   File and network access ride through your own typed commands instead,
   where you control validation per operation.
   [FACT: source grants exactly 10 permissions — core window ops
   (hide/close/destroy for the lifecycle feature), opener (open external
   URLs), dialog (confirm/ask + open/save pickers). The dialog plugin picks
   *paths*; your own Rust commands do the actual I/O.]
2. **Every permission line carries a justification comment** — which feature
   needs it, and why a command can't do it instead. A permission without a
   comment fails review.
3. **CSP is part of the security model, not boilerplate.**
   [FACT baseline: `default-src 'self'`; `script-src 'self'` (no inline, no
   eval); `connect-src 'self' ipc: http://ipc.localhost` (webview can talk to
   the backend and nothing else — outbound HTTP happens in Rust);
   `object-src 'none'`; `base-uri 'self'`.]
   Documented, deliberate relaxations in source — copy the *reasoning*, not
   necessarily the values:
   - `style-src 'unsafe-inline'` — Tailwind/inline styles; acceptable but note
     it; tightening to nonces is an upgrade path.
   - `img-src https: http: data: blob:` — deliberately broad because user
     documents embed arbitrary remote/AI-generated images; this is a product
     decision, re-decide it for your product.
4. **Any CSP or capability diff triggers the `tauri-permission-review`
   skill** (see .claude/skills/). No drive-by edits.
5. **Untrusted-content URLs go through the guarded fetch** (SSRF guard:
   scheme allowlist, private/loopback/link-local/CGNAT/metadata IP blocks,
   per-hop redirect re-validation, size cap + timeout). Operator-configured
   endpoints (the user's own API endpoint setting) are exempt *by
   documented design* — they are the user's own infrastructure choice, not
   attacker-controlled content. Keep that distinction written down.
6. **Secrets live in the OS keychain** (keyring crate: macOS Keychain /
   Windows Credential Manager / Secret Service). The settings file never
   holds them; the frontend only ever receives existence booleans. Setting an
   empty key deletes the entry rather than storing "".
7. **Write paths pass an extension allowlist** per command (defense in depth:
   a compromised renderer can't coax `save` into writing `.sh`). Missing
   extensions are allowed (the OS save dialog appends one) — only *wrong*
   extensions are blocked.
8. **Renderer-reachable surface = the command list.** Review new commands as
   permission grants: what can this command be made to do with hostile
   arguments? (Path traversal, oversized payloads, protocol smuggling.)

## Review checklist for a permission/CSP diff

- [ ] Which feature motivates each added line? (comment present)
- [ ] Could a typed command with per-call validation replace the grant?
- [ ] Does the CSP change widen `connect-src`/`script-src`? (near-always no)
- [ ] Are new outbound fetches routed through the guarded fetch?
- [ ] Does any new command accept a caller-supplied path? (extension
      allowlist + no traversal)
- [ ] Updated the justification table in this file?
