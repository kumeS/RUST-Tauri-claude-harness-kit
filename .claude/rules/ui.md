# Rules: UI

Hard constraints for any UI change. Rationale lives in docs/ai/03 + 04.

1. **NEVER ship an icon-only button.** Every control has a visible label or a
   tooltip plus an accessible name.
2. **Primary actions ≤ 2 clicks.** If a flow exceeds two, add a palette entry
   or a surface-local control — do not accept "it's in a submenu".
3. **Every new command MUST register a command-palette entry** (label +
   search keywords + visibility condition).
4. **Every new surface ships its empty, loading, and error states** in the
   same change — not as a follow-up.
5. **Destructive actions**: physically separated from safe ones, explicit
   verb labels ("Discard & close", "Delete 3 slides"), native confirm dialog
   for irreversible loss. NEVER "OK/Cancel" for destruction.
6. **Success is quiet.** State change (dot, badge, inline diff) over toast;
   toast over dialog; success dialogs are forbidden.
7. **Warnings that matter outlive the toast.** Anything reporting data loss
   or degraded output goes to the persistent status surface (health bar /
   report panel) in addition to, or instead of, a toast.
8. **No new modal if a popover, docked panel, or inline state suffices.**
   Modals are for decisions that block everything else.
9. **Colors and fonts via semantic tokens only** (`ink`, `accent`, content
   vs chrome typeface). Raw hex/gray-scale classes in components fail review.
10. **Content vs chrome typography**: user content uses the content face and
    its user-adjustable size; app chrome uses the system stack and fixed
    sizes. Never mix.
11. **Visual choices are shown visually.** Options that differ visually
    (layouts, themes) get swatches/previews, not raw enum names in a select.
12. **Automation is overridable, and overrides can return to Auto.** Any
    auto-picked behavior exposed in UI must offer an explicit Auto state.
13. **One AI action per surface**, named by outcome. Additional AI verbs go
    to the per-item menu or palette.
14. **Heavy panels lazy-load**; error boundaries around major surfaces are
    keyed on view identity so navigation resets them.
