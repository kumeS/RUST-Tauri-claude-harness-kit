# 03 — UI Design Constitution

The product-personality contract. The first half is the constitution itself;
the second half shows how the source codebase implements each clause, so the
clauses stay concrete.

## Product Personality

- **Quiet.** The app never celebrates itself. Success is shown by state, not
  by announcement.
- **Dense but not cramped.** High information density with generous line
  height and restrained chrome.
- **macOS-native restraint.** Feels like a system app: system font for
  chrome, native dialogs for destructive choices, no custom theatrics.
- **For professionals, without settings sprawl.** Powerful, but options are
  earned progressively, not dumped on the first screen.

## UI Principles

1. **Primary actions within 2 clicks.** If a common action needs three, add a
   palette entry or a surface-local control.
2. **The first screen never makes the user think.** Sensible defaults; no
   setup wizard walls; configuration is reachable, not required.
3. **Destructive actions are clearly separated** — distinct placement,
   explicit verb labels ("Discard & close", never "OK"), native confirm
   dialogs for irreversible loss.
4. **State is always visible.** Saved/unsaved, busy, stale, warnings: one
   persistent strip, always on, never modal.
5. **Every surface designs its empty, loading, and error states** — before
   shipping, not after the first bug report.
6. **Advanced features hide behind progressive disclosure** — popovers,
   panels, and the palette; never a wall of toggles.

## Do Not

- Do not pile settings onto the top-level screen.
- Do not ship icon-only buttons (label or tooltip + accessible name, always).
- Do not reach for a modal when a popover, panel, or inline state works.
- Do not over-notify on success — a quiet state change beats a toast; a toast
  beats a dialog; a dialog is for decisions only.

---

## How the source app implements each clause [FACT — worked examples]

- **2 clicks / discoverability:** a ⌘K command palette lists ~25 commands
  (file, export, AI, view, speech, edit, app) with substring search and
  keyboard navigation — the palette is the guarantee that nothing is more
  than "⌘K + Enter" away. New commands MUST register a palette entry
  (see rules/ui.md).
- **State visibility:** a one-line persistent HealthBar (28px) at the bottom:
  save-state dot (amber/emerald), paragraph/word counts, analysis freshness
  with "out of date" badge and stale-summary count, busy label, read-aloud
  indicator, and the last export report behind a details popup. Warnings
  survive there after the toast fades — the bar exists precisely because
  toast-only loss reports proved too easy to miss.
- **Notification tiers:** errors toast for 7s, success/info 3.5s, all
  manually dismissible, bottom-right stack; anything worth keeping goes to
  the HealthBar or a panel instead. Native `ask()` dialogs are reserved for
  destructive confirmation with explicit choice labels.
- **Progressive disclosure:** heavy panels (graph, review) lazy-load and dock
  right; per-item actions live in a gutter popover menu; the layout picker is
  a popover of labeled wireframe swatches with an "Auto" state — visual
  choices are shown, not named in a raw `<select>`.
- **Quiet success:** saving flips the dot to emerald; no toast. AI edits show
  an inline word-level diff with revert — evidence, not applause.
- **Error states:** an ErrorBoundary wraps the editing surface, keyed on
  tab+mode so navigating resets it; render failures inside embedded content
  (diagrams) show a readable error box in place, never a blank crash.

## Grouping rule [B]

Related controls read as one visual cluster (a bordered group), one cluster
per concern per surface — e.g. "slide design" groups the layout picker with
the single slide-scoped AI action. Corollary: **one AI action per surface**;
if two AI features feel interchangeable on the same surface, merge them or
move one to a different scope (see 05_feature_taste_guide).
