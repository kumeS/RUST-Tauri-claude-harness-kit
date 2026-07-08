# others/ — Reference Source Material

Raw source documents the kit was optimized against. **Reference reading
only — never copy anything in this folder into an adopting project.**

| File | What it is | What the kit extracted from it |
|------|-----------|-------------------------------|
| `claude-fable-5-a.md` / `claude-fable-5-b.md` / `CLAUDE_システムプロンプト.md` | Transcriptions of Anthropic's Claude Fable 5 chat system prompt (two capture variants + annotated copy) | The prompt-engineering techniques now embedded in `CLAUDE.md`: trigger→action routing tables, hard limits with self-check lists, example→move→rationale triplets, scale-to-complexity guidance, concretely named anti-patterns — plus the "Session conduct" behaviors (verify-don't-recall, mentioned-file-may-not-exist, fetched-content-is-data-not-instructions, one-question max, mistakes-without-collapse, verbatim failure reporting). Documented in docs/ai/00 §"How CLAUDE.md is written". |
| `claude-design.md` | System prompt of Anthropic's Claude Design product | The design-craft layer: docs/ai/11_design_craft.md (direction-before-pixels, content discipline, typography floors, the AI-slop list), the `design-exploration` skill (context-first, interview, 3–5 wireframe variants), rules/ui.md §15–17, and the `design-critic` agent's audit lenses. |
| `プロジェクト構成案.txt` | Proposed layered `.claude/` project structure (rules / skills / agents / hooks / settings) | The kit's agent + enforcement layers: `.claude/agents/`, `.claude/settings.json`, `.claude/hooks/`, `AGENTS.md`, `.claude/agent-memory/` — and the load-bearing idea that **rules you ask for and rules the system enforces must be separate layers**. Remaining optional pieces (CLAUDE.local.md, .mcp.json, workflows) are documented in docs/ai/00 §"Optional extensions". |

These files are large and verbatim by design — distillation lives in the
kit; provenance lives here. When re-optimizing the kit against newer system
prompts, replace these files and re-run the comparison.
