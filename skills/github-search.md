# GitHub Search Skill

Search GitHub code, repositories, issues, and PRs via gh CLI.

## Usage

- `/github-search code "query"` - Search code
- `/github-search repos "query"` - Search repositories
- `/github-search issues "query"` - Search issues
- `/github-search prs "query"` - Search pull requests

## Arguments
$ARGUMENTS

---

## Instructions

Use the `gh` CLI directly for searches:

### Command: `code`

```bash
gh search code "$ARGUMENTS" --limit 10
```

### Command: `repos`

```bash
gh search repos "$ARGUMENTS" --limit 10
```

### Command: `issues`

```bash
gh search issues "$ARGUMENTS" --limit 10
```

### Command: `prs`

```bash
gh search prs "$ARGUMENTS" --limit 10
```

### Common Filters

```bash
# Search in specific repo
gh search code "query" --repo owner/repo

# Search by language
gh search code "query" --language python

# Search issues by state
gh search issues "bug" --state open

# Search by owner
gh search repos "query" --owner anthropics
```

## Requirements

- `gh` CLI installed and authenticated (`gh auth login`)
