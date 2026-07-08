# Rules: Escalation & Anti-Shortcuts

Hard constraints for what to do when things go wrong. Written for every
model tier, load-bearing for weaker ones: these are the failure modes that
grow as model capability shrinks.

1. **Two strikes, then stop.** If the same fix has failed twice, a third
   blind attempt is forbidden. Stop editing, fill in
   `.claude/forms/escalation-report.md` (goal, both attempts with verbatim
   errors, ranked remaining hypotheses, the decision/info needed), and ask
   the user.
2. **Never make a suite green by weakening it.** All of the following are
   forbidden as "fixes": deleting or skipping tests (`.skip`, `.only`,
   `xit`, `#[ignore]`), loosening assertions, hardcoding expected outputs,
   `@ts-ignore` / `as any` casts, catch-and-ignore, commenting out failing
   code, `todo!()` / `unimplemented!()` as a landing state. If a test is
   *genuinely wrong*, say so explicitly and fix the test with the
   justification in the same report — that is a spec change, not a shortcut.
3. **A red suite is information, not an obstacle.** Quote it verbatim.
   "Done with a known red suite" does not exist (CLAUDE.md self-check §1).
4. **Degrade transparently.** If a skill step cannot be completed (missing
   tool, missing info, missing access), name the step and why — never
   silently skip it and continue as if the procedure held.
5. **Answer every tripwire flag.** The anti-shortcut hook's flags are
   review prompts, not verdicts: each one gets either a fix or a one-line
   justification before claiming done.
6. **When stuck, prefer asking over guessing** for user-owned decisions,
   and **reading over recalling** for facts (CLAUDE.md session conduct).
   The cheapest escalation is a precise question with the evidence attached.
