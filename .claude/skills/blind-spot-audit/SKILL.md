---
name: blind-spot-audit
description: Surface what the developer doesn't know they don't know — about product quality, real-world utility, and usability, NOT engineering hygiene. Use when direction feels uncertain, before investing in a big feature, after an MVP works but "something is off", or when explicitly asked to find blind spots. Read-only — never edits code.
---

# Blind-Spot Audit

Requirements gathering finds what the developer can articulate. This skill
hunts the other three categories: what they know but never wrote down, what
they know they don't know, and — most valuable — what they haven't thought
to think about. The output is resolved ambiguity, on paper.

## Hard constraints

- **Read-only.** No code edits, no file changes outside the report. State
  this at the start and honor it even if a fix looks trivial.
- **Product lens, not engineering-manners lens.** Missing tests, CI gaps,
  security nits have their own rules and skills. Here the questions are: is
  this feature *truly needed*? Would a real user *actually reach for this*?
  Where does the workflow *actually hurt*?
- **Interview in the developer's language.** (For this kit's origin
  project: Japanese.) Understanding is the deliverable; language friction
  destroys it.

## Procedure

1. **Counter your own bias first.** The builder's bias is "what I built is
   good." Before asking anything, run an independent multi-lens critique:
   read the codebase/specs read-only and criticize the product from
   adversarial perspectives that don't overlap — e.g. the first-run user,
   the daily power user, the user mid-disaster (crash, data loss, wrong
   output under deadline), the user who stopped using it, the competitor's
   PM, the person the output is *sent to*, the accessibility user, the
   support engineer reading bug reports. 8–10 lenses; parallel subagents
   are ideal (they must also be read-only). Collect concrete doubts, not
   themes.

2. **Distill doubts into questions that have a wrong answer.** A blind-spot
   question is decidable: the developer must pick, and picking costs
   something. "Who is this for?" is weak; "When the export mangles a table
   the night before a deadline, what does the user do at 2am — retry, hand-
   edit the output, or abandon the app?" is strong.

3. **Ask ONE question at a time, each with 4 adversarial options.** The
   options are competing worldviews, not multiple-choice trivia — each
   option should imply a different product decision, and at least one
   should be uncomfortable ("this feature shouldn't exist"). Include an
   escape hatch for "none of these — here's the reality". Wait for the
   answer before the next question; each answer re-aims the next question.

4. **Chase ambiguity to zero.** 5–10 questions is the usual span, but the
   stop condition is "no answer changed our model of the product twice in a
   row" — not a question count. If an answer contradicts the code or an
   earlier answer, say so and resolve it on the spot.

5. **Meta-observation — the climax.** After the last question, step back
   and name the pattern across all answers: the one assumption underneath
   most of the blind spots (e.g. "every gap traces to designing for the
   demo, not the Tuesday-afternoon user"). This synthesis is the most
   valuable line in the report; do not skip it.

6. **Write everything to `project.md`** (or the path the user names):
   - the lenses used and each lens's sharpest doubt;
   - every question, the chosen option, and what that decision *rules out*;
   - contradictions found and how they were resolved;
   - the meta-observation;
   - a short list of decisions now settled, each phrased so it can become a
     feature-spec acceptance criterion later.

## Follow-through

The audit produces decisions, not tasks. When the developer acts on one,
route it through the normal harness: `feature-spec` for anything new,
`design-exploration` for surface changes. An audit whose findings bypass the
spec pipeline just creates a new generation of untested promises.
