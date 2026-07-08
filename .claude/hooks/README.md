# Hooks — the enforced layer

CLAUDE.md and `.claude/rules/` *ask*; `settings.json` and these hooks
*enforce*. A rule file persuades a cooperative agent; a hook stops a
confused one. The weaker the model driving the session, the more weight
this layer carries — every hook here converts something the constitution
*asks for* into something the harness *checks*. Registration lives in
`.claude/settings.json`; machine-local overrides belong in
`settings.local.json` (gitignored).

**Scope honesty:** these are best-effort tripwires against common
spellings, not a sandbox. `protect.sh` splits commands on separators and
anchors patterns per command, so chained commands and string literals don't
false-positive — but a determined or sufficiently creative command can
still slip past. The hooks buy reaction time and catch accidents; the
review skills and agents catch intent.

## Safety hooks

| Hook | Event | Behavior |
|------|-------|----------|
| `protect.sh` | PreToolUse (Bash) | **Blocks** (exit 2): recursive force-deletes of root-level targets (`/`, `~`, `$HOME`, bare `*` — named subdirectories stay allowed), force pushes (`--force-with-lease` allowed), hard resets to remote refs, common `.env` reads/copies (template files like `.env.example` stay readable), curl/wget piped to a shell, `chmod 777`, shell-rc overwrites/appends. |
| `permission-surface-reminder.sh` | PostToolUse (Edit\|Write\|MultiEdit) | Non-blocking **feedback**: any edit to `capabilities/*.{json,json5,toml}`, `tauri.conf.json{,5}`, or `Tauri.toml` injects a reminder to run the `tauri-permission-review` skill and dispatch the `permission-auditor` agent. |

## Discipline hooks (weak-model load-bearing)

| Hook | Event | Behavior |
|------|-------|----------|
| `done-gate.sh` | Stop | When the turn ends with modified code files, runs the fast gates (`cargo test --lib`, `tsc --noEmit`, vitest/jest with `CI=1`) and **blocks the stop** with verbatim failures if red. One gate run per unique working-tree state (hash cache in `.claude/cache/`); loop-guarded via `stop_hook_active`; skip with `DONE_GATE=off`. |
| `check-on-edit.sh` | PostToolUse (Edit\|Write\|MultiEdit) | Compile-checks the edited file (`cargo check` for `.rs`, `tsc --noEmit` for `.ts/.tsx`) and feeds errors back immediately. The most expensive hook — disable with `CHECK_ON_EDIT=off` or remove from settings.json if your crate's check time makes it net-negative. |
| `anti-shortcut.sh` | PostToolUse (Edit\|Write\|MultiEdit) | Flags "make it green" moves in the diff: `@ts-ignore`/`as any`, `.only`/`.skip`/`xit`, `#[ignore]`, `todo!()`, deleted tests, unwrap outside tests. Flags are review prompts — each needs a fix or one-line justification (rules/escalation.md §5). `.claude/` and `.md` files are exempt. |
| `prompt-router.sh` | UserPromptSubmit | Keyword-classifies the prompt (JA+EN) and injects the matching CLAUDE.md routing hint as context — mechanical task routing for models that misclassify. Hints only; nothing blocks. Max 3 hints. |
| `context-refresh.sh` | SessionStart (matcher: compact) | After context compaction, re-injects a condensed copy of the six invariants + session conduct, so the constitution survives summarization. |
| `format-on-edit.sh` | PostToolUse (Edit\|Write\|MultiEdit) | **Silent hygiene**: rustfmt for `.rs` (edition from nearest `Cargo.toml`), project-local prettier for TS/JS/CSS/JSON (walk-up resolution, nested layouts work). Never blocks, never reports. |

## Design constraints (keep these when extending)

- **Fail open.** Every hook exits 0 when python3, git, or a toolchain is
  missing. Enforcement must never brick a session on a minimal machine.
- **Block only what no rule file can undo** (protect.sh, done-gate).
  Everything else is feedback (PostToolUse/Stop exit 2 = message to the
  model) or silence. Hints (prompt-router, context-refresh) are stdout on
  exit 0.
- **Never loop, never nag.** done-gate guards `stop_hook_active` and gates
  each working-tree state once; anti-shortcut fires per edit, not per
  turn. A hook the team turns off out of annoyance protects nobody.
- **Test the matrix.** The expectation list ships alongside the hooks:
  `bash .claude/hooks/test_hooks.sh`. Any new pattern gets both a
  should-block and a should-allow case — including the known
  false-positive shapes (chained commands, string literals, globs, named
  subdirectories). A hook that blocks `cargo test` is worse than no hook.
