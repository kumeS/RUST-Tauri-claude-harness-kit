---
name: ui-polish
description: Audit and polish one UI surface against the UI constitution and design tokens. Use after building or substantially changing a screen, panel, toolbar, or dialog — or when asked to "clean up", "refine", or "make it feel native".
---

# UI Polish

A single-surface audit pass against docs/ai/03 (constitution), 04 (tokens),
11 (design craft), and .claude/rules/ui.md. Produces a defect list first,
then fixes.

## Procedure

1. **Scope one surface** (one component tree: a panel, a toolbar, a modal).
   Polishing "the app" is not a task; polishing the review panel is.

2. **State audit** — enumerate and eyeball all four:
   - Empty (no data yet) — designed, or accidental blank?
   - Loading/busy — indicated within the surface, correct scope disabled?
   - Error — readable, recoverable, boundary-reset on navigation?
   - Overflow — long content, many items, narrow window: scrolls the right
     subregion (never the whole app), truncates with disclosure?

3. **Control audit** — for every interactive element:
   - Label or tooltip + accessible name (rule 1)?
   - Reachable ≤2 clicks; palette entry if it's a command (rules 2–3)?
   - Destructive? → separated + explicit verb label (rule 5)?
   - Disabled states scoped to the actual busy scope (07 §5)?

4. **Token audit** — grep the component for raw hex, `gray-*`, ad-hoc font
   classes, off-scale spacing/heights. Everything maps to semantic tokens
   (ink/accent tiers, content-vs-chrome typeface, standard control heights).

5. **Noise audit** — count notifications this surface can emit. Success
   toasts → state changes. Warnings that matter → persistent surface.
   Modals → can a popover/panel/inline state do it?

6. **Density & rhythm** — line heights, cluster grouping (related controls
   read as one bordered group; unrelated ones don't share a cluster),
   alignment to the surface's grid. Compare against a native macOS app at
   the same information density (Notes, Finder inspector).

7. **Craft audit (docs/ai/11)** —
   - Spacing built from flex/grid `gap`, not margin-stacked siblings?
   - Content discipline: any filler copy, decorative stats, or data slop
     no decision consumes? Remove or question it.
   - Anti-slop sweep against the named list (11 §8): gradient wallpaper,
     rounded left-border accent cards, emoji-as-icon, hand-rolled SVG
     imagery, overused-font content face, scattered micro-animations.
   - Typography floors: chrome ≥ 11px, content ≥ 13px, hit targets ≥ 24px;
     `text-wrap: balance` on headings, `pretty` on paragraphs where
     supported.
   - One deliberate motion moment at most; everything honors
     `prefers-reduced-motion`.

8. **Fix, then verify.** Apply fixes; verify with the running app
   (screenshot the four states from step 2 where feasible). For pure-CSS
   claims, inspect computed styles rather than trusting the diff. For an
   independent pass, dispatch the `design-critic` subagent and answer its
   findings.

## Output

A short table: `finding → rule/token violated → fix applied` (or "deferred:
reason"). Surfaces with zero findings are stated as audited-clean rather
than silently skipped.
