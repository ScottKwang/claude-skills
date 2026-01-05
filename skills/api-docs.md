# API Documentation Manager

Comprehensive skill for managing API documentation across any codebase. Detects APIs in use, fetches documentation, sets up caching, and configures freshness checking.

## Usage

- `/api-docs init` - Initialize API docs system in current repo (detect APIs, fetch docs, update CLAUDE.md, set up hooks)
- `/api-docs scan` - Scan codebase to detect which APIs are in use
- `/api-docs fetch <provider>` - Fetch docs for specific provider (gemini, anthropic, openai, bland, firebase, stripe, twilio, supabase, etc.)
- `/api-docs fetch <url>` - Fetch docs from any URL
- `/api-docs refresh` - Refresh all cached documentation
- `/api-docs list` - List all cached docs with freshness status
- `/api-docs add <name> <url>` - Add a new provider to the registry

## Arguments
$ARGUMENTS

---

## Instructions

### Command: `init`

Full initialization of the API docs system for the current repository:

#### Step 1: Create cache directory
```bash
mkdir -p .claude/cache/hyperdocs
mkdir -p .claude/hooks
```

#### Step 2: Scan for APIs
Search the codebase for API usage patterns. Look for:

**Environment variables** (in `.env*`, `*.yml`, `*.json`, code files):
- `ANTHROPIC_API_KEY` → Anthropic/Claude
- `OPENAI_API_KEY` → OpenAI
- `GOOGLE_API_KEY`, `GOOGLE_AI_API_KEY`, `GEMINI_API_KEY` → Google/Gemini
- `BLAND_API_KEY` → Bland AI
- `TWILIO_*` → Twilio
- `STRIPE_*` → Stripe
- `SUPABASE_*` → Supabase
- `FIREBASE_*` → Firebase
- `SENDGRID_*` → SendGrid
- `AWS_*` → AWS
- `PINECONE_*` → Pinecone
- `REPLICATE_*` → Replicate

**Import patterns** (in code files):
- `import openai`, `from openai` → OpenAI
- `import anthropic`, `from anthropic` → Anthropic
- `google.generativeai`, `google.genai` → Gemini
- `firebase`, `FirebaseApp` → Firebase
- `stripe` → Stripe
- `twilio` → Twilio
- `@supabase` → Supabase

**Package dependencies** (in `package.json`, `requirements.txt`, `Podfile`, `Package.swift`):
- Check for SDK packages

Report which APIs were detected.

#### Step 3: Fetch documentation
For each detected API, fetch documentation using WebFetch. Use the Provider Registry below.

Save each doc to `.claude/cache/hyperdocs/<domain>_<path>.md` with header:
```markdown
# [Provider] API Documentation

> Cached from: [URL]
> Fetched: [YYYY-MM-DD]
> Detected via: [env var / import / package]

---

[Content]
```

#### Step 4: Update CLAUDE.md
Check if CLAUDE.md exists. If not, create it. If it exists, check if it already has "## API Documentation Protocol" section.

If section doesn't exist, append this section (customize the table based on detected providers):

```markdown
---

## API Documentation Protocol

**ALWAYS fetch and reference cached docs when working with API integrations.**

### Cached Documentation Location

All API docs are cached in `.claude/cache/hyperdocs/`:

| Provider | File | Primary Use |
|----------|------|-------------|
[GENERATE TABLE BASED ON DETECTED/FETCHED PROVIDERS]

### When to Fetch Fresh Docs

1. **Before implementing any API integration** - always check cached docs first
2. **When encountering API errors** - docs may be outdated
3. **On session start** - run `/api-docs refresh` if reminded
4. **When adding new providers** - run `/api-docs fetch <provider>`

### How to Use

```bash
# Initialize in new repo
/api-docs init

# Fetch specific provider
/api-docs fetch stripe

# Refresh all docs
/api-docs refresh

# Check what's cached
/api-docs list
```

### API Integration Workflow

1. **Read cached docs first**: Check `.claude/cache/hyperdocs/` for provider
2. **Fetch if missing**: Use `/api-docs fetch <provider>` if needed
3. **Reference during implementation**: Keep docs in mind for parameter names, formats
4. **Update on error**: If API calls fail, refresh docs - APIs change frequently
```

#### Step 5: Set up freshness hook
Create `.claude/hooks/check-docs-freshness.sh`:
```bash
#!/bin/bash
DOCS_DIR="$(pwd)/.claude/cache/hyperdocs"
STALE_DAYS=7

if [ ! -d "$DOCS_DIR" ]; then
    echo "API docs cache not found. Run: /api-docs init"
    exit 0
fi

STALE_COUNT=0
TOTAL_COUNT=0

for doc in "$DOCS_DIR"/*.md; do
    [ -f "$doc" ] || continue
    TOTAL_COUNT=$((TOTAL_COUNT + 1))
    if [ "$(find "$doc" -mtime +$STALE_DAYS 2>/dev/null)" ]; then
        STALE_COUNT=$((STALE_COUNT + 1))
    fi
done

if [ $TOTAL_COUNT -eq 0 ]; then
    echo "No API docs cached. Run: /api-docs init"
elif [ $STALE_COUNT -gt 0 ]; then
    echo "API docs may be stale ($STALE_COUNT/$TOTAL_COUNT older than ${STALE_DAYS}d). Consider: /api-docs refresh"
fi
```

Make executable: `chmod +x .claude/hooks/check-docs-freshness.sh`

Update `.claude/settings.json` to add the hook to SessionStart (merge with existing if present).

#### Step 6: Report summary
Output:
- APIs detected
- Docs fetched
- CLAUDE.md updated (yes/no)
- Hook installed (yes/no)

---

### Command: `scan`

Scan the codebase for API usage without fetching docs:

1. Search for env vars, imports, and package dependencies (as described in Step 2 of init)
2. Report all detected APIs with detection method
3. Suggest `/api-docs fetch <provider>` commands for any that don't have cached docs

---

### Command: `fetch <provider>` or `fetch <url>`

If argument is a known provider name, use the Provider Registry URL.
If argument is a URL, fetch directly.

1. Use WebFetch to get documentation
2. Save to `.claude/cache/hyperdocs/<domain>_<path>.md`
3. Report success with file path

---

### Command: `refresh`

Refresh ALL cached documentation:

1. List all `.md` files in `.claude/cache/hyperdocs/`
2. Extract the "Cached from:" URL from each file header
3. Re-fetch each URL using WebFetch
4. Update the files with new content and timestamp
5. Report summary

---

### Command: `list`

List cached documentation with freshness status:

1. List all files in `.claude/cache/hyperdocs/`
2. For each file, show:
   - Provider name (from filename)
   - File size
   - Last modified date
   - Freshness (Fresh <7d, Stale ≥7d)
3. Show total count

---

### Command: `add <name> <url>`

Add a new provider to the local registry:

1. Fetch docs from URL
2. Save with appropriate filename
3. Suggest adding to CLAUDE.md table

---

## Provider Registry

Use these URLs for known providers:

| Provider | Keyword | Documentation URL |
|----------|---------|-------------------|
| Anthropic/Claude | `anthropic`, `claude` | https://platform.claude.com/docs/en/api/getting-started |
| OpenAI | `openai`, `gpt` | https://platform.openai.com/docs/api-reference/chat/create |
| Google Gemini | `gemini`, `google-ai` | https://ai.google.dev/gemini-api/docs/gemini-3 |
| Bland AI | `bland` | https://docs.bland.ai/api-v1/post/calls |
| Firebase Auth (iOS) | `firebase-ios` | https://firebase.google.com/docs/auth/ios/start |
| Firebase Auth (Web) | `firebase-web` | https://firebase.google.com/docs/auth/web/start |
| Stripe | `stripe` | https://stripe.com/docs/api |
| Twilio | `twilio` | https://www.twilio.com/docs/usage/api |
| Supabase | `supabase` | https://supabase.com/docs/reference/javascript/introduction |
| SendGrid | `sendgrid` | https://docs.sendgrid.com/api-reference/mail-send/mail-send |
| Pinecone | `pinecone` | https://docs.pinecone.io/reference/api/introduction |
| Replicate | `replicate` | https://replicate.com/docs/reference/http |
| AWS S3 | `aws-s3` | https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html |
| Vercel | `vercel` | https://vercel.com/docs/rest-api |
| Resend | `resend` | https://resend.com/docs/api-reference/introduction |
| Clerk | `clerk` | https://clerk.com/docs/reference/backend-api |
| Auth0 | `auth0` | https://auth0.com/docs/api |

## Notes

- WebFetch may not work for all URLs (403 errors, auth-required pages). Fall back to mcp__hyperbrowser__scrape_webpage if needed.
- For OpenAI specifically, use Hyperbrowser scraping as their docs block WebFetch.
- Always preserve the "Cached from:" header so refresh can work.
- The hook uses project-local paths (`.claude/hooks/`) not global paths.
