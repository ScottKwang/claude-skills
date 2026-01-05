# Claude Code Power User Setup

One-time setup to get Claude Code ripping immediately on any device.

## What's Included

### 🚀 Quick Setup

```bash
git clone https://github.com/ecoglito/claude-skills.git
cd claude-skills
./scripts/setup-claude.sh
source ~/.zshrc
```

Then just run `cc` to start Claude Code with permissions skipped.

### 📦 Skills

| Skill | Command | Description |
|-------|---------|-------------|
| [api-docs](skills/api-docs.md) | `/api-docs init` | Detects APIs in codebase, fetches docs, sets up caching |
| | `/api-docs fetch <provider>` | Fetch docs for specific provider (stripe, openai, etc.) |
| | `/api-docs refresh` | Refresh all cached documentation |
| [github-push](skills/github-push.md) | `/github-push` | Commit and push with auto-generated message |
| | `/github-push --pr` | Push and create pull request |
| [railway](skills/railway.md) | `/railway deploy` | Deploy current project to Railway |
| | `/railway logs` | View deployment logs |
| | `/railway env` | Manage environment variables |
| [vercel-env](skills/vercel-env.md) | `/vercel-env list` | List Vercel environment variables |
| | `/vercel-env push` | Push local .env to Vercel |
| [spec-generator](skills/spec-generator.md) | `/spec-generator` | Deep-dive spec interview to catch edge cases |

### 🪝 Hooks System

Pre-bundled TypeScript hooks that enhance Claude Code:

| Hook | Event | Purpose |
|------|-------|---------|
| skill-activation-prompt | UserPromptSubmit | Auto-suggests relevant skills based on prompts |
| session-start-continuity | SessionStart | Loads continuity ledger on session start |
| pre-compact-continuity | PreCompact | Creates handoff before context compaction |
| session-end-cleanup | SessionEnd | Updates ledger, cleans old cache |
| subagent-stop-continuity | SubagentStop | Logs agent output for resumability |
| post-tool-use-tracker | PostToolUse | Tracks file changes and build attempts |
| typescript-preflight | PreToolUse | TypeScript validation before edits |

**Zero runtime dependencies** - hooks are pre-bundled JS, just clone and go.

### 🔌 MCP Servers

Pre-configured MCP servers:

- **hyperbrowser** - Browser automation for web scraping
- **railway** - Deploy and manage Railway projects

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
│   └── setup-claude.sh      # Full installation script
├── skills/
│   └── api-docs.md          # API documentation manager
├── hooks/
│   ├── src/                  # TypeScript source
│   ├── dist/                 # Pre-bundled JS (ready to run)
│   ├── *.sh                  # Shell wrappers
│   ├── README.md             # Hooks documentation
│   └── CONFIG.md             # Configuration guide
├── mcp-configs/
│   └── mcp.json              # MCP server configuration
└── templates/
    ├── CLAUDE.md             # Project CLAUDE.md template
    └── settings.json         # Settings template
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
git clone https://github.com/ecoglito/claude-skills.git
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

After setup, edit `~/.mcp.json` to add your API keys:

```json
{
  "mcpServers": {
    "hyperbrowser": {
      "env": {
        "HYPERBROWSER_API_KEY": "your-key-here"
      }
    }
  }
}
```

## License

MIT
