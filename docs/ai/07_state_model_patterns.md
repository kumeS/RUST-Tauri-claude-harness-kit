# 07 — State Model Patterns

Zustand-flavored, but the patterns are store-library-agnostic. [FACT] items
observed in source (~1500-line single store); [REC] items derived.

## 1. Single store, active-context-at-top-level [B]

One store. The active tab's fields live at the store's top level (fast paths,
simple selectors); background tabs are full snapshots (`TabSnapshot`)
including their in-flight state. Switching tabs snapshots the active one and
applies the target. [FACT]

## 2. Route async results to their owning context [A — the anti-bleed rule]

Every async completion (AI result, stream delta, TTS done) carries its
context id (tab id, utterance id) and goes through a router
(`routeTabPatch`) that:
- applies to top-level state if that context is still active,
- patches the background snapshot if not,
- **no-ops if the context was closed** (never resurrect state).
[FACT — unit-tested: background ops can't repaint the wrong tab; results for
closed tabs vanish.] Monotonic ids defeat stale events: a TTS-done event with
an old utterance id can't clear a newer playback. [FACT]

## 3. Undo = whole-model snapshots + input coalescing [B]

Structural edits push a full model snapshot onto `past` (capped ~100);
undo/redo swap between `past`/`future` and re-derive dependent flags
(staleness) for the restored model. Continuous typing in one item coalesces
into a single undo step via `lastEditChunkId` — a new step starts when focus
moves. [FACT]
[REC] Every NEW mutating action must answer: does it `commit()` (undoable) or
deliberately not (e.g. summary writes marked non-staling)? Undecided = bug.

## 4. Freshness via content hashes, consumed at the action site [A]

The load-bearing pattern (see principles §7):
- Derived data stores a hash of its source at derivation time
  (`summaryHash`).
- A cheap selector (`staleSummaryChunkIds`) lists stale items.
- **Consumers act**: AI actions run a refresh-stale pass first; the health
  bar shows the stale count; the graph panel shows an "out of date" badge.
[FACT — and the historical failure: an earlier `analysisStale` boolean was
consumed by exactly one side panel and by nothing that fired actions; stale
context flowed into AI calls silently. A flag without an action-site consumer
is decoration.]

## 5. Busy state is scoped [B]

Per-item busy (`busyChunks` set) for parallel-safe per-item ops; one
`globalBusy` label for document-wide ops (analyze, multi-edit) that must not
overlap; both isolated per tab via the snapshot mechanism. UI disables
exactly the scope that's busy, not the whole app. [FACT]

## 6. Dirty tracking + debounced autosave + guarded exits [B]

Any model mutation sets `dirty`; a debounced (1.5s) autosave persists all
dirty tabs to a session file (atomic write); startup offers restore; clean
quit clears it. Destructive exits (close tab, quit) check dirty and confirm
with explicit labels. In-flight/undo state deliberately does NOT persist —
sessions restore *documents*, not *operations*. [FACT]

## 7. Ephemeral vs durable UI state [REC, FACT-derived]

Three tiers, stored differently:
- **Model** (chunks, comments, analysis) — persisted in the document file.
- **Workspace** (open tabs, file paths, dirty) — persisted in the session.
- **Ephemeral** (palette open, panel toggles, busy, toasts, focus) — store
  fields, never persisted.
Putting an ephemeral in the document (or vice versa) is a review-blocking
category error.

## 8. Reports as state [B]

The most recent lossy-operation report (`lastExportReport {format, warnings,
at}`) is state, not a fire-and-forget toast — the health surface renders it
until replaced. Generalize to any "the user will ask 'what just happened?'"
artifact. [FACT]

## 9. Comments/annotations live on the model item [B]

Per-item annotations (review comments) live in item metadata
(`metadata.comments`, with author/kind/resolved/createdAt), so they persist
with the document, survive projections, and are undoable like any other
mutation. Panels render views over them; they own nothing. [FACT]
