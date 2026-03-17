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

---

## Plan: Replace qlty with Project-Native Linters

### Goal

Remove the `qlty` external dependency. Instead, detect and run whatever linter the project already uses (eslint, ruff, pylint, etc.).

### Files to Change

| File | Change |
|------|--------|
| `hooks/src/typescript-preflight.ts` | Replace `qlty_errors` handling with eslint output. Rename the field generically (e.g. `lint_errors`). The hook calls an external `typescript_check.py` script — update the comment/description to say "tsc + project linter" instead of "tsc + qlty". |
| `hooks/dist/typescript-preflight.mjs` | Rebuild from source after editing `.ts` file. |
| `agents/review-agent.md` | Replace section 1.5 "Run Code Quality Checks (qlty)" with a generic "Run Project Linter" section that auto-detects the linter: check for `.eslintrc*`/`eslint.config.*` → run eslint, `ruff.toml`/`pyproject.toml` with ruff → run ruff, `setup.cfg`/`pyproject.toml` with pylint → run pylint, else skip with note. |
| `agents/review-agent.md` | Update the example report template: rename "Code Quality (qlty)" to "Code Quality (Linting)". |
| `dependencies_summary.md` | Remove qlty from Optional Services table. |

### Approach

1. **`review-agent.md`** — Replace the qlty section with auto-detection logic. The agent should try to find the project's linter config and run it. If none found, skip gracefully.
2. **`typescript-preflight.ts`** — The hook delegates to `typescript_check.py` which returns a JSON object with `qlty_errors`. Rename the field to `lint_errors` and update the label from "Lint Issues" to keep it generic. The actual linting logic lives in the external Python script (not in this repo), so we just update what the hook expects.
3. **Rebuild `dist/`** — Run the build script to regenerate the bundled JS.
4. **`dependencies_summary.md`** — Remove qlty row.

### Notes

- The `typescript_check.py` script that does the actual checking is NOT in this repo (it lives at `~/.claude/scripts/` or `project/scripts/`). We're only changing what the hook expects from it, not the script itself.
- The hook already handles missing scripts gracefully (continues silently), so renaming the field is backwards-compatible — old scripts returning `qlty_errors` just won't match `lint_errors`, and the hook will skip the lint section silently.

---

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
