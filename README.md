# Claude Harness Kit

**v1.0.0** — A drop-in set of AI-collaboration guardrails for
**Rust (Tauri 2) + React + TypeScript** desktop apps: principles, enforceable
rules, repeatable skills, review procedures, and CI/PR templates.

[![Preview](preview.png)](https://kumeS.github.io/RUST-Tauri-claude-harness-kit/)

Extracted from a real, shipping Tauri 2 desktop application (~16k LOC,
84 Rust tests + 41 vitest tests) that went through three generations of deep
post-mortem analysis. Every rule in this kit traces to a bug that actually
happened, a promise that actually drifted, or a pattern that actually
survived multiple release cycles — provenance is documented in
[AUDIT.md](AUDIT.md).

> **The one-sentence version:** every promise gets a test, or an explicit
> "planned" label. A codebase's strong areas are exactly the promises guarded
> by tests; its weak areas are exactly the promises guarded by goodwill.

---

## ⚠️ Which files go into your project — and which do not

**`README.md` (this file) and `AUDIT.md` are documentation *of this kit
repository*. They are NOT used by adopting projects — do not copy them into
your codebase.** Everything else is designed to be copied.

| Path | Copy into your project? | Notes |
|------|------------------------|-------|
| `README.md` | ❌ **No** | Describes the kit itself (this file). |
| `AUDIT.md` | ❌ **No** | Provenance record of the source codebase. Reference reading only. |
| `CLAUDE.md` | ✅ Yes → repo root | Fill every `{{PLACEHOLDER}}`, delete non-applicable lines. |
| `docs/ai/00–08_*.md` | ✅ Yes → `docs/ai/` | Reference docs, loaded on demand by AI sessions. |
| `.claude/rules/*.md` | ✅ Yes → `.claude/rules/` | Enforceable per-domain constraints. |
| `.claude/skills/*/SKILL.md` | ✅ Yes → `.claude/skills/` | Trigger-driven procedures. |
| `templates/ci.yml` | ✅ Yes → `.github/workflows/ci.yml` | Adjust the working-directory if your app is nested. |
| `templates/pull_request_template.md` | ✅ Yes → `.github/pull_request_template.md` | Condensed from the review checklist. |
| `templates/README.md` | ❌ No | Explains the templates; not needed after moving them. |
| `.gitignore` | ❌ No | Kit-repo housekeeping. Tauri projects keep their scaffold-generated one — but the `.claude/settings.local.json` line is worth adding to it. |

## Quick start

```bash
# from your project root
cp -r <kit>/docs ./          # → docs/ai/*
cp -r <kit>/.claude ./       # → .claude/rules, .claude/skills
cp <kit>/CLAUDE.md ./        # then fill in every {{PLACEHOLDER}}
mkdir -p .github/workflows
cp <kit>/templates/ci.yml .github/workflows/ci.yml
cp <kit>/templates/pull_request_template.md .github/
```

Then:

1. Fill in `CLAUDE.md` (project name, personality, commands, paths).
   It is deliberately short — if it grows past ~80 lines, push content into
   `docs/ai/`.
2. Open `.github/workflows/ci.yml` and set the working directory / package
   paths for your repo layout.
3. Read `docs/ai/00_harness_overview.md` (5 minutes) — it explains how the
   four layers (constitution → references → rules → skills) are meant to be
   loaded during AI sessions.
4. Resolve the six **[D] Needs-confirmation** decisions listed in
   `AUDIT.md §4` for your product (atomic writes, dark mode, CI provider,
   platform matrix, UI i18n, headless-twin commitment). Deciding them on
   day one is cheap; retrofitting is not.
5. Delete or rewrite anything marked **[C] Project-specific** — those are
   worked examples from the source app (its palette values, its chunk data
   model), kept for concreteness, not as defaults.

## What's inside

```
claude-harness-kit/
├── README.md                  ← kit docs (do not copy)
├── AUDIT.md                   ← provenance (do not copy)
├── CLAUDE.md                  ← template: always-loaded constitution
├── docs/ai/
│   ├── 00_harness_overview.md     how the layers fit together
│   ├── 01_project_principles.md   8 principles, with receipts
│   ├── 02_architecture_patterns.md Rust/IPC/layering patterns
│   ├── 03_ui_constitution.md      product personality + UI principles
│   ├── 04_design_tokens.md        token policy (+ replaceable example set)
│   ├── 05_feature_taste_guide.md  what to build, and how it should feel
│   ├── 06_tauri_permission_policy.md permissions + CSP stance
│   ├── 07_state_model_patterns.md store/undo/staleness/routing patterns
│   └── 08_review_checklist.md     the pre-merge walk
├── .claude/
│   ├── rules/          ui.md · rust.md · tauri-permissions.md · testing.md
│   └── skills/         feature-spec · ui-polish · tauri-permission-review
│                       · ipc-command-design · rust-error-design
└── templates/          ci.yml · pull_request_template.md · README.md
```

## Provenance markers used throughout

- **[FACT]** — observed directly in the source codebase
- **[REC]** — recommendation derived from an observed failure/success
- **[A]** universal · **[B]** generalize-then-use · **[C]** do not port ·
  **[D]** needs a per-project decision

## Assumptions & scope

- Target stack: **Tauri 2 + Rust backend, React + TypeScript frontend**
  (state-library guidance is written against Zustand but is store-agnostic).
- Not on Tauri? Drop `06_tauri_permission_policy.md`,
  `.claude/rules/tauri-permissions.md`, and the `tauri-permission-review`
  skill — the rest is stack-light.
- The kit contains **no application code** — only documentation, rules,
  skills, and CI/PR configuration templates.

## License

Add a license before publishing forks/derivatives. The kit text itself
carries no code; a documentation-friendly license (MIT / CC-BY-4.0) is a
natural fit. (This repository's owner chooses; the kit does not impose one.)
