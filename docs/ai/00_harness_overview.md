# 00 — Harness Overview

How the pieces of this kit fit together, and how an AI session should use them.

## Provenance markers (used throughout docs/ai and rules)

- **[FACT]** — observed directly in the source codebase the kit was extracted
  from; **[REC]** — recommendation derived from an observed failure/success.
- **[A]** universal principle · **[B]** generalize-then-use pattern ·
  **[C]** source-specific worked example (replace with your own values) ·
  **[D]** decision your project must make explicitly.

## The six layers

| Layer | Location | Loaded / fires | Purpose |
|-------|----------|----------------|---------|
| Constitution | `CLAUDE.md` | always (every session) | Invariants, task routing, session conduct, self-check. Deliberately short — if it grows past ~130 lines, push content down a layer. |
| References | `docs/ai/*.md` | on demand | Deep rationale, patterns, worked examples. A session reads the one relevant to the task, not all of them. |
| Rules | `.claude/rules/*.md` | when touching that domain | Enforceable constraints, phrased as MUST/NEVER, checkable in review. |
| Skills | `.claude/skills/*/SKILL.md` | when the trigger matches | Repeatable procedures with steps and outputs — the "how", where rules are the "what". Key outputs have fill-in forms in `.claude/forms/`. |
| Agents | `.claude/agents/*.md` | dispatched for verification | Independent reviewers with fresh context (plan-gatekeeper, code-review, adversarial-reviewer, scope-guard, permission-auditor, design-critic). They report; the session decides. Index: `AGENTS.md`. |
| Enforcement | `.claude/settings.json` + `.claude/hooks/` | mechanically, always | What no rule file can guarantee: denied commands, a done gate that runs the suites when a turn ends with modified code, per-edit compile checks, an anti-shortcut tripwire, prompt routing, post-compaction context refresh, permission-surface reminders, silent auto-format. Fires regardless of what any agent intends. |

The layering exists because context is finite: the constitution must survive
in every session; everything else must be findable *from* it. The last two
layers exist because **asked rules and enforced rules are different things**
— a rule file persuades a cooperative agent; a hook stops a confused one.

## Why this kit is shaped by failure modes [FACT-derived]

The source project's post-mortems found that its weak spots shared one shape:
**a promise guarded only by goodwill**. A README claim with no test. A
capabilities manifest listing features that didn't exist. A staleness flag no
action ever consulted. Two renderers of one visual contract kept in sync by
memory. Each rule in this kit exists to convert one of those goodwill
promises into a mechanical guarantee.

Conversely, the source project's strong spots (security guards, file-format
round-trips, load-time repair) were exactly the promises guarded by tests.
The kit's job is to make the strong pattern the default.

## How CLAUDE.md is written (patterns borrowed from Anthropic system prompts)

The constitution's structure deliberately mirrors techniques observed in
Anthropic's own production system prompts (preserved in the kit repo under
`others/` for reference):

- **Trigger → action routing**: "if the task involves X, do Y *before*
  editing" as a table, checked before work starts — not prose the session
  might recall later.
- **Hard limits + self-check**: the few absolutes are phrased as
  non-negotiable, and "done" is gated by an explicit self-interrogation
  list, mirroring the self-check-before-responding pattern.
- **Example → move → rationale triplets**: each worked example names the
  request, the correct move, and *why* — rules with receipts stick; bare
  rules drift.
- **Scale-to-complexity**: explicit guidance on how much process a change
  earns, so small fixes stay cheap and big changes can't skip the pipeline.
- **Negative space**: anti-patterns are named concretely (the AI-slop list,
  the vacuous-test shapes), because "don't do bad things" doesn't parse but
  "no rounded left-border accent cards" does.

## Scaling down to weaker models

The prose layers (references, rules, skills) assume a model that reads,
retains, and honestly self-assesses. As model capability drops, those
assumptions fail in predictable ways — misrouted tasks, instruction decay
over long sessions, optimistic "done" claims, and degenerate shortcuts
(deleting a test to make the suite green). The kit's answer is not more
prose; it is shifting weight from *asked* to *enforced and verified*:

- **done-gate hook** — "did the suites run?" stops being a self-check
  question and becomes a mechanical gate on ending the turn.
- **check-on-edit hook** — compile feedback per edit, so drift is caught
  one step after it starts, not twenty.
- **anti-shortcut hook + rules/escalation.md** — the degenerate
  green-making moves are named, detected in the diff, and forbidden;
  two failed fixes force a written escalation instead of a third guess.
- **prompt-router hook** — task routing becomes keyword-mechanical instead
  of relying on the model reading CLAUDE.md's table.
- **context-refresh hook** — the invariants are re-injected after
  compaction instead of trusting the summary to keep them.
- **forms (`.claude/forms/`)** — skill outputs become fill-in forms;
  weaker models fill forms far more reliably than they synthesize
  structure, and a half-filled form is visibly unfinished.
- **plan-gatekeeper / scope-guard agents** — verification is easier than
  generation, so narrow-rubric checking works even when the checker runs
  on the same weak model.
- **agent-memory/** — repeated mistakes accumulate into defenses instead
  of recurring.

What does NOT scale down: the taste layers (docs/ai/05, 11) and long
rationale docs. Don't compensate for a weaker model by adding rules —
convert rules into hooks, forms, and gates.

## How to use during a session

1. **Orientation**: CLAUDE.md is already loaded. Its routing table names the
   skill/rule for the task domain (UI / Rust core / IPC / permissions /
   state / tests / product doubt).
2. **Load the matching rule file** before editing that domain.
3. **If a skill trigger matches** (new feature, permission diff, new command,
   new surface, error design, blind spots) — follow the skill's steps rather
   than improvising.
4. **After implementing**: dispatch the matching verification agents
   (code-review + adversarial-reviewer for any behavior change;
   permission-auditor and design-critic for their domains). Answer every
   finding: fixed or rebutted.
5. **Before claiming done**: CLAUDE.md's six-question self-check +
   docs/ai/08_review_checklist.md + full suites + verbatim reporting of any
   failure.

## Adoption sequencing for a new project

Week 1: CLAUDE.md filled in; `.claude/settings.json` + hooks live (the
mechanical layer costs nothing to adopt and works from the first session);
rules/testing.md enforced; CI live (`templates/ci.yml` →
`.github/workflows/ci.yml`) plus the PR template.
Week 2: ui.md + design tokens agreed; permission policy baselined;
verification agents in the review loop.
Then: skills adopted one at a time as their triggers first occur.

Do not adopt everything on day one of an existing project — retrofit the
enforcement layer + testing rule + CI first (highest leverage), then the
rest as files get touched.

## Optional extensions (not shipped, worth knowing)

Patterns from the broader Claude Code ecosystem that pair well with this kit
when the need arises — add them deliberately, not by default:

- `CLAUDE.local.md` — personal, gitignored notes (machine paths, local DB
  quirks). Never team rules; those go in the tracked layers.
- Per-directory `CLAUDE.md` — for a subtree with genuinely different rules
  (e.g. a `payment/`-grade module). One extra always-loaded file per scope;
  use sparingly.
- `.mcp.json` — external tool servers (GitHub, DB, browser). Reference
  secrets via env vars, never inline.
- `.claude/workflows/` — deterministic multi-agent orchestration scripts.
  Useful at scale; noise before that. (`agent-memory/` used to sit here
  too — it now ships as a starter, see `.claude/agent-memory/README.md`.)

Note: the kit repository's own `README.md`, `AUDIT.md`, and `others/` are
documentation *about* the kit (adoption guide, provenance, source system
prompts). They are not copied into adopting projects and nothing in this
tree references them at runtime.
