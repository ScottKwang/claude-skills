# External Dependencies Summary

## Core Requirements

These are needed for the hooks and basic skill functionality.

| Dependency | Type | Install | Used By |
|-----------|------|---------|---------|
| **Node.js v20+** | Runtime | [nodejs.org](https://nodejs.org) | All hooks (pre-bundled .mjs files) |
| **git** | CLI | Pre-installed | github-push skill, agents |
| **gh** (GitHub CLI) | CLI | `brew install gh` | github-search, github-push skills |
| **jq** | CLI | `brew install jq` | post-tool-use-tracker hook |

## API Keys

| Variable | Service | Used By | Required |
|----------|---------|---------|----------|
| `HYPERBROWSER_API_KEY` | [hyperbrowser.ai](https://hyperbrowser.ai) | Hyperbrowser MCP server | Only if using web scraping fallback |

## MCP Servers

Configured in `mcp-configs/mcp.json`. Auto-installed via npx on first use.

| Server | Package | Purpose |
|--------|---------|---------|
| **hyperbrowser** | `hyperbrowser-mcp` | Web scraping fallback when WebFetch is blocked |
| **xcodebuildmcp** | `xcodebuildmcp` | Xcode build/simulator for iOS/macOS development |

## Skill-Specific Dependencies

| Dependency | Type | Install | Skill |
|-----------|------|---------|-------|
| **gh** (authenticated) | CLI | `gh auth login` | github-search, github-push |

## Agent Dependencies

These are optional — only needed if using the corresponding agents.

| Dependency | Type | Install | Agents |
|-----------|------|---------|--------|
| **uv** | Python pkg manager | `brew install uv` | braintrust-analyst, session-analyst, context-query-agent, plan-agent, research-agent, review-agent, validate-agent, debug-agent |
| **Python 3.8+** | Runtime | Pre-installed on macOS | Same as above |
| **rp-cli** (RepoPrompt) | CLI | Via RepoPrompt app | rp-explorer, onboard, plan-agent, research-agent, debug-agent |
| **sqlite3** | CLI | Pre-installed on macOS | session-start-continuity hook (artifact index queries) |

## Hook Development Only

Only needed if modifying the TypeScript hook source files.

| Dependency | Type | Install |
|-----------|------|---------|
| **esbuild** | Dev dependency | `cd hooks && npm install` |
| **typescript** | Dev dependency | Included in hooks/package.json |
| **@types/node** | Dev dependency | Included in hooks/package.json |

Users do **not** need these — hooks ship pre-bundled as `.mjs` files in `hooks/dist/`.

## Optional Services

| Service | Purpose | Agents/Hooks |
|---------|---------|-------------|
| **Braintrust** | Session trace analysis | braintrust-analyst, session-analyst, review-agent, validate-agent |
| **OpenAI API** | Learnings extraction (LLM-as-judge) | session-end-cleanup hook |
| **qlty** | Code quality checks | review-agent |

## Quick Start Checklist

```
Required:
  [x] Node.js v20+
  [x] git
  [x] gh (GitHub CLI, authenticated)
  [x] jq

Recommended:
  [ ] Hyperbrowser API key (for web scraping)
  [ ] uv + Python 3.8+ (if using analysis agents)

Optional:
  [ ] RepoPrompt / rp-cli (for codebase exploration agents)
  [ ] Braintrust account (for session analysis)
  [ ] xcodebuildmcp (for iOS development)
```
