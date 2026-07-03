# Rules: Testing

Hard constraints. Every rule here corresponds to a defect that shipped (or
nearly shipped) in the source project.

1. **Every promise gets a guard.** Any user-visible claim (README, manifest,
   UI copy, doc comment) is covered by a test that fails when the claim
   breaks — or the claim is explicitly labeled "planned". Writing the claim
   and the guard is ONE task, not two.
2. **No vacuous tests.** Before committing a test, name the precise code
   change that would make it fail. If you can't, the test is decoration.
   Specifically: string/XML/JSON assertions MUST be scoped to the element
   under test (extract the specific shape/node first), never `contains()`
   over the whole output. *(Source defect: a full-slide `contains()` check
   satisfied by an unrelated element.)*
3. **Contract tests for every dual implementation.** Two code paths rendering
   one contract (preview/export mirror, manifest/dispatch table, TS/Rust
   type pair) get a test asserting agreement — golden fixtures or direct
   list equality. *(Source defect: preview≠export drift, twice.)*
4. **Round-trip tests for every import/export pair**, including a
   second-cycle idempotency check (export→import→export produces no
   accumulation). *(Source pattern: title-chunk accumulation regression
   test.)*
5. **Test the failure path.** Every warning, fallback, and repair branch has
   a test that triggers it (bad image → warning emitted; malformed file →
   repaired + note; empty stream → loud error). Success-only suites are
   half-suites.
6. **Parsers get adversarial inputs.** Anything parsing LLM/model output or
   user files is a pure function with tests for: preambles, code fences,
   nested/unusual markers, empty input, and the wrong-but-plausible shape.
7. **Non-Latin coverage.** Text-measuring, diffing, wrapping, or
   font-touching code is tested with CJK (and mixed-script) input, on both
   screen and export paths.
8. **New mutations test their undo/history behavior** (or their documented
   exemption) and, in multi-context apps, their routing (background
   completion patches the right context; closed context → no-op).
9. **Suites run before "done"** — backend, frontend, typecheck/build. Report
   results verbatim; quote failures; never "mostly passing". A red suite
   means the task is not complete.
10. **Coverage debt is visible.** Modules with zero tests are listed in
    CLAUDE.md's project notes with the reason (e.g. "commands.rs: glue-only
    by rule"). An unexplained zero-test module fails review. CI runs all
    suites on every push (the kit ships a workflow template) — a kit
    adoption without CI is running on goodwill, which is exactly what this
    kit exists to eliminate.
