#!/usr/bin/env bash
# PostToolUse hook (matcher: Edit|Write|MultiEdit) — compile-checks the file
# that was just edited and feeds errors straight back to the model.
# Weaker models drift far from a broken state before noticing; this shrinks
# the feedback loop to a single edit.
#
#   .rs        → `cargo check --quiet` in the nearest Cargo.toml directory
#   .ts/.tsx   → `tsc --noEmit` with the nearest tsconfig + local tsc
#
# Non-blocking feedback (PostToolUse exit 2 = message, not rollback).
# This is the most expensive hook in the kit: disable it with
# CHECK_ON_EDIT=off, or remove it from settings.json if your crate's
# check time makes per-edit feedback net-negative. Fails open without
# python3 or the relevant toolchain.

[ "${CHECK_ON_EDIT:-on}" = "off" ] && exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HOOK_INPUT=$(cat)
export HOOK_INPUT

python3 <<'PYEOF'
import json, os, subprocess, sys

try:
    data = json.loads(os.environ.get("HOOK_INPUT", "") or "{}")
except Exception:
    sys.exit(0)

path = (data.get("tool_input") or {}).get("file_path", "") or ""
if not path or not os.path.isfile(path):
    sys.exit(0)


def walk_up(start, relpath, limit=8):
    d = os.path.abspath(start)
    for _ in range(limit):
        candidate = os.path.join(d, relpath)
        if os.path.exists(candidate):
            return candidate
        parent = os.path.dirname(d)
        if parent == d:
            break
        d = parent
    return None


def feedback(label, output):
    lines = output.strip().splitlines()[-40:]
    print(f"CHECK-ON-EDIT ({label}) found errors after editing {path}:",
          file=sys.stderr)
    print("\n".join(lines), file=sys.stderr)
    print("Fix these before moving on; do not silence them with casts or "
          "ignores (rules/escalation.md §2).", file=sys.stderr)
    sys.exit(2)


ext = os.path.splitext(path)[1]
here = os.path.dirname(path)

if ext == ".rs":
    cargo_toml = walk_up(here, "Cargo.toml")
    if cargo_toml and subprocess.run(["which", "cargo"],
                                     capture_output=True).returncode == 0:
        r = subprocess.run(["cargo", "check", "--quiet"],
                           cwd=os.path.dirname(cargo_toml),
                           capture_output=True, text=True, timeout=150)
        if r.returncode != 0:
            feedback("cargo check", r.stderr or r.stdout)
elif ext in (".ts", ".tsx"):
    tsconfig = walk_up(here, "tsconfig.json")
    tsc = walk_up(here, os.path.join("node_modules", ".bin", "tsc"))
    if tsconfig and tsc and os.access(tsc, os.X_OK):
        r = subprocess.run([tsc, "--noEmit", "-p", os.path.dirname(tsconfig)],
                           capture_output=True, text=True, timeout=150)
        if r.returncode != 0:
            feedback("tsc --noEmit", r.stdout or r.stderr)

sys.exit(0)
PYEOF
