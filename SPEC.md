# Spec: Remove Deployment Dependencies

## Overview

Remove deployment/environment management skills (Railway, Vercel) from the repo. These are handled outside this repo's skill set.

## Completed

### Railway (done)
1. ~~Delete `skills/railway.md`~~
2. ~~Remove railway entry from `mcp-configs/mcp.json`~~
3. ~~Update `README.md` — remove railway references~~

### Vercel
1. **Delete `skills/vercel-env.md`** — the Vercel env management skill
2. **Update `README.md`** — remove vercel-env rows from Skills table
3. **Update `dependencies_summary.md`** — remove vercel references

## Out of Scope

- Keep Vercel entry in `skills/api-docs.md` provider detection table (that's just doc fetching, not a dependency)
- No replacement skills needed — managed elsewhere
- No changes to hooks, agents, or templates

## Decision Log

**Q:** Delete skill files or archive them?
**A:** Delete entirely.
**Rationale:** Git history preserves them if ever needed.

**Q:** Remove MCP server config too? (Railway)
**A:** Yes — the MCP server only existed to support the skill.

**Q:** Why remove these?
**A:** Deployment and env management are handled outside this repo's skills.

**Q:** Remove Vercel from api-docs provider table?
**A:** No — that's just documentation fetching, not a dependency on the Vercel CLI.
