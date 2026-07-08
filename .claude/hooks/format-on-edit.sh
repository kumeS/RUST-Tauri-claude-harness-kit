#!/usr/bin/env bash
# PostToolUse hook (matcher: Edit|Write|MultiEdit) — auto-formats the file
# that was just edited, so formatting never becomes review noise.
#
# Deliberately silent and fail-open: if the formatter isn't installed or the
# file type is unknown, do nothing. Never blocks, never reports — formatting
# is hygiene, not feedback. Tool resolution walks UP from the edited file,
# so nested layouts (app in a subdirectory, src-tauri crates) work.

set -u

if ! command -v python3 >/dev/null 2>&1; then
  exit 0
fi

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


def walk_up(start, relpath, limit=8):
    """Return the first <dir>/<relpath> found from start upward, else None."""
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


def run_quiet(argv):
    try:
        subprocess.run(argv, check=False, timeout=30,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception:
        pass


ext = os.path.splitext(path)[1]
here = os.path.dirname(path)

if ext == ".rs":
    if subprocess.run(["which", "rustfmt"], capture_output=True).returncode == 0:
        edition = "2021"
        cargo = walk_up(here, "Cargo.toml")
        if cargo:
            try:
                with open(cargo, encoding="utf-8") as f:
                    m = re.search(r'^\s*edition\s*=\s*"(\d{4})"', f.read(), re.M)
                if m:
                    edition = m.group(1)
            except Exception:
                pass
        run_quiet(["rustfmt", "--edition", edition, path])
elif ext in (".ts", ".tsx", ".js", ".jsx", ".css", ".json"):
    # Project-local prettier only — never a global surprise. Walk up so the
    # nested-app layout (APP_DIR != repo root) still resolves.
    prettier = walk_up(here, os.path.join("node_modules", ".bin", "prettier"))
    if prettier and os.access(prettier, os.X_OK):
        run_quiet([prettier, "--write", path])

sys.exit(0)
PYEOF
