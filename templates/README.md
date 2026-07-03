# Templates

Move these into your project (this file itself stays behind):

| File | Destination | Then |
|------|-------------|------|
| `ci.yml` | `.github/workflows/ci.yml` | Set `APP_DIR`; pick ubuntu (keep apt step) or macos (delete it); soften clippy if retrofitting |
| `pull_request_template.md` | `.github/pull_request_template.md` | Delete gate lines that can never apply to your product |

Why these exist: the source project's highest-leverage gap was that its 125
tests only ran when someone remembered. CI is the mechanism that turns the
kit's root principle ("every promise gets a test") from advice into a gate,
and the PR template is the human-side mirror of the same checklist.
