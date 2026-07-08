---
name: feature-spec
description: Convert a prose feature request into testable acceptance criteria BEFORE implementation. Use when starting any new feature, when a request arrives as a complaint or wish ("X is weak", "I want Y"), or before delegating implementation work.
---

# Feature Spec

Prose intent is unmeasurable; unmeasurable intent drifts. This skill converts
a request into a spec block whose every line can become a test.

## Why this exists

The source project's biggest systemic issue was promises guarded only by
goodwill. The root cause: features were built from prose ("the layout
function is weak") and the builder inferred the requirements. Inference
worked — but nothing recorded what "done" meant, so claims and code drifted
apart later.

## Procedure

1. **Restate the request as outcomes.** For each thing the user said, write
   what the user will be able to DO afterward (not what code will exist).
   Ask (or infer and mark as assumption): who triggers it, from where, how
   often, on what data.

2. **Write the acceptance criteria block:**
   ```
   FEATURE: <outcome-named title>
   TRIGGERS: <surfaces + palette entry name>
   CRITERIA (each must be mechanically checkable):
     1. Given <state>, when <action>, then <observable result>
     2. ...
   NON-GOALS: <adjacent things deliberately excluded, with one-line reasons>
   ASSUMPTIONS: <inferences the requester should be able to veto at a glance>
   ```

3. **Run the standard interrogations** (each yes spawns a criterion):
   - Destructive or non-destructive? If it transforms content: side-channel
     + way back? (taste guide §1)
   - Does it create derived/cached data? → what invalidates it, which action
     site checks freshness? (principles §7)
   - Does it render the same contract in more than one place? → contract
     test criterion. (principles §6)
   - Can it lose content (export, conversion, cap)? → report struct +
     persistent surface criterion.
   - Auto behavior? → override + return-to-Auto criterion.
   - New command? → palette entry + (if applicable) headless/CLI parity or
     an explicit "GUI-only, labeled honestly" criterion.
   - Empty / loading / error states named?
   - Non-Latin input relevant? → CJK criterion.

4. **Translate criteria to test names** before implementation. Each
   criterion gets the test file + test name that will guard it. A criterion
   with no imaginable test must be rewritten until it has one.

5. **Get the spec vetoed** (show requester the block — assumptions
   especially) or, when running autonomously, record it in the change
   description so the veto can happen at review.

6. Only then: implement. The spec block goes into the PR/commit description;
   the review checklist (docs/ai/08) verifies criteria == tests.

## Output

The spec block (step 2) + the criterion→test mapping (step 4). Nothing else;
this skill produces no implementation.

A fill-in form of this output lives at `.claude/forms/feature-spec.md` —
copy it and fill every field top to bottom. Prefer the form whenever
structure discipline matters (weaker models, delegated implementation,
autonomous runs): a half-filled form is visibly unfinished in a way that
half-remembered prose is not.
