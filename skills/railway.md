# Railway Deployment

Deploy and manage Railway projects with natural language.

## Usage

- `/railway deploy` - Deploy current project to Railway
- `/railway status` - Check deployment status
- `/railway logs` - View recent logs
- `/railway env` - Manage environment variables
- `/railway link` - Link current directory to Railway project

## Arguments
$ARGUMENTS

---

## Prerequisites

1. Railway CLI installed: `brew install railway` or `npm i -g @railway/cli`
2. Logged in: `railway login`
3. MCP server configured (see setup below)

## MCP Setup

Add to `~/.mcp.json`:
```json
{
  "mcpServers": {
    "railway": {
      "command": "npx",
      "args": ["-y", "@railway/mcp-server"]
    }
  }
}
```

---

## Instructions

### Command: `deploy`

Deploy the current project to Railway:

1. **Check Railway CLI status**:
   ```bash
   railway whoami
   ```
   If not logged in, prompt user to run `railway login`

2. **Check if project is linked**:
   ```bash
   railway status
   ```
   If not linked, ask user which project to link or create new

3. **Deploy**:
   ```bash
   railway up
   ```

4. **Report deployment URL and status**

### Command: `status`

Check current deployment status:

1. Run `railway status` to get project info
2. Show:
   - Project name
   - Environment
   - Service status
   - Last deployment time
   - Public URL (if available)

### Command: `logs`

View recent deployment logs:

1. Run `railway logs --lines 100`
2. If errors found, summarize the issues
3. Suggest fixes if applicable

### Command: `env`

Manage environment variables:

**View all**: `railway variables`

**Set variable**:
```bash
railway variables set KEY=value
```

**Delete variable**:
```bash
railway variables delete KEY
```

Ask user what operation they want if not specified.

### Command: `link`

Link current directory to a Railway project:

1. List available projects:
   ```bash
   railway list
   ```

2. Ask user which project to link (or create new)

3. Link:
   ```bash
   railway link
   ```

4. Confirm linkage with `railway status`

---

## Common Workflows

### First-time Deploy

```bash
railway login           # Authenticate
railway init            # Create new project
railway up              # Deploy
railway domain          # Add custom domain (optional)
```

### Redeploy After Changes

```bash
railway up              # Redeploys with latest code
railway logs            # Check deployment logs
```

### Environment Setup

```bash
railway variables set DATABASE_URL="postgres://..."
railway variables set API_KEY="sk-..."
railway up              # Redeploy with new vars
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| "Not logged in" | Run `railway login` |
| "No project linked" | Run `railway link` or `railway init` |
| "Build failed" | Check `railway logs` for build errors |
| "No Dockerfile" | Railway auto-detects, but Dockerfile helps |

## Notes

- Railway auto-detects project type (Node, Python, Go, etc.)
- Deployments are triggered on `railway up` or git push (if connected)
- Free tier includes $5/month credits
- Use `railway run` to run commands with Railway env vars locally
