# Claude Code Custom Skills

A collection of reusable Claude Code skills and setup scripts for cross-device consistency.

## Quick Setup

Run the setup script to configure Claude Code with expanded permissions and the `cc` alias:

```bash
curl -fsSL https://raw.githubusercontent.com/ecoglito/claude-skills/main/scripts/setup-claude.sh | bash
```

Or manually add the alias:

```bash
echo "alias cc='claude --dangerously-skip-permissions'" >> ~/.zshrc
source ~/.zshrc
```

## What the Setup Script Does

1. **Creates `cc` alias** - Runs Claude Code skipping permission prompts
2. **Configures permissions** - Auto-allows common tools (git, npm, file ops, etc.)
3. **Sets up Hyperbrowser** - Browser automation via MCP (if `HYPERBROWSER_API_KEY` is set)

## Installing Skills

Copy skills to your user-level Claude commands directory:

```bash
# Clone the repo
git clone https://github.com/ecoglito/claude-skills.git

# Copy all skills to your user commands directory
mkdir -p ~/.claude/commands
cp claude-skills/skills/*.md ~/.claude/commands/
```

Or install individual skills:

```bash
curl -o ~/.claude/commands/api-docs.md https://raw.githubusercontent.com/ecoglito/claude-skills/main/skills/api-docs.md
```

## Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| [api-docs](skills/api-docs.md) | `/api-docs` | API documentation manager - detects APIs, fetches docs, sets up caching |

## Skill Locations

- **User-level** (`~/.claude/commands/`): Available in all projects
- **Project-level** (`.claude/commands/`): Project-specific skills

## Adding New Skills

1. Create a `.md` file in `skills/`
2. Follow the skill template structure
3. Update this README with the new skill
4. Push to main

## Skill Template

```markdown
# Skill Name

Description of what the skill does.

## Usage

- `/skill-name action` - What it does

## Arguments
$ARGUMENTS

---

## Instructions

### Command: `action`

Step-by-step instructions for Claude to follow...
```

## License

MIT
