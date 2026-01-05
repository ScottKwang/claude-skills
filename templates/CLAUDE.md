# Claude Code Guidelines

## Self-Improvement Protocol

After completing any task or fixing any bug, always consider:

1. **Skill Opportunities**: Could this solution become a reusable skill? Would a subagent + skill combination help?
2. **Patch Mistakes**: If I made an error, create a skill or reminder to prevent it next time
3. **Research Triggers**: When uncertain, note what research would have helped and add reminders
4. **Update CLAUDE.md**: Persist learnings about this codebase here

## Continuous Iteration

- Don't just solve problems — solve the class of problems
- Build skills proactively, not just when asked
- The harness should form to the codebase while shaping it back
- Store patches and reminders persistently, not just in context

## On Mistakes

Every mistake is a skill waiting to be written. Ask:
- What protection would have caught this?
- What reminder would have prompted the right research?
- How do I ensure this never happens again in this codebase?

---

## API Documentation Protocol

**ALWAYS fetch and reference cached docs when working with API integrations.**

### Cached Documentation Location

All API docs are cached in `.claude/cache/hyperdocs/`:

| Provider | File | Primary Use |
|----------|------|-------------|
| Example | `example.com_docs_api.md` | Description |

### When to Fetch Fresh Docs

1. **Before implementing any API integration** - always check cached docs first
2. **When encountering API errors** - docs may be outdated
3. **On session start** - run `/api-docs refresh` if reminded
4. **When adding new providers** - run `/api-docs fetch <provider>`

### How to Use

```bash
# Initialize in new repo (scans for APIs, fetches docs)
/api-docs init

# Fetch specific provider
/api-docs fetch stripe

# Refresh all docs
/api-docs refresh

# Check what's cached
/api-docs list
```

---

## Project Specifics

### Key Decisions

| Decision | Rationale |
|----------|-----------|
| Example | Why we chose this |

### Best Practices for This Codebase

1. **Read before modifying** - Understand existing patterns
2. **Test after changes** - Run relevant tests
3. **Document decisions** - Update this file with learnings

---

## Reminders

- Add project-specific reminders here
- Things Claude should always remember for this codebase
