# Claude Code Power User Setup

One-time setup to get Claude Code ripping immediately on any device.

## What's Included

### 🚀 Quick Setup

```bash
git clone https://github.com/ScottKwang/claude-skills.git
cd claude-skills
./scripts/setup-claude.sh
source ~/.zshrc
```

Then just run:
- `cc` - Start Claude Code (skip permission prompts)
- `ccr` - Resume last session (skip permissions + resume picker)

### 📦 Skills

Skills are slash commands you invoke directly. Installed to `~/.claude/commands/` or `<project>/.claude/commands/`.

| Skill | Command | Description | Output |
|-------|---------|-------------|--------|
| [api-docs](skills/api-docs.md) | `/api-docs init` | Detects APIs in codebase, fetches docs, sets up caching | `.claude/cache/hyperdocs/*.md` |
| | `/api-docs fetch <provider>` | Fetch docs for specific provider (stripe, openai, etc.) | `.claude/cache/hyperdocs/<domain>_<path>.md` |
| | `/api-docs refresh` | Refresh all cached documentation | Updates existing cache files |
| [github-push](skills/github-push.md) | `/github-push` | Commit and push with auto-generated message | Git commit + push |
| | `/github-push --pr` | Push and create pull request | GitHub PR |
| [github-search](skills/github-search.md) | `/github-search <query>` | Search GitHub repos, code, issues, PRs | Search results |
| [spec-generator](skills/spec-generator.md) | `/spec-generator` | Deep-dive spec interview to catch edge cases | `SPEC.md` |

### 🤖 Agents

Agents run as subprocesses for complex tasks. Installed to `~/.claude/agents/` or `<project>/.claude/agents/`.

| Agent | Purpose | Output |
|-------|---------|--------|
| [onboard](agents/onboard.md) | Analyze brownfield codebase, create initial ledger | `thoughts/ledgers/CONTINUITY_CLAUDE-*.md` |
| [plan-agent](agents/plan-agent.md) | Create implementation plans from research | `.claude/cache/agents/plan-agent/latest-output.md` |
| [research-agent](agents/research-agent.md) | Deep research using MCP tools | `.claude/cache/agents/research-agent/latest-output.md` |
| [review-agent](agents/review-agent.md) | Compare plan vs implementation vs git diff | `.claude/cache/agents/review-agent/latest-output.md` |
| [debug-agent](agents/debug-agent.md) | Investigate issues, trace code, identify root causes | `.claude/cache/agents/debug-agent/latest-output.md` |
| [validate-agent](agents/validate-agent.md) | Validate tech choices against best practices | `.claude/cache/agents/validate-agent/latest-output.md` |
| [rp-explorer](agents/rp-explorer.md) | Token-efficient codebase exploration | Returns summary to main conversation |
| [codebase-analyzer](agents/codebase-analyzer.md) | Analyze repo structure and internals | Returns summary to main conversation |
| [codebase-locator](agents/codebase-locator.md) | Find files and components for a task | Returns summary to main conversation |
| [braintrust-analyst](agents/braintrust-analyst.md) | Analyze sessions from local transcript logs | `.claude/cache/agents/braintrust-analyst/latest-output.md` |
| [session-analyst](agents/session-analyst.md) | Lightweight session analysis | `.claude/cache/agents/session-analyst/latest-output.md` |

**How agents work:** Agents are spawned automatically by Claude Code as subprocesses via the `Agent` tool whenever a task matches an agent's `description` field. The setup script installs the `.md` files to `~/.claude/agents/` (global) or `<project>/.claude/agents/` (project-scoped), where Claude Code picks them up by `name`. You can also request a specific agent explicitly (e.g., "use the debug agent to investigate this"). Each agent's `model` frontmatter field controls which Claude model it runs on. The `subagent-stop-continuity` hook logs agent output to `.claude/cache/agents/<name>/latest-output.md` so results persist across conversations.

### 🪝 Hooks System

Pre-bundled TypeScript hooks that run automatically at Claude Code lifecycle events. **Zero runtime dependencies** — hooks are pre-bundled JS, just clone and go.

| Hook | Event | When it fires | Output location |
|------|-------|--------------|-----------------|
| skill-activation-prompt | UserPromptSubmit | Every time the user sends a prompt | Suggests skills inline |
| session-start-continuity | SessionStart | When a new session begins | Injects ledger into context |
| pre-compact-continuity | PreCompact | Before context window compaction | `thoughts/handoffs/auto-handoff-*.md` |
| session-end-cleanup | SessionEnd | When session ends (exit, clear, logout) | Updates `thoughts/ledgers/CONTINUITY_CLAUDE-*.md` |
| subagent-stop-continuity | SubagentStop | When a subagent completes | Appends to continuity ledger |
| post-tool-use-tracker | PostToolUse | After Edit/Write (file tracking) or Bash (build detection) | `.git/claude/branches/<branch>/attempts.jsonl`, `.claude/tsc-cache/<session>/edited-files.log` |
| typescript-preflight | PostToolUse | After Edit/Write on `.ts/.tsx` files | Blocks with errors if tsc/linter fails |
| handoff-index | PostToolUse | After Write to a handoff file | Adds `session_id` to frontmatter |
| session-outcome | SessionEnd | When session ends | Session summary |

### 🔌 MCP Servers

Pre-configured MCP servers:

- **playwright** - Browser automation for web scraping *(no API key needed)*
- **xcodebuildmcp** - Xcode build, simulator, and device automation for iOS/macOS development

### ⚙️ Settings

Expanded permissions for common operations:
- Git, GitHub CLI
- Package managers (npm, yarn, pnpm, pip, cargo, etc.)
- File operations
- Docker, kubectl
- Xcode, Swift (iOS development)
- Web fetching and searching

Plugins enabled:
- **swift-lsp** - Swift language server
- **ralph-wiggum** - Persistent loop technique

### 📄 Templates

- `templates/CLAUDE.md` - Project CLAUDE.md with best practices
- `templates/settings.json` - Full settings configuration

## Directory Structure

```
claude-skills/
├── scripts/
│   └── setup-claude.sh      # Installation script (--global or --project)
├── skills/                   # Slash commands (/skill-name)
│   ├── api-docs.md
│   ├── github-push.md
│   ├── github-search.md
│   └── spec-generator.md
├── agents/                   # Subagent definitions
│   ├── onboard.md
│   ├── plan-agent.md
│   ├── review-agent.md
│   └── ...                   # 11 agents total
├── hooks/
│   ├── src/                  # TypeScript source (edit these)
│   ├── dist/                 # Pre-bundled JS (committed, zero deps)
│   ├── *.sh                  # Shell wrappers (entry points)
│   └── package.json          # Dev deps only (esbuild, typescript)
├── mcp-configs/
│   └── mcp.json              # MCP server config (playwright, xcodebuildmcp)
└── templates/
    ├── CLAUDE.md             # Project CLAUDE.md template
    └── settings.json         # Settings + permissions + hooks config
```

## Manual Installation

If you prefer to install components individually:

### cc alias only

```bash
echo "alias cc='claude --dangerously-skip-permissions'" >> ~/.zshrc
source ~/.zshrc
```

### Skills only

```bash
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/api-docs.md https://raw.githubusercontent.com/ecoglito/claude-skills/main/skills/api-docs.md
```

### Hooks only

```bash
git clone https://github.com/ScottKwang/claude-skills.git
cp -r claude-skills/hooks/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

### Settings only

```bash
curl -o ~/.claude/settings.json https://raw.githubusercontent.com/ecoglito/claude-skills/main/templates/settings.json
```

## Adding Your Own Skills

1. Create a `.md` file in `skills/`
2. Follow the template structure:

```markdown
# Skill Name

Description.

## Usage

- `/skill-name action` - What it does

## Arguments
$ARGUMENTS

---

## Instructions

### Command: `action`

Step-by-step instructions...
```

3. Push to main
4. Re-run `./scripts/setup-claude.sh` on other devices

## Updating

```bash
cd claude-skills
git pull
./scripts/setup-claude.sh
```

The setup script is idempotent - safe to run multiple times.

## API Keys

No API keys required. All MCP servers work out of the box.

## License

MIT
