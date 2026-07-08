# 10 — Blind-Spot Audit Method

Why the harness includes a product-interrogation layer, and how to write
questions that actually find blind spots. The runnable procedure lives in
`.claude/skills/blind-spot-audit/SKILL.md`; this file is the rationale.

## The gap this fills

Every other layer of this kit guards *stated* promises: tests guard claims,
rules guard domains, skills guard procedures. None of them can guard a
promise nobody thought to state. The most expensive defects in the source
project were not broken features — they were features that worked exactly as
designed for a user who didn't exist, and workflows whose real pain point
was one step outside the spec.

Four knowledge categories, by guardability:

1. Known and written down → guarded by tests (rules/testing.md).
2. Known but never written down → extracted by `feature-spec`.
3. Known-unknowns → the developer asks; normal Q&A handles it.
4. **Unknown-unknowns** → nothing extracts these except adversarial
   interrogation from perspectives the developer doesn't inhabit. This is
   the blind-spot audit.

## Why adversarial, why four options, why one at a time

- **Adversarial lenses before questions**: the builder's bias is "what I
  built is good", and an interviewer sharing the builder's context shares
  the bias. Running independent read-only critiques (first-run user, user
  mid-disaster, user who churned, recipient of the output, support
  engineer…) generates doubts the builder-mind won't.
- **Four options per question**: an open question invites the answer the
  developer already believes. Four *competing worldviews* — each implying a
  different product decision, at least one uncomfortable — force a real
  choice with a real cost. The option set is the instrument; writing it is
  most of the work.
- **One question at a time**: each answer re-aims the next question. A
  batch of ten questions is a survey; a sequence of ten is an
  interrogation. Surveys collect opinions; interrogations resolve
  ambiguity.
- **In the developer's language**: comprehension friction is fatal here —
  the developer must feel the discomfort of the trade-off, not parse
  translation.

## What "done" means

Not a question count. The audit ends when answers stop moving the product
model, and it ends with a **meta-observation**: the single assumption
underneath most of the blind spots found. Everything lands in a written
report (`project.md` by convention) where each settled decision is phrased
so it can become a `feature-spec` acceptance criterion later — the audit
feeds the promise→test pipeline; it never bypasses it.

## Scope guard

This method deliberately excludes engineering hygiene (tests, CI, security
posture) — those have rules and skills already, and letting the audit drift
there is how it degenerates into a checklist walk. Product quality, real
utility, usability. Nothing else.
