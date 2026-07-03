# Rules: Tauri Permissions & CSP

Hard constraints for `capabilities/*.json`, `tauri.conf.json` security
section, and anything renderer-reachable. Policy rationale in docs/ai/06.

1. **NEVER grant `fs:*`, `shell:*`, or `http:*` plugin permissions.** File
   and network access go through typed app commands with per-call
   validation.
2. **Every permission line needs a justification comment** naming the feature
   that requires it and why a command can't replace it. No comment → reject.
3. **CSP edits are security changes**, not config tweaks:
   - `script-src` stays `'self'` — no inline, no eval, no CDN. Non-negotiable.
   - `connect-src` stays backend-IPC-only; the webview never gains direct
     outbound HTTP. Outbound requests belong in Rust.
   - Widening `img-src`/`media-src` is a product decision — document it in
     docs/ai/06 when made.
4. **Any diff to permissions or CSP triggers the `tauri-permission-review`
   skill** before merge.
5. **New commands are reviewed as attack surface**: assume hostile arguments.
   Paths → allowlist + traversal check; URLs → guarded fetch; sizes →
   explicit caps; strings that reach a shell or SQL → forbidden by design.
6. **Secrets**: OS keychain only. Never in settings files, documents,
   session files, logs, or error messages. Frontend receives existence
   booleans, never values. Empty-value set = delete the entry.
7. **Events emitted on the app bus are GUI-internal.** Anything an external
   process must observe needs a deliberate, documented surface (file, CLI
   verb, socket) — never assume the event bus is reachable from outside.
