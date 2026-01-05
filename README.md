# Claude Code Custom Skills

A collection of reusable Claude Code skills for cross-device consistency.

## Installation

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
