# 00 — Harness Overview

How the pieces of this kit fit together, and how an AI session should use them.

## Provenance markers (used throughout docs/ai and rules)

- **[FACT]** — observed directly in the source codebase the kit was extracted
  from; **[REC]** — recommendation derived from an observed failure/success.
- **[A]** universal principle · **[B]** generalize-then-use pattern ·
  **[C]** source-specific worked example (replace with your own values) ·
  **[D]** decision your project must make explicitly.

## The four layers

| Layer | Location | Loaded | Purpose |
|-------|----------|--------|---------|
| Constitution | `CLAUDE.md` | always (every session) | The 6 invariants + pointers. Deliberately short — if it grows past ~80 lines, push content down a layer. |
| References | `docs/ai/*.md` | on demand | Deep rationale, patterns, worked examples. An AI session reads the one relevant to the task, not all of them. |
| Rules | `.claude/rules/*.md` | when touching that domain | Enforceable constraints, phrased as MUST/NEVER, checkable in review. |
| Skills | `.claude/skills/*/SKILL.md` | when the trigger matches | Repeatable procedures with steps and outputs — the "how", where rules are the "what". |

The layering exists because context is finite: the constitution must survive
in every session; everything else must be findable *from* it.

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

## How to use during a session

1. **Orientation**: CLAUDE.md is already loaded. Identify which domain the
   task touches (UI / Rust core / IPC / permissions / state / tests).
2. **Load the matching rule file** before editing that domain.
3. **If a skill trigger matches** (new feature, permission diff, new command,
   UI polish, error design) — follow the skill's steps rather than improvising.
4. **Before claiming done**: docs/ai/08_review_checklist.md + full test
   suites + verbatim reporting of any failure.

## Adoption sequencing for a new project

Week 1: CLAUDE.md filled in; rules/testing.md enforced; CI live (the kit
ships a ready workflow — `templates/ci.yml` → `.github/workflows/ci.yml`)
plus the PR template (`templates/pull_request_template.md` →
`.github/pull_request_template.md`).
Week 2: ui.md + design tokens agreed; permission policy baselined.
Then: skills adopted one at a time as their triggers first occur.

Do not adopt everything on day one of an existing project — retrofit the
testing rule + CI first (highest leverage), then the rest as files get
touched.

Note: the kit repository's own `README.md` and `AUDIT.md` are documentation
*about* the kit (adoption guide, provenance). They are not copied into
adopting projects and nothing in this tree references them at runtime.
