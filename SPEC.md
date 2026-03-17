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
