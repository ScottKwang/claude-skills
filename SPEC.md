# Spec: Remove Railway Dependency

## Overview

Remove all Railway-related configuration, skills, and documentation from the repo. Deployment is handled outside this repo's skill set.

## Requirements

1. **Delete `skills/railway.md`** — the Railway deployment skill file
2. **Remove railway entry from `mcp-configs/mcp.json`** — the MCP server config
3. **Update `README.md`** — remove all railway references:
   - Railway row from the Skills table
   - Railway bullet from the MCP Servers section

## Scope

| File | Action |
|------|--------|
| `skills/railway.md` | Delete |
| `mcp-configs/mcp.json` | Remove `railway` server entry |
| `README.md` | Remove railway rows/bullets |

## Out of Scope

- No replacement deployment skill needed — deployment is managed elsewhere
- No changes to other skills, hooks, agents, or templates

## Decision Log

**Q:** Delete skill file or archive it?
**A:** Delete entirely.
**Rationale:** No need to keep dead code; git history preserves it if ever needed.

**Q:** Remove MCP server config too?
**A:** Yes.
**Rationale:** The MCP server only exists to support the skill.

**Q:** Why remove railway?
**A:** Deployment is handled outside this repo's skills.
**Rationale:** Keeps the repo focused on tools actually in use.
