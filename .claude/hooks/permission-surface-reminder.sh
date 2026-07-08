#!/usr/bin/env bash
# PostToolUse hook (matcher: Edit|Write|MultiEdit) — after any edit that
# touches a Tauri permission surface, feed a reminder back to the model to
# run the tauri-permission-review skill. Non-blocking by design: the edit
# already happened; exit 2 here only injects the message into the model's
# context (PostToolUse exit 2 = feedback, not rollback).
#
# This is the mechanical guard behind rules/tauri-permissions.md §4
# ("any diff to permissions or CSP triggers the review skill").

if ! command -v python3 >/dev/null 2>&1; then
  exit 0
fi

# Capture the hook JSON before the heredoc-fed interpreter can swallow stdin.
HOOK_INPUT=$(cat)
export HOOK_INPUT

python3 <<'PYEOF'
import json, os, re, sys

try:
    data = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except Exception:
    sys.exit(0)

path = (data.get("tool_input") or {}).get("file_path", "") or ""

SURFACES = [
    r"capabilities/[^/]+\.(json|json5|toml)$",
    r"tauri\.conf\.(json|json5)$",
    r"Tauri\.toml$",
]

if any(re.search(p, path) for p in SURFACES):
    print(
        "REMINDER from .claude/hooks/permission-surface-reminder.sh: "
        f"'{path}' is a Tauri permission surface. Before this change is "
        "considered done, run the tauri-permission-review skill "
        "(.claude/skills/tauri-permission-review/SKILL.md) and justify every "
        "grant per .claude/rules/tauri-permissions.md. "
        "Consider dispatching the permission-auditor subagent for an "
        "independent pass.",
        file=sys.stderr,
    )
    sys.exit(2)

sys.exit(0)
PYEOF
