---
name: design-exploration
description: Explore direction and variations BEFORE building any new or visually reshaped UI surface. Use when a task adds a screen, panel, toolbar, or dialog, redesigns an existing one, or when the request names a look ("make it feel like X", "more modern"). Not for tweaks to an existing, already-directed surface.
---

# Design Exploration

Breadth before polish. Polishing the first idea is how default-shaped,
AI-slop UI happens; this skill forces 3–5 genuinely different structures to
exist before one is chosen. Taste layer: docs/ai/11_design_craft.md;
personality: 03; hard floors: rules/ui.md.

## Procedure

1. **Acquire design context first — never design in a vacuum.**
   Read docs/ai/03 (personality), 04 (tokens), 11 (craft), and the two most
   related existing surfaces in the codebase. If the project has no tokens
   or constitution yet, STOP and resolve that with the user first — starting
   a design without context reliably produces bad design.

2. **Interview before diverging.** Ask focused questions (one round):
   - Starting point: is there a reference — an existing surface, a
     screenshot, a product they like? What specifically do they like about
     it (density, navigation model, tone — not "the look")?
   - Axis of variation: should the options differ in *structure*,
     *interaction model*, *visual treatment*, or *copy*? Never assume.
   - Divergence appetite: safe evolutions of the current system, novel
     approaches, or a mix?
   - Constraints: what must not change (shortcuts, muscle memory, adjacent
     surfaces)?
   If the user is unavailable (autonomous run), write these answers as
   explicit ASSUMPTION lines in the output and choose conservatively.

3. **Commit to a direction on paper.** Three lines, written into the task
   notes/PR: Purpose (who, how often), Tone (named direction — for this
   product usually the constitution's), Differentiation (the one memorable
   thing). Every later choice ties back to these.

4. **Produce 3–5 wireframe-fidelity variants.** Low-fi on purpose:
   structure boxes, real hierarchy, placeholder content clearly marked —
   no colors beyond grayscale + one accent, no polish. Each variant gets:
   - a name and one sentence stating its *thesis* ("inspector docks right,
     list stays put" vs "modal takes over, zero chrome"),
   - a sketch: ASCII/markdown layout diagram, or a throwaway static JSX/HTML
     mock if interaction must be felt to be judged.
   Genuinely different means different structure or interaction model — the
   same layout with three accent colors is one variant, not three.

5. **Choose with criteria, not vibes.** Score variants against: the 2-click
   rule, state-visibility, how each handles the empty/overflow extremes,
   and the direction from step 3. Present the comparison; the user picks —
   or, autonomously, pick the highest-scoring and record the runner-up and
   why.

6. **Implement the winner inside the system.** Tokens only, gap-based
   spacing, states designed in the same change (empty/loading/error —
   rules/ui.md §4), palette entries for new commands.

7. **Close the loop.** Run the `ui-polish` skill on the built surface, then
   dispatch the `design-critic` subagent for an independent pass. Answer
   every finding: fixed or rebutted.

## Output

A short exploration record (in the PR description or task notes): context
read, interview answers or ASSUMPTIONs, the three direction lines, variant
theses with sketches, the scoring table, and the decision. This record is
what makes the next redesign cheaper. A fill-in form lives at
`.claude/forms/exploration-record.md` — use it; implementation starts only
after every field is filled.

## Anti-patterns this skill exists to prevent

- Implementing the first layout that comes to mind, then defending it.
- "Variations" that vary only the accent color.
- Designing a surface in isolation and discovering it clashes with the
  panel next to it.
- Asking zero questions and shipping an unstated assumption about what the
  user wanted to vary.
