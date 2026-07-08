# Rules: React / Frontend

Hard constraints for React + TypeScript changes. Rationale: docs/ai/02
(architecture), 07 (state patterns). UI look-and-feel rules live in ui.md —
this file is about component/state/type discipline.

1. **Components are projections.** They render the model and dispatch
   actions — no business logic, no model→output conversion inline. Any
   nontrivial derivation is a pure, exported, tested function; the component
   calls it.
2. **One IPC wrapper module.** Raw `invoke()` appears in exactly one typed
   api-wrapper file. Components and store actions call the wrapper — never
   `invoke` directly. New commands extend the wrapper in the same change
   (see ipc-command-design skill).
3. **Single store; narrow selectors.** Components subscribe to the smallest
   slice they render. NEVER copy model state into `useState` — local state
   is for transient input drafts only, with an explicit commit-to-store
   path.
4. **Async results route by context id** (07 §2). Every completion (AI
   result, stream delta, background op) goes through the patch router:
   applies to the active context, patches background snapshots, **no-ops if
   the context closed**. Monotonic ids defeat stale events. A bare
   `set()` in an async callback fails review.
5. **Every mutating action answers the undo question** (07 §3): `commit()`
   to history, or a documented exemption. It also sets `dirty`. Undecided
   is a bug, not a default.
6. **State tier discipline** (07 §7): model (document file) / workspace
   (session file) / ephemeral (never persisted). Putting a field in the
   wrong tier is a review-blocking category error.
7. **Busy state is scoped** (07 §5): per-item busy sets for parallel-safe
   ops, one global-busy label for exclusive ops. Disable exactly the busy
   scope, never the whole app.
8. **Effects are contained.** Side effects live in store actions or
   dedicated hooks — never in render. Every listener, subscription, and
   timer cleans up; Tauri event listeners `unlisten` on unmount. An effect
   that syncs store state to store state is a design smell — derive it.
9. **TS mirrors of Rust types live in one file** and change in lockstep
   with the Rust model in the same change-set, guarded by a contract test
   (rust.md §5, testing.md §3). Hand-drifting a mirror fails review.
10. **No `any`, no `@ts-ignore`.** Narrow, commented exceptions only
    (the comment states the constraint forcing it). Props are explicitly
    typed; discriminated unions are switched exhaustively (a `never` check
    catches new variants at compile time).
11. **Boundaries and lazy-loading** per ui.md §14: heavy panels lazy-load;
    error boundaries around major surfaces are keyed on view identity.
12. **Text code is CJK-aware** (testing.md §7): no naive char-count
    width/wrap/diff assumptions; anything measuring or splitting text is
    tested with CJK and mixed-script input.
