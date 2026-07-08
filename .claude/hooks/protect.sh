#!/usr/bin/env bash
# PreToolUse hook (matcher: Bash) — blocks commands whose damage no rule
# file can undo. This is the mechanical layer: CLAUDE.md asks, this enforces.
#
# Contract: reads the hook JSON on stdin, exits 2 with a reason on stderr to
# BLOCK the call (the reason is fed back to the model), exits 0 to allow.
#
# Scope honesty: this is a best-effort tripwire against common spellings,
# NOT a sandbox. It splits on command separators and anchors patterns to
# each command's start, so mentions inside string literals or later chained
# commands don't false-positive — but quote-embedded separators and exotic
# spellings can still slip either way. Fails open (allow) when python3 is
# missing; the settings.json deny list is the independent first line.
# Every pattern change gets block AND allow cases in test_hooks.sh.

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
    sys.exit(0)  # malformed input: not ours to judge

cmd = (data.get("tool_input") or {}).get("command", "") or ""


def block(reason):
    print(f"BLOCKED by .claude/hooks/protect.sh: {reason}", file=sys.stderr)
    sys.exit(2)


# Whole-command check first: pipes are treated as separators below, so
# pipe-to-shell must be detected before splitting.
if re.search(r"\b(curl|wget)\b[^|;&]*\|\s*(sudo\s+)?(sh|bash|zsh|dash|ksh|fish)\b", cmd):
    block("Piping a downloaded script into a shell is blocked (unauditable "
          "supply-chain risk). Download, read, then run it as separate steps.")

# rm targets that are never OK to force-delete recursively. Named
# subdirectories (rm -rf ./node_modules, rm -rf /tmp/build) stay allowed.
DANGEROUS_RM_TARGETS = {"/", "~", "~/", "$HOME", "$HOME/", "*"}

SEGMENT_RULES = [
    (r"^git\s+push\b(?!.*--force-with-lease).*(\s--force\b|\s-f\b)",
     "Force push is blocked (history rewrite on a shared remote). Use "
     "--force-with-lease on a feature branch, and only when asked."),
    (r"^git\s+reset\s+--hard\s+(origin|upstream)/",
     "Hard reset to a remote ref discards local work. Stash or branch "
     "first, and confirm with the user."),
    # Common .env readers/copiers. Template files (.env.example etc.) are
    # secretless and stay readable.
    (r"^(?:\.|cat|less|more|head|tail|bat|strings|source|grep|rg|cp|mv|xxd|od)\s+"
     r"(?:[^|;&]*\s)?(?:\S*/)?\.env(?!\.(?:example|sample|template|dist)\b)"
     r"(\.[A-Za-z0-9_-]+)?(?=\s|$)",
     "Touching .env files is blocked: secrets never enter the conversation. "
     "Per this project's invariants, secrets live in the OS keychain; the "
     "transcript sees booleans only. (.env.example and friends are fine.)"),
    (r"^chmod\s+(-[a-zA-Z]*R[a-zA-Z]*\s+)?777\b",
     "chmod 777 is blocked. Grant the narrowest permission that works."),
    # Redirect can sit anywhere in its segment, so this one is unanchored.
    (r">>?\s*(~|\$HOME|/Users/[^/\s]+|/home/[^/\s]+)/\.(zshrc|bashrc|zprofile|bash_profile|profile)\b",
     "Overwriting or appending to shell rc files is blocked. Propose the "
     "snippet to the user instead."),
]

for raw_seg in re.split(r"\|\||&&|;|\|", cmd):
    seg = raw_seg.strip()
    seg = re.sub(r"^(?:\w+=\S*\s+)+", "", seg)               # env assignments
    seg = re.sub(r"^(?:(?:sudo|command|nohup)\s+)+", "", seg)  # wrappers
    if not seg:
        continue

    # rm: parse arguments instead of pattern-matching, so split flags
    # (-r -f), long flags (--recursive --force), and quoted targets
    # ("$HOME") are all caught — and named subdirectories are not.
    if re.match(r"^rm\s", seg):
        tokens = seg.split()[1:]
        flags = [t for t in tokens if t.startswith("-")]
        targets = [t.strip("\"'") for t in tokens if not t.startswith("-")]
        recursive = any(
            t == "--recursive"
            or (re.match(r"^-[a-zA-Z]+$", t) and ("r" in t or "R" in t))
            for t in flags)
        force = any(
            t == "--force"
            or (re.match(r"^-[a-zA-Z]+$", t) and "f" in t)
            for t in flags)
        if recursive and force and any(t in DANGEROUS_RM_TARGETS for t in targets):
            block("Recursive force-delete of a root-level path. If a "
                  "directory truly must go, name it explicitly and ask the "
                  "user.")

    for pattern, reason in SEGMENT_RULES:
        if re.search(pattern, seg):
            block(reason)

sys.exit(0)
PYEOF
