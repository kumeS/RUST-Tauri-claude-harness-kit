# 05 — Feature Taste Guide

Rules for *which* features to build and how they should feel. Each rule was
learned from a real decision in the source project (provenance noted).

## 1. Non-destructive by default; destruction is opt-in and separate [A]

When a feature transforms user content, prefer writing the result to a
side-channel (override field, new artifact) over rewriting the source. Offer
an explicit way back.
**Provenance:** "Summarize→slide" writes a detachable `slideBody` override
with a Re-link button; the destructive cousin ("Bulletize", which rewrites
the shared prose) confused users when it sat on the same toolbar. The fix
moved the destructive one to a different scope. Users read two side-by-side
verbs on one surface as interchangeable — if one destroys and one doesn't,
they must not sit together.

## 2. One AI verb per surface [A]

Each surface (toolbar, panel, item menu) carries at most one AI action, named
by its *outcome*, scoped to that surface. Many verbs belong in the per-item
menu or the palette, not on the chrome.
**Provenance:** the slide toolbar once had two near-duplicate AI verbs; the
user literally could not tell them apart. After the redesign it has exactly
one, and satisfaction followed.

## 3. Auto + override + a way back to Auto [A]

Automatic behavior (layout picking, language detection) always allows a
manual override — and the override always offers an explicit "Auto" state to
return to. An override with no way back reads as "the automation is broken".
**Provenance:** slide layouts auto-pick from content; the picker's first
swatch is "Auto"; the original design had no way back and was called "weak"
by the user in exactly those terms.

## 4. Don't add a setting for what code can decide [A]

Prefer computing a sensible choice from context over asking. Settings are for
durable user identity (language, tone, model, font), not for per-operation
knobs.
**Provenance:** layout auto-pick derives from slide composition; no "default
layout" setting exists. Meanwhile *global* voice (language/tone) IS a
setting, because it's identity, not operation.

## 5. Lossy operations report specifically, on a persistent surface [A]

"3 items were left out — only one image per slide is supported" beats
"export completed with warnings". Counts + reasons + where to look. Reports
outlive the toast (health bar / report panel).
**Provenance:** the PptxReport/lastExportReport arc (see 03 §state).

## 6. Honest capability labels beat aspirational ones [A]

If a surface can't do something yet, say so in the surface itself — a
"planned" note, an explicit warning ("export from the app to include
diagrams"), a manifest field (`aiActionsRunVia: "gui"`). Aspirational claims
rot into trust debt.
**Provenance:** the CLI manifest once over-claimed; the repaired version
self-describes honestly and tests the claim.

## 7. Feature names describe outcomes, not mechanisms [A]

"Summarize → slide", "Revise with context", "Image right" — not
"slideBody generator", "harmonize", "title-image". Mechanism names leak
implementation and read as jargon.
**Provenance:** raw enum names in the layout `<select>` ("section",
"title-content") were "meaningless, purpose unclear" per user feedback;
labeled swatches fixed it.

## 8. Progressive disclosure over configuration sprawl [A]

New capability? Default it on with good behavior, put its controls in the
nearest scoped surface (item menu → panel → palette), and keep Settings for
identity-level choices only. Heavy panels lazy-load.

## 9. Every generated artifact keeps its provenance [B]

AI-produced content records what produced it (prompt on image chunks, hash of
source on summaries, author+kind on review comments) so regeneration, staleness
detection, and attribution stay possible.
**Provenance:** image chunks store their prompt (regenerate works), summaries
store `summaryHash`, review comments store `author: "ai" | "user"` + `kind`.

## 10. When in doubt, ship the report structure first [B]

Building a pipeline? Design its warning/report type before its happy path.
The report structure forces you to enumerate the loss modes up front — and
the UI surface for it (health bar slot) already exists.
