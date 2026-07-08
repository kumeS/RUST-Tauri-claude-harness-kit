# agent-memory/ — accumulated pitfalls & decisions

Team-shared, git-tracked memory for AI sessions. Weaker models repeat
mistakes; this directory converts each mistake into a defense the next
session inherits. (The same mechanism as docs/ai/09's tool-call memo,
generalized.)

## What belongs here

- **Pitfalls**: a failure that happened in THIS repo and will recur —
  with the trigger, the wrong move, and the right move. Falsifiable and
  dated.
- **Decisions**: choices that keep getting re-litigated ("we use X, not
  Y, because Z") that don't fit docs/ai/ or a rule file.

## What does NOT belong here

- Anything derivable from the code or git history.
- General best practices (rules/ own those).
- Session narration, task logs, or praise. If nobody will act differently
  because of the entry, delete it.

## Convention

One file per topic (`pitfalls.md`, `decisions.md`, or per-agent files like
`code-review.md`). Entry format:

```md
## {{date}} — {{one-line trigger}}
- Wrong move: {{what a session actually did}}
- Right move: {{what to do instead}}
- Evidence: {{file/PR/error, so future sessions can verify it still holds}}
```

Prune on read: an entry whose evidence no longer holds gets deleted, not
kept "just in case" — stale memory is worse than no memory.
