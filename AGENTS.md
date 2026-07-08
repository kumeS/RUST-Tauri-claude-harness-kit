# Agents

Entry point for AI coding agents. **The constitution lives in
[CLAUDE.md](CLAUDE.md)** — read it first; this file only indexes the agent
layer. (Tools that read AGENTS.md instead of CLAUDE.md: treat CLAUDE.md as
the authoritative instruction set for this repository.)

## Subagents (`.claude/agents/`)

Specialized reviewers, dispatched for *independent verification* — they
report, the main session decides. All six are instructed to report and
never edit; their tool grant omits Edit/Write (Bash is included for
`git diff` and running suites — instructed-read-only, not sandboxed).

| Agent | Lens | Dispatch when | Output |
|-------|------|--------------|--------|
| `plan-gatekeeper` | Is the plan complete before code exists — files, criteria, tests, routing | Before implementing any multi-file change; always for weaker models | GO / REVISE + rubric table |
| `code-review` | Does the code do what it means to do — bugs, edge cases, races | Before merging any nontrivial change | Verdict + confirmed bugs with failure scenarios + test gaps |
| `adversarial-reviewer` | Does the change honor the harness — promises, contracts, rules | Any behavior-changing diff is complete, before claiming done | Verdict + clause-cited findings (blocking / should-fix / consider) |
| `scope-guard` | Does the diff match the ask — nothing missing, nothing extra | Before merging; after long sessions or delegated implementation | IN-SCOPE / NEEDS ANSWERS + file classification + orphaned asks |
| `permission-auditor` | Hostile arguments against the renderer-reachable surface | Capabilities files, `tauri.conf` security, or a command taking caller paths/URLs changed | PASS/FAIL + attack scenarios + required fixes |
| `design-critic` | Personality, craft, and UI-rule compliance of one surface | A UI surface was built or visually reshaped | SHIP / POLISH-FIRST + defect list against docs/ai/03·04·11 |

`code-review` and `adversarial-reviewer` are complementary, not redundant:
one hunts defects in what the diff *does*, the other violations of what the
harness *demands*. Large changes dispatch both (they run in parallel).
`plan-gatekeeper` (before code) and `scope-guard` (after code) bracket the
implementation — the pair matters most when a weaker model implements.

## Usage policy

- **Verification is independent or it is theater.** The session that wrote
  the code does not review its own work as the only gate — dispatch the
  matching subagent and answer its findings before "done".
- **Dual implementations are never split across parallel agents** (CLAUDE.md
  routing table). Subagents here verify; they do not implement halves.
- **Skills are procedures, agents are perspectives.** When a skill exists for
  the task (`.claude/skills/`), the implementing session runs the skill;
  the subagent then checks the result with fresh context.
- Subagent findings are answered explicitly: fixed, or rebutted with a
  reason. Silently dropping a Blocking finding fails review.

## The rest of the harness (context for agents landing here first)

- `CLAUDE.md` — invariants, task routing, self-check. Always loaded.
- `.claude/rules/` — per-domain MUST/NEVER constraints (ui, rust, react,
  tauri-permissions, testing, escalation).
- `.claude/skills/` — trigger-driven procedures (feature-spec,
  ipc-command-design, tauri-permission-review, rust-error-design,
  design-exploration, ui-polish, blind-spot-audit).
- `.claude/forms/` — fill-in output forms for the skills (spec,
  exploration record, escalation report).
- `.claude/settings.json` + `.claude/hooks/` — mechanical enforcement
  (denied commands, done gate on stop, per-edit compile checks,
  anti-shortcut tripwire, prompt routing, post-compaction refresh). These
  fire regardless of what any agent intends.
- `.claude/agent-memory/` — accumulated pitfalls and decisions.
- `docs/ai/` — rationale and patterns, loaded on demand.
