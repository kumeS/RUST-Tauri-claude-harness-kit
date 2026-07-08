#!/usr/bin/env bash
# UserPromptSubmit hook — keyword-classifies the user's prompt and injects
# the matching routing hint from CLAUDE.md's task-routing table as context.
# Stronger models read the table themselves; weaker models misclassify the
# task and skip the required skill — this makes the routing mechanical.
#
# Hints, not gates: stdout is appended as context (exit 0); nothing is
# blocked, so a false positive costs one stray line. At most 3 hints.
# Fails open (silent) without python3.

command -v python3 >/dev/null 2>&1 || exit 0

HOOK_INPUT=$(cat)
export HOOK_INPUT

python3 <<'PYEOF'
import json, os, re, sys

try:
    data = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except Exception:
    sys.exit(0)

prompt = data.get("prompt", "") or ""
if not prompt.strip():
    sys.exit(0)

RULES = [
    (r"(新機能|機能.{0,4}(追加|作|欲しい)|強化|改善|(?<![-\w])(add|implement|build|create)\b.{0,60}\b(feature|command|panel|export|support)|feature request|弱い|weak)",
     "feature-shaped request → run the feature-spec skill BEFORE implementing "
     "(CLAUDE.md routing: never implement from unconverted prose)."),
    (r"(capabilit|permission|\bcsp\b|tauri\.conf|権限|セキュリティ設定)",
     "permission surface involved → run the tauri-permission-review skill and "
     "read .claude/rules/tauri-permissions.md before editing."),
    (r"(画面|パネル|ダイアログ|ツールバー|デザイン|見た目|\bui\b|component|screen|panel|dialog|toolbar|redesign|レイアウト)",
     "UI surface involved → rules/ui.md + rules/react.md apply; a NEW or "
     "reshaped surface goes through the design-exploration skill first, "
     "ui-polish last."),
    (r"(\bipc\b|invoke|#\[tauri::command\]|コマンド追加|backend command|バックエンド)",
     "backend capability involved → follow the ipc-command-design skill end "
     "to end; rules/rust.md applies."),
    (r"(\.rs\b|rust|cargo)",
     "Rust change → load .claude/rules/rust.md before editing."),
    (r"(\.tsx?\b|react|zustand|store|フロント)",
     "frontend change → load .claude/rules/react.md before editing."),
    (r"(テスト|test|vitest|contract)",
     "test work → .claude/rules/testing.md; name the code change that would "
     "make each new test fail."),
    (r"(バグ|直して|落ち|クラッシュ|panic|エラーになる|\bbug\b|\bfix\b|broken|crash|fails?)",
     "bug-shaped request → reproduce first, fix second; after two failed "
     "fix attempts, STOP and follow rules/escalation.md."),
]

hints = []
low = prompt.lower()
for pattern, hint in RULES:
    if re.search(pattern, low, re.I):
        hints.append(hint)
    if len(hints) == 3:
        break

if hints:
    print("[prompt-router] Routing hints (mechanical keyword match — "
          "ignore any that misread the task):")
    for h in hints:
        print(f"- {h}")

sys.exit(0)
PYEOF
