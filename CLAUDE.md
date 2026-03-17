# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A setup and extensibility system for Claude Code. Provides pre-configured skills, agents, hooks, MCP servers, and settings. Designed for zero external API keys and minimal setup friction.

## Build & Development

### Building hooks (the only build step)

```bash
cd hooks && npm run build
```

This runs esbuild to bundle `hooks/src/*.ts` into `hooks/dist/*.mjs`. Users don't need to build — dist files are pre-committed. Only rebuild after editing TypeScript sources.

If `node_modules/` is missing:
```bash
cd hooks && npm install && npm run build
```

### Setup script

```bash
./scripts/setup-claude.sh              # Interactive (global or project)
./scripts/setup-claude.sh --global     # Install to ~/.claude/
./scripts/setup-claude.sh --project .  # Install to <project>/.claude/
```

## Architecture

### Hooks: Shell wrappers → Pre-bundled JS

Each hook has three layers:
1. **`hooks/src/*.ts`** — TypeScript source (edit these)
2. **`hooks/dist/*.mjs`** — ESBuild bundles (committed, zero runtime deps)
3. **`hooks/*.sh`** — Shell wrappers that pipe stdin to `node dist/<name>.mjs`

Exception: `post-tool-use-tracker.sh` is pure Bash with no TypeScript source.

Hooks read JSON from stdin, write JSON to stdout. They follow a graceful degradation pattern: missing files or parse errors silently continue rather than blocking Claude Code.

### Hook events

| Shell wrapper | Event | What it does |
|--------------|-------|-------------|
| skill-activation-prompt.sh | UserPromptSubmit | Matches prompt against skill-rules.json, suggests relevant skills |
| session-start-continuity.sh | SessionStart | Loads continuity ledger into context |
| pre-compact-continuity.sh | PreCompact | Creates handoff before context compaction |
| session-end-cleanup.sh | SessionEnd | Updates ledger timestamp, prunes old cache |
| subagent-stop-continuity.sh | SubagentStop | Logs agent output for resumability |
| typescript-preflight.sh | PostToolUse | Runs tsc + linter after .ts/.tsx edits |
| post-tool-use-tracker.sh | PostToolUse | Tracks edited files and build pass/fail |
| handoff-index.sh | PostToolUse | Injects session_id into handoff files |
| session-outcome.sh | SessionEnd | Writes session summary |

### Skills (`skills/*.md`)

Markdown files that become slash commands when installed to `~/.claude/commands/` or `<project>/.claude/commands/`. Invoked as `/skill-name action`.

### Agents (`agents/*.md`)

Markdown files with YAML frontmatter (`name`, `description`, `model`). Installed to `~/.claude/agents/` or `<project>/.claude/agents/`. All agents use native Claude Code tools (Glob, Grep, Read) — no external CLIs.

### Path resolution convention

Hooks and skills check project-scoped paths first, then fall back to global:
```
$CLAUDE_PROJECT_DIR/.claude/  →  ~/.claude/
```

### Local data locations

| Data | Path |
|------|------|
| Build attempts | `.git/claude/branches/<branch>/attempts.jsonl` |
| Edited files | `.claude/tsc-cache/<session>/edited-files.log` |
| Continuity ledgers | `thoughts/ledgers/CONTINUITY_CLAUDE-*.md` |
| API doc cache | `.claude/cache/hyperdocs/` |
| Agent output | `.claude/cache/agents/<name>/latest-output.md` |

## Key Conventions

- **After editing any `hooks/src/*.ts` file**, always rebuild: `cd hooks && npm run build`
- **Hooks must not block on failure** — catch errors and exit 0 or output `{"result":"continue"}`
- **No API keys** — MCP servers (playwright, xcodebuildmcp) run locally via npx
- **Dependencies**: Node.js, git, gh, jq are required. The setup script auto-installs them via Homebrew.
