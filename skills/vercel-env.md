# Vercel Environment Variables

Manage environment variables on Vercel projects.

## Usage

- `/vercel-env list` - List all environment variables
- `/vercel-env set KEY=value` - Set an environment variable
- `/vercel-env pull` - Pull env vars to local .env
- `/vercel-env push` - Push local .env to Vercel

## Arguments
$ARGUMENTS

---

## Prerequisites

1. Vercel CLI installed: `npm i -g vercel`
2. Logged in: `vercel login`
3. Project linked: `vercel link`

---

## Instructions

### Command: `list`

List all environment variables:

```bash
vercel env ls
```

Show which environments each variable is set for (Production, Preview, Development).

### Command: `set KEY=value`

Set an environment variable:

1. Parse the KEY=value from arguments
2. Ask which environments to set for (or default to all):
   ```bash
   vercel env add KEY production preview development
   ```
3. Enter the value when prompted, or use:
   ```bash
   echo "value" | vercel env add KEY production preview development
   ```

### Command: `pull`

Pull environment variables to local `.env` file:

```bash
vercel env pull .env.local
```

This creates/updates `.env.local` with all Development environment variables.

### Command: `push`

Push local `.env` file to Vercel:

1. Read the local `.env` or `.env.local` file
2. For each KEY=value pair:
   ```bash
   echo "value" | vercel env add KEY development
   ```
3. Report which variables were pushed

**Note**: This only pushes to Development environment by default. Ask user if they want Production/Preview too.

---

## Environment Types

| Environment | When Used |
|-------------|-----------|
| Production | Main branch deployments |
| Preview | PR/branch deployments |
| Development | Local development (`vercel dev`) |

## Common Patterns

### Sync from another service

```bash
# Pull from Vercel
vercel env pull .env.local

# Or set from .env file
cat .env | while IFS='=' read -r key value; do
  echo "$value" | vercel env add "$key" development
done
```

### Copy between environments

```bash
# Get production value
vercel env pull .env.production --environment=production

# Set to preview
cat .env.production | while IFS='=' read -r key value; do
  echo "$value" | vercel env add "$key" preview
done
```

## Notes

- Sensitive values (like API keys) should use Vercel's encrypted storage
- Changes require redeployment to take effect
- Use `vercel --prod` to deploy to production after env changes
