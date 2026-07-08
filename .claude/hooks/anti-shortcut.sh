#!/usr/bin/env bash
# PostToolUse hook (matcher: Edit|Write|MultiEdit) — flags the degenerate
# "make it green" moves that weaker models reach for under pressure:
# ignore-comments, any-casts, skipped/focused tests, deleted tests,
# todo!()/unimplemented!() landings. Flags are review prompts, not
# verdicts: each one must be fixed or justified in one line
# (rules/escalation.md §5). Non-blocking feedback; fails open.
#
# Scope: code files only (.rs/.ts/.tsx/.js/.jsx); .claude/ and docs are
# exempt (they legitimately *name* these patterns).

command -v python3 >/dev/null 2>&1 || exit 0

HOOK_INPUT=$(cat)
export HOOK_INPUT

python3 <<'PYEOF'
import json, os, re, subprocess, sys

try:
    data = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except Exception:
    sys.exit(0)

path = (data.get("tool_input") or {}).get("file_path", "") or ""
if not path or not os.path.isfile(path):
    sys.exit(0)

norm = path.replace(os.sep, "/")
if "/.claude/" in norm or norm.endswith(".md"):
    sys.exit(0)
ext = os.path.splitext(path)[1]
if ext not in (".rs", ".ts", ".tsx", ".js", ".jsx"):
    sys.exit(0)

workdir = os.path.dirname(path) or "."


def run(argv):
    try:
        return subprocess.run(argv, cwd=workdir, capture_output=True,
                              text=True, timeout=20)
    except Exception:
        return None


# Added/removed lines: git diff for tracked files, whole content for
# untracked or out-of-repo files.
added, removed = [], []
tracked = run(["git", "ls-files", "--error-unmatch", path])
if tracked and tracked.returncode == 0:
    diff = run(["git", "diff", "HEAD", "--", path])
    if diff and diff.returncode == 0:
        for line in diff.stdout.splitlines():
            if line.startswith("+") and not line.startswith("+++"):
                added.append(line[1:])
            elif line.startswith("-") and not line.startswith("---"):
                removed.append(line[1:])
else:
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            added = f.read().splitlines()
    except Exception:
        sys.exit(0)

ADDED_PATTERNS = [
    (r"@ts-ignore|@ts-nocheck", "TypeScript error suppressed"),
    (r"\bas any\b|:\s*any\b", "`any` cast/type added (rules/react.md §10)"),
    (r"\.only\(", "test suite narrowed to .only — the rest stops running"),
    (r"\.skip\(|\bxit\(|\bxdescribe\(", "test skipped"),
    (r"#\[ignore", "Rust test ignored"),
    (r"todo!\(|unimplemented!\(", "unimplemented landing state"),
]
if ext == ".rs" and "/tests/" not in norm:
    ADDED_PATTERNS.append(
        (r"\.unwrap\(\)|\.expect\(",
         "unwrap/expect added — verify it is inside #[cfg(test)] "
         "(rules/rust.md §3)"))

REMOVED_PATTERNS = [
    (r"#\[test\]", "a Rust test was removed"),
    (r"\b(it|test|describe)\(", "a JS/TS test block was removed"),
]

flags = []
for pattern, msg in ADDED_PATTERNS:
    hits = [l.strip()[:90] for l in added if re.search(pattern, l)]
    if hits:
        flags.append(f"- {msg}: `{hits[0]}`" +
                     (f" (+{len(hits)-1} more)" if len(hits) > 1 else ""))
for pattern, msg in REMOVED_PATTERNS:
    hits = [l.strip()[:90] for l in removed if re.search(pattern, l)]
    if hits:
        flags.append(f"- {msg}: `{hits[0]}`" +
                     (f" (+{len(hits)-1} more)" if len(hits) > 1 else ""))

if flags:
    print(f"ANTI-SHORTCUT TRIPWIRE ({path}): this edit contains moves that "
          "commonly fake progress. Each flag needs a fix or a one-line "
          "justification before 'done' (rules/escalation.md §2, §5):",
          file=sys.stderr)
    print("\n".join(flags[:8]), file=sys.stderr)
    sys.exit(2)

sys.exit(0)
PYEOF
