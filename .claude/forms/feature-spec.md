<!-- Fill-in form for the feature-spec skill. Copy this block into the task
     notes / PR description and fill every field. "I'll skip this row" is
     not an option — write "none" explicitly where empty is the true
     answer. Weaker models: fill the form top to bottom, one field at a
     time; do not start implementing until every row has content. -->

# Feature Spec — {{feature name}}

**Request (verbatim):** {{paste the user's words, unedited}}

## Outcomes — what the user can DO afterward (not what code will exist)

- O1: {{…}}
- O2: {{…}}

## Acceptance criteria — every row becomes a test

| # | Criterion (measurable, falsifiable) | Guard (test file::name, or "planned" + why) |
|---|-------------------------------------|---------------------------------------------|
| 1 | {{…}} | {{…}} |
| 2 | {{…}} | {{…}} |

## Non-goals (what this change deliberately does NOT do)

- {{…}}

## Assumptions (unconfirmed readings of the request — confirm or mark)

- ASSUMPTION: {{…}}

## Touched surfaces

- UI surfaces: {{names, or "none"}} → design-exploration needed? {{yes/no}}
- Commands/IPC: {{new or changed commands, or "none"}} → ipc-command-design
- Permissions/CSP: {{diff expected? or "none"}} → tauri-permission-review
- Dual implementations touched (preview/export, TS/Rust mirror): {{list, or "none"}}
