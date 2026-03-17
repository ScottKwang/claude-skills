# Spec: Reduce External Dependencies

## Overview

Remove unnecessary external dependencies from the repo by replacing them with native Claude Code tools or deleting unused features. Goal: minimize setup friction and API key requirements.

## Completed

### Railway (done)
1. ~~Delete `skills/railway.md`~~
2. ~~Remove railway entry from `mcp-configs/mcp.json`~~
3. ~~Update `README.md` — remove railway references~~

### Vercel (done)
1. ~~Delete `skills/vercel-env.md`~~
2. ~~Update `README.md` — remove vercel-env rows from Skills table~~
3. ~~Update `dependencies_summary.md` — remove vercel references~~

### Hyperbrowser → Playwright (done)
1. ~~Replace hyperbrowser MCP server with `@anthropic-ai/mcp-server-playwright` in `mcp-configs/mcp.json`~~
2. ~~Update `templates/settings.json` — permission `mcp__hyperbrowser__*` → `mcp__playwright__*`~~
3. ~~Update `skills/api-docs.md` — fallback instructions now reference Playwright~~
4. ~~Update `README.md` — MCP servers list, remove API key section~~
5. ~~Update `scripts/setup-claude.sh` — comments and output messages~~
6. ~~Update `dependencies_summary.md` — remove API keys section, update MCP table~~

### qlty → Project-Native Linters (done)
1. ~~`hooks/src/typescript-preflight.ts` — renamed `qlty_errors` to `lint_errors`, updated description~~
2. ~~`hooks/dist/typescript-preflight.mjs` — rebuilt from source~~
3. ~~`agents/review-agent.md` — replaced qlty section with auto-detect project linter logic~~
4. ~~`dependencies_summary.md` — removed qlty row~~

### RepoPrompt → Native Claude Code Tools (done)
1. ~~`agents/rp-explorer.md` — full rewrite using Glob/Grep/Read~~
2. ~~`agents/onboard.md` — replaced RepoPrompt block with native tools~~
3. ~~`agents/research-agent.md` — replaced rp-cli commands, updated description~~
4. ~~`agents/plan-agent.md` — replaced rp-cli commands, updated references~~
5. ~~`agents/debug-agent.md` — replaced both rp-cli blocks with Grep equivalents~~
6. ~~`dependencies_summary.md` — removed rp-cli row~~

## Out of Scope

- Keep Vercel entry in `skills/api-docs.md` provider detection table (just doc fetching, not a dependency)
- No replacement deployment skills needed — managed elsewhere

## Decision Log

**Q:** Delete skill files or archive them?
**A:** Delete entirely. Git history preserves them if ever needed.

**Q:** Remove railway MCP server config too?
**A:** Yes — it only existed to support the skill.

**Q:** Remove Vercel from api-docs provider table?
**A:** No — that's just documentation fetching, not a dependency on the Vercel CLI.

**Q:** What replaces Hyperbrowser for web scraping?
**A:** Playwright MCP server. Runs locally, no API key needed.

**Q:** What replaces qlty for linting?
**A:** Auto-detect the project's own linter (eslint, ruff, pylint). If none found, skip gracefully.

**Q:** Delete rp-explorer agent or rewrite it?
**A:** Rewrite with native tools (Glob, Grep, Read). Same token-efficient exploration purpose.

**Q:** Replace rp-cli in other agents or just remove the sections?
**A:** Replace with native tool equivalents.

**Q:** What replaces Braintrust for session analysis?
**A:** Local logs — Claude Code transcripts, post-tool-use-tracker JSONL, and continuity ledgers.

**Q:** What about the LLM-as-judge learnings extraction at session end?
**A:** Replace with a local session summary written from continuity ledger data (no external API call).

---

## Plan: Replace Braintrust with Local Logs

### Goal

Remove the Braintrust external dependency (and the OpenAI API dependency it brings). Replace session analysis with local data sources that already exist in the repo.

### Local Data Sources Available

| Source | Location | Contents |
|--------|----------|----------|
| Claude Code transcript | `transcript_path` (passed to hooks) | Full JSONL of all tool calls, inputs, outputs |
| Build/test attempts | `.git/claude/branches/<branch>/attempts.jsonl` | Build pass/fail with command, exit code, output |
| Edited files log | `.claude/tsc-cache/<session>/edited-files.log` | Files edited during session |
| Continuity ledgers | `thoughts/ledgers/CONTINUITY_CLAUDE-*.md` | Session goals, state, decisions, working set |

### Files to Change

| File | Change |
|------|--------|
| `agents/braintrust-analyst.md` | Rewrite to analyze local transcript JSONL + attempts.jsonl instead of calling braintrust_analyze.py. Parse transcript for tool sequence, count tool usage, detect loops (same tool called >3 times in a row). |
| `agents/session-analyst.md` | Same as above — rewrite to use local transcript data. |
| `agents/review-agent.md` | Replace section 1.2 "Query Braintrust Session Data" with reading the local transcript and attempts.jsonl. Update description to remove "Braintrust" mention. Update example report template. |
| `agents/validate-agent.md` | Replace Step 4 "Check Past Precedent (RAG-Judge)" — instead of braintrust_analyze.py, search continuity ledgers and git history for past similar work. |
| `hooks/src/session-end-cleanup.ts` | Remove the Braintrust learnings extraction block (lines 66-89). Replace with writing a session summary to `thoughts/ledgers/` using the continuity ledger's current state (already read/updated earlier in the same hook). |
| `hooks/src/handoff-index.ts` | Remove BraintrustState interface and the block that reads `~/.claude/state/braintrust_sessions/`. Keep the artifact indexing logic. |
| `hooks/dist/*.mjs` | Rebuild from source. |
| `dependencies_summary.md` | Remove Braintrust and OpenAI API rows from Optional Services table. |

### Approach

1. **Analyst agents** — Rewrite to parse the transcript JSONL directly. The transcript has all tool calls with timing, inputs, outputs. This is the same data Braintrust was capturing.
2. **Review agent** — Replace Braintrust queries with reading transcript + attempts.jsonl. The agent can still compare plan vs reality — just using local files instead of an API.
3. **Validate agent** — Replace RAG-judge with searching continuity ledgers and git log for precedent.
4. **Session-end hook** — Remove the spawn of braintrust_analyze.py. The continuity ledger update (already in the hook) serves as the session summary.
5. **Handoff-index hook** — Strip Braintrust state reading. Keep artifact indexing.
6. **Rebuild hooks** — Run build script after TS changes.

### Notes

- The transcript JSONL format is: one JSON object per line, with fields like `tool_name`, `tool_input`, `tool_output`, `type` ("tool_use" or "tool_result").
- This removes both the `braintrust` and `openai` Python package dependencies.
- The `uv` dependency remains (used by other agent scripts), but `--with braintrust --with openai --with aiohttp` is eliminated.

---

## Plan: Update Setup Script to Install Dependencies

### Goal

Add dependency checking and auto-installation to `scripts/setup-claude.sh` so users get a working setup in one step.

### Dependencies to Check/Install

| Dependency | Check Command | Install Command | Required |
|-----------|--------------|----------------|----------|
| Node.js | `node --version` | `brew install node` | Yes |
| git | `git --version` | `brew install git` | Yes |
| gh (GitHub CLI) | `gh --version` | `brew install gh` | Yes |
| jq | `jq --version` | `brew install jq` | Yes |

### Changes to `scripts/setup-claude.sh`

1. **Add dependency check section** (new Step 0, before alias setup):
   - Check for Homebrew first — if missing, warn and list manual install commands
   - For each dependency: check if installed, if not `brew install` it
   - After installing gh, check `gh auth status` — if not authenticated, prompt user to run `gh auth login`

2. **Fix MCP config section**:
   - Remove stale "Update API keys" message (no API keys needed anymore)
   - Current behavior already only installs if `~/.mcp.json` doesn't exist — keep that

3. **Fix dependencies_summary.md**:
   - Remove stale Braintrust reference from Quick Start Checklist

### Notes

- Homebrew is the assumed package manager (macOS focus). If brew isn't available, fall back to warning with manual install instructions.
- `set -e` is already in the script, so failed installs will halt — that's fine, the user needs these deps.
- gh auth is interactive, so we prompt the user rather than running it automatically.
