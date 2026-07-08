# 04 — Design Tokens

Token *policy* is [A] portable; the concrete values shown are [C] the source
app's palette — replace them, keep the structure. Tokens are the mechanics;
how to choose well within them is docs/ai/11_design_craft.md.

## Policy

1. **Semantic names, not raw scales.** Components reference `ink`, `ink-soft`,
   `ink-faint`, `accent` — never `gray-700` or hex literals. The palette can
   then change in one file.
2. **Two-typeface rule.** One face for *content* (the thing the user makes),
   one for *chrome* (the app around it). Content deserves a reading face;
   chrome uses the platform system stack so the app feels native.
3. **One measure for reading.** Long-form content gets a max reading width
   token (`max-w-prose`); panels and chrome are exempt.
4. **Declare the color-scheme.** Light-only? Say `color-scheme: light`
   explicitly and gate any future dark work on a real token pass — half-dark
   is worse than light-only. [D in source: dark mode undecided.]
5. **Density by component tokens, not ad-hoc padding.** Pick a small set of
   control heights and stick to them.
6. **Motion restraint.** Transitions for state changes the user caused;
   nothing autonomous. (Matches the "quiet" personality.)
7. **One icon set.** Choose a single icon set and stroke weight, record the
   choice here, and never mix sets on one surface. [D — decide with the
   token pass; craft rules for icon usage live in docs/ai/11 §7.]

## Worked example — the source app's token set [FACT, values are [C]]

```js
// tailwind.config.js (extend)
fontFamily: {
  serif: ["Georgia", "Charter", "Cambria", "Times New Roman", "serif"], // content
  sans:  ["-apple-system", "BlinkMacSystemFont", "Segoe UI",
          "Hiragino Kaku Gothic ProN", "Meiryo", "sans-serif"],         // chrome
},
colors: {
  ink:    { DEFAULT: "#1f2933", soft: "#3e4c59", faint: "#7b8794" },    // text tiers
  accent: { DEFAULT: "#2563eb", soft: "#3b82f6" },                      // one accent
},
maxWidth: { prose: "44rem" },                                            // measure
```

Supporting facts from the source:
- Body text: antialiased, `optimizeLegibility`, ink on white; `color-scheme:
  light` declared at `:root`.
- Content typography is user-adjustable within tokens: font family
  (serif/sans/mono stacks) and size (default 17px, line-height 1.85) exposed
  as *two* settings — not a free-form CSS box. Chrome typography is not
  user-adjustable.
- CJK-aware stacks: the sans stack includes Hiragino/Meiryo so JP text in
  chrome doesn't fall back badly; exports embed a Unicode TTF for the same
  reason. If your users write CJK, every font decision must be made twice
  (screen + export).
- Density tokens in practice: 28px status strip, 320px (`w-80`) side panels,
  sticky 1-row toolbar. Three heights cover nearly all chrome.

## Anti-patterns seen and rejected [REC]

- Raw enum strings in a `<select>` as a "picker" — replaced with labeled
  wireframe swatches. If users choose between *visual* options, show the
  options visually.
- Scrollbar chrome on dense internal lists — a `.no-scrollbar` utility
  exists, used sparingly where the container makes scrollability obvious.
- Multiple accents. One accent color; states are conveyed with the ink tiers
  plus semantic colors (amber = unsaved/stale, emerald = saved/ok, red =
  error) used *only* for state, never decoration.
