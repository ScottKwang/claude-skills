#!/bin/bash
# Claude Code Setup Script
# Configures Claude Code with expanded permissions and browser access

set -e

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "🔧 Setting up Claude Code..."

# Create .claude directory if it doesn't exist
mkdir -p "$CLAUDE_DIR/commands"

# Define the settings with expanded permissions
SETTINGS='{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(gh *)",
      "Bash(npm *)",
      "Bash(npx *)",
      "Bash(yarn *)",
      "Bash(pnpm *)",
      "Bash(node *)",
      "Bash(python *)",
      "Bash(pip *)",
      "Bash(cargo *)",
      "Bash(go *)",
      "Bash(make *)",
      "Bash(docker *)",
      "Bash(kubectl *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(cd *)",
      "Bash(mkdir *)",
      "Bash(rm *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(chmod *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(sed *)",
      "Bash(awk *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(sort *)",
      "Bash(uniq *)",
      "Bash(wc *)",
      "Bash(xargs *)",
      "Bash(open *)",
      "Bash(pbcopy *)",
      "Bash(pbpaste *)",
      "Bash(echo *)",
      "Bash(cat *)",
      "Bash(touch *)",
      "Bash(task-master *)",
      "Bash(xcodebuild *)",
      "Bash(swift *)",
      "Bash(xcodegen *)",
      "Bash(pod *)",
      "Bash(brew *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep",
      "WebFetch",
      "WebSearch",
      "mcp__hyperbrowser__*"
    ],
    "deny": []
  }
}'

# Check if settings file exists
if [ -f "$SETTINGS_FILE" ]; then
    echo "⚠️  Existing settings found at $SETTINGS_FILE"
    echo "   Creating backup at ${SETTINGS_FILE}.backup"
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
fi

# Write new settings
echo "$SETTINGS" > "$SETTINGS_FILE"
echo "✅ Settings written to $SETTINGS_FILE"

# Set up MCP config for Hyperbrowser if API key exists
MCP_FILE="$HOME/.mcp.json"
if [ -n "$HYPERBROWSER_API_KEY" ]; then
    echo "🌐 Setting up Hyperbrowser MCP..."
    cat > "$MCP_FILE" << 'EOF'
{
  "mcpServers": {
    "hyperbrowser": {
      "command": "npx",
      "args": ["-y", "@anthropic/hyperbrowser-mcp"],
      "env": {
        "HYPERBROWSER_API_KEY": "${HYPERBROWSER_API_KEY}"
      }
    }
  }
}
EOF
    # Replace the placeholder with actual env var
    sed -i '' "s/\${HYPERBROWSER_API_KEY}/$HYPERBROWSER_API_KEY/" "$MCP_FILE" 2>/dev/null || \
    sed -i "s/\${HYPERBROWSER_API_KEY}/$HYPERBROWSER_API_KEY/" "$MCP_FILE"
    echo "✅ Hyperbrowser MCP configured"
else
    echo "ℹ️  Set HYPERBROWSER_API_KEY env var to enable browser automation"
fi

# Create alias for Claude with common flags
SHELL_RC=""
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    # Check if alias already exists
    if ! grep -q "alias cc=" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Claude Code alias with auto-accept permissions" >> "$SHELL_RC"
        echo "alias cc='claude --dangerously-skip-permissions'" >> "$SHELL_RC"
        echo "✅ Added 'cc' alias to $SHELL_RC"
        echo "   Run 'source $SHELL_RC' or restart terminal to use"
    else
        echo "ℹ️  'cc' alias already exists in $SHELL_RC"
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Usage:"
echo "  cc              - Run Claude Code (skips permission prompts)"
echo "  claude          - Run Claude Code normally"
echo ""
echo "Permissions enabled for:"
echo "  • Git, GitHub CLI"
echo "  • Package managers (npm, yarn, pip, cargo, etc.)"
echo "  • File operations"
echo "  • Web fetching and searching"
echo "  • Hyperbrowser (if API key set)"
echo ""
