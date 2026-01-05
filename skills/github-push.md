# GitHub Push

Commit and push code to GitHub with auto-generated commit messages.

## Usage

- `/github-push` - Commit all changes and push to current branch
- `/github-push "message"` - Commit with custom message and push
- `/github-push --pr` - Push and create a pull request

## Arguments
$ARGUMENTS

---

## Instructions

### Default: Commit and Push

1. **Check git status**:
   ```bash
   git status
   git diff --stat
   ```

2. **Stage all changes**:
   ```bash
   git add -A
   ```

3. **Generate commit message** based on changes:
   - Look at what files changed
   - Summarize the nature of changes (feat, fix, refactor, docs, etc.)
   - Create concise commit message

4. **Commit**:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>: <description>

   🤖 Generated with [Claude Code](https://claude.com/claude-code)

   Co-Authored-By: Claude <noreply@anthropic.com>
   EOF
   )"
   ```

5. **Push**:
   ```bash
   git push
   ```
   If upstream not set:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

6. **Report** commit hash and branch pushed

### With Custom Message

If arguments contain a quoted message, use that instead of auto-generating.

### With --pr Flag

After pushing, create a pull request:

```bash
gh pr create --fill
```

Or if you want to customize:
```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Commit Message Conventions

| Prefix | Use Case |
|--------|----------|
| feat: | New feature |
| fix: | Bug fix |
| refactor: | Code restructuring |
| docs: | Documentation only |
| style: | Formatting, no code change |
| test: | Adding tests |
| chore: | Maintenance tasks |

## Notes

- Never force push unless explicitly asked
- Always check `git status` before committing
- If there are no changes, report "Nothing to commit"
