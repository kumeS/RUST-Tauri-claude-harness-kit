#!/usr/bin/env bash
# Stop hook — the done gate. When the agent ends its turn with modified
# code files in the working tree, run the fast verification gates and, if
# any is red, block the stop and feed the failures back verbatim. This
# converts CLAUDE.md self-check §1 ("did the suites run?") from a question
# the model answers into a fact the harness checks — load-bearing for
# weaker models that claim "done" optimistically.
#
# Guards against noise and loops:
#   - stop_hook_active in the input JSON → exit 0 (never re-block the
#     continuation the gate itself caused).
#   - No modified .rs/.ts/.tsx/.js/.jsx files → exit 0 (conversational
#     turns stay free).
#   - Each unique working-tree state is gated ONCE (state hash cached in
#     .claude/cache/): a red result is reported one time, not on every
#     subsequent stop while the user discusses it.
#   - Escape hatch for deliberate WIP stops: DONE_GATE=off env var.
# Fails open without python3/git. Timeout is set in settings.json.

[ "${DONE_GATE:-on}" = "off" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0
command -v git >/dev/null 2>&1 || exit 0

HOOK_INPUT=$(cat)
export HOOK_INPUT

ACTIVE=$(python3 -c '
import json, os
try:
    d = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except Exception:
    d = {}
print("1" if d.get("stop_hook_active") else "0")
')
[ "$ACTIVE" = "1" ] && exit 0

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

CHANGED=$(git status --porcelain 2>/dev/null | grep -E '\.(rs|tsx?|jsx?)$' || true)
[ -z "$CHANGED" ] && exit 0

mkdir -p .claude/cache
STATE_HASH=$( { git diff; git diff --cached; git status --porcelain; } 2>/dev/null \
  | python3 -c 'import hashlib,sys; print(hashlib.sha256(sys.stdin.buffer.read()).hexdigest())')
CACHE=.claude/cache/done-gate.hash
if [ -f "$CACHE" ] && [ "$(cat "$CACHE" 2>/dev/null)" = "$STATE_HASH" ]; then
  exit 0
fi
printf '%s\n' "$STATE_HASH" > "$CACHE"

REPORT=$(mktemp)
FAIL=0

run_gate() { # run_gate <label> <dir> <cmd...>
  label=$1; dir=$2; shift 2
  tmp=$(mktemp)
  ( cd "$dir" && "$@" ) >"$tmp" 2>&1
  if [ $? -ne 0 ]; then
    FAIL=1
    { printf '### %s FAILED (last 40 lines):\n' "$label"; tail -40 "$tmp"; echo; } >>"$REPORT"
  fi
  rm -f "$tmp"
}

# Locate the app (root or one level down; the kit repo itself has neither).
CRATE=""
for c in src-tauri */src-tauri; do
  [ -f "$c/Cargo.toml" ] && CRATE=$c && break
done
FE=""
for d in . */; do
  case "$d" in node_modules/|target/|others/) continue;; esac
  [ -f "${d}package.json" ] && [ -d "${d}node_modules" ] && FE=${d%/} && break
done

if printf '%s' "$CHANGED" | grep -qE '\.rs$' && [ -n "$CRATE" ]; then
  run_gate "cargo test --lib ($CRATE)" "$CRATE" cargo test --lib --quiet
fi
if printf '%s' "$CHANGED" | grep -qE '\.tsx?$' && [ -n "$FE" ] && [ -f "$FE/tsconfig.json" ] \
   && [ -x "$FE/node_modules/.bin/tsc" ]; then
  run_gate "tsc --noEmit ($FE)" "$FE" ./node_modules/.bin/tsc --noEmit
fi
if printf '%s' "$CHANGED" | grep -qE '\.(tsx?|jsx?)$' && [ -n "$FE" ]; then
  if [ -x "$FE/node_modules/.bin/vitest" ]; then
    run_gate "vitest ($FE)" "$FE" env CI=1 ./node_modules/.bin/vitest run --silent
  elif [ -x "$FE/node_modules/.bin/jest" ]; then
    run_gate "jest ($FE)" "$FE" env CI=1 ./node_modules/.bin/jest --silent
  fi
fi

if [ "$FAIL" = "1" ]; then
  {
    echo "DONE GATE (.claude/hooks/done-gate.sh): suites are RED — this is not done (CLAUDE.md self-check §1)."
    echo "Fix the failures, or report them verbatim to the user with what you tried (rules/escalation.md)."
    echo "Never weaken a test to pass this gate (rules/escalation.md §2)."
    echo
    head -120 "$REPORT"
  } >&2
  rm -f "$REPORT"
  exit 2
fi

rm -f "$REPORT"
exit 0
