# 11 — Design Craft

How to make a surface *good*, not merely compliant. 03 defines the product's
personality, 04 the token mechanics, rules/ui.md the hard floors — this file
is the taste layer above them: aesthetic direction, typography, spacing,
content discipline, and the named anti-patterns that make UI read as
AI-generated.

Distilled from Anthropic's Claude Design guidance (preserved at
`others/claude-design.md` in the kit repo) and adapted from prototype-land to
shipping desktop apps. Markers as usual: [A] universal · [B] adapt ·
[REC] recommendation.

## 1. Direction before pixels [A]

Before building or reshaping a surface, answer three questions and write the
answers down (a comment in the PR or the feature-spec block is enough):

- **Purpose** — what problem does this surface solve, for whom, how often?
  A daily-driver panel and a once-a-year settings page earn different
  density and different discoverability budgets.
- **Tone** — name the direction and commit. For this kit's default
  personality that direction is 03's "quiet, dense but not cramped,
  macOS-native restraint" — but naming it per surface still matters: it is
  the tiebreaker for every later choice.
- **Differentiation** — what is the one thing a user will remember? One
  deliberate signature (the persistent health bar, the inline word-diff)
  beats ten small flourishes.

**Intentionality, not intensity.** Bold maximalism and refined minimalism
both work; what fails is the unchosen middle — defaults assembled without a
direction. If you cannot say why a choice fits the direction, it is not a
choice yet. [A]

**Vocalize the system up front.** Before implementing, state the system:
which layouts exist, where each background tone is used, what the type scale
is, where motion is allowed. Then implement the system, not slide-by-slide
improvisation. Variety comes from the system's deliberate rhythm, never from
drift. [A]

## 2. Content discipline [A]

- **No filler.** Never pad a surface with placeholder copy, decorative
  stats, or sections that exist to fill space. An empty-feeling region is a
  layout problem — solve it with composition, not invented content.
- **No data slop.** Numbers, icons, and badges that no decision consumes are
  noise. Every datum on screen must answer someone's actual question.
- **Ask before adding material.** If extra sections or copy seem like they
  would help, that is a question for the developer/user — they know the
  audience. Propose; don't unilaterally pad.
- Less is more: one thousand no's for every yes.

## 3. Typography [B]

- **Two faces, strict roles** (rules/ui.md §10): app chrome uses the system
  stack at fixed sizes; user content uses the content face at the
  user-adjustable size. Never mix roles.
- The content face is a *chosen*, characterful face — not a default. Avoid
  the overused set (Inter, Roboto, Arial, and whatever this year's
  equivalent is) for content; when pairing, pair one distinctive display
  face with one refined body face, and stop at two.
- **Minimum sizes** [REC]: chrome text ≥ 11px, body/content ≥ 13px on
  screen; ≥ 12pt in print/PDF export paths; slide-style exports ≥ 24px at
  1920×1080. Pointer hit targets ≥ 24×24px; touch (if ever) ≥ 44×44px.
- Body line-height 1.55–1.7 for reading surfaces; headings get
  `text-wrap: balance`, paragraphs `text-wrap: pretty` (kills one-word
  orphan lines). Print/PDF paths set `orphans: 3; widows: 3` and keep
  headings with their first paragraph (`break-after: avoid`).

## 4. Color & depth [B]

- Everything through semantic tokens (04). Craft-level rule: **dominant
  base + sharp accent** outperforms timid, evenly-distributed palettes.
  One accent doing real work (focus, primary action, live state) reads as
  designed; four accents read as indecision.
- Depth in a quiet app comes from hairline borders, one restrained elevation
  system (2–3 shadow levels, defined once as tokens), and background *tone
  steps* — not from decorative gradients. Atmosphere is allowed in empty
  states and onboarding; chrome stays flat and calm.
- Check every token pair for contrast at both ends of the theme matrix the
  project supports (and with CJK glyphs, which render optically heavier).

## 5. Space & layout [A]

- **Flex/grid with `gap` — never margin-stacked siblings** for rows and
  groups of controls (buttons, chips, toolbar items, cards). Gap spacing is
  explicit, survives reordering and deletion, and keeps rhythm consistent.
  Inline flow is for prose with the occasional inline element, not for UI.
- Spacing values come from the token scale (04), applied so that *related
  things sit closer than unrelated things* — grouping is the primary job of
  space, borders are the fallback.
- Alignment: pick the grid, then never violate it casually. A single
  misaligned control reads louder than a missing feature.
- Generous negative space OR controlled density — both are valid reads of
  "dense but not cramped"; per surface, pick one deliberately.
- `text-wrap: pretty`, CSS grid, container queries: modern CSS is your
  friend; reach for it before JavaScript layout.

## 6. Motion [REC]

- Budget: **one well-orchestrated moment per surface** (a panel's staggered
  first reveal, a save-state dot's transition) beats scattered
  micro-interactions on every hover.
- CSS-only first; JS animation only when state genuinely requires it.
- Every animation respects `prefers-reduced-motion`. Motion communicates
  state change; it never celebrates (03: success is quiet).

## 7. Iconography [A]

- One icon set, one stroke weight, consistently sized — chosen once,
  documented in 04.
- **Never hand-draw SVG imagery** to fill a gap, and never use emoji as
  icons or unicode glyphs as controls. If the asset doesn't exist, use a
  labeled placeholder and flag it — an honest gap beats a fake asset.
- Icon-only controls remain forbidden regardless of icon quality
  (rules/ui.md §1).

## 8. Named anti-patterns — the AI-slop list [A]

Reject on sight, in your own output and in review:

- Gradient wallpaper backgrounds (especially blue-purple) behind ordinary
  chrome.
- Cards with rounded corners + colored left-border accent as the default
  "callout" pattern.
- Emoji as icons, emoji in headings, emoji as bullet decoration.
- Three-stat hero rows ("42 files · 99% fast · ∞ joy") and other decorative
  metrics no one asked for.
- The overused-font default (Inter/Roboto/Arial as a *content* face).
- Hand-rolled SVG illustrations standing in for real assets.
- Ten timid micro-animations instead of one deliberate moment.
- Converging on the same look across unrelated surfaces because it's the
  path of least resistance — variety within the system is a feature.

## 9. Exploration before commitment [B]

For any new surface (not for tweaks): explore **3–5 genuinely different
approaches at wireframe fidelity** before polishing one. Different means
different structure or interaction model — not the same layout with three
accent colors. Breadth first, polish second; polishing the first idea is how
default-shaped UI happens. Procedure: `.claude/skills/design-exploration/`.

When the user asks for variations, ask *what should vary* — structure,
visuals, copy, interaction — and how divergent they want it. Never assume
the axis of variation.

## 10. Respect existing systems [A]

- Inside this product: the tokens and constitution win over personal taste.
  Craft operates within the system; changing the system is a product
  decision, made explicitly in 04.
- Outside references: never recreate another company's distinctive UI,
  branded patterns, or proprietary layouts. Understand what the user liked
  about the reference (density? navigation model? tone?) and build an
  original design that achieves it.
