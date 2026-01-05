#!/bin/bash
# Claude Code Full Setup Script
# One-time setup to start ripping immediately
#
# Installs:
# - cc alias (skip permission prompts)
# - All custom skills
# - Hooks system (skill activation, continuity, etc.)
# - MCP servers (task-master, hyperbrowser)
# - Settings with expanded permissions
# - Plugins (swift-lsp, ralph-wiggum)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 Claude Code Full Setup"
echo "========================="
echo ""

# Create directories
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/cache/hyperdocs"

# ============================================
# 1. Install cc alias
# ============================================
echo "📝 Setting up 'cc' alias..."

SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q "alias cc=" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Claude Code alias - skip permission prompts" >> "$SHELL_RC"
        echo "alias cc='claude --dangerously-skip-permissions'" >> "$SHELL_RC"
        echo "   ✅ Added 'cc' alias to $SHELL_RC"
    else
        echo "   ℹ️  'cc' alias already exists"
    fi
fi

# ============================================
# 2. Install skills
# ============================================
echo ""
echo "📦 Installing skills..."

if [ -d "$REPO_DIR/skills" ]; then
    for skill in "$REPO_DIR/skills"/*.md; do
        if [ -f "$skill" ]; then
            cp "$skill" "$CLAUDE_DIR/commands/"
            echo "   ✅ $(basename "$skill")"
        fi
    done
else
    echo "   ⚠️  Skills directory not found - run from repo root"
fi

# ============================================
# 3. Install hooks
# ============================================
echo ""
echo "🪝 Installing hooks..."

if [ -d "$REPO_DIR/hooks" ]; then
    # Copy entire hooks directory
    cp -r "$REPO_DIR/hooks/"* "$CLAUDE_DIR/hooks/"

    # Make shell scripts executable
    chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true

    echo "   ✅ Hooks installed to ~/.claude/hooks/"
    echo "   ✅ Shell scripts made executable"
else
    echo "   ⚠️  Hooks directory not found"
fi

# ============================================
# 4. Install settings
# ============================================
echo ""
echo "⚙️  Configuring settings..."

SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
    echo "   ⚠️  Existing settings found - creating backup"
    cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup.$(date +%Y%m%d%H%M%S)"
fi

if [ -f "$REPO_DIR/templates/settings.json" ]; then
    cp "$REPO_DIR/templates/settings.json" "$SETTINGS_FILE"
    echo "   ✅ Settings installed with:"
    echo "      • Expanded permissions (git, npm, etc.)"
    echo "      • Plugins enabled (swift-lsp, ralph-wiggum)"
    echo "      • Hooks configured"
else
    echo "   ⚠️  Settings template not found"
fi

# ============================================
# 5. Install MCP config
# ============================================
echo ""
echo "🔌 Configuring MCP servers..."

MCP_FILE="$HOME/.mcp.json"

if [ -f "$MCP_FILE" ]; then
    echo "   ℹ️  Existing MCP config found at $MCP_FILE"
    echo "   📋 Template available at: $REPO_DIR/mcp-configs/mcp.json"
    echo "   💡 Merge manually if needed"
else
    if [ -f "$REPO_DIR/mcp-configs/mcp.json" ]; then
        cp "$REPO_DIR/mcp-configs/mcp.json" "$MCP_FILE"
        echo "   ✅ MCP config installed"
        echo "   ⚠️  Update API keys in ~/.mcp.json"
    fi
fi

# ============================================
# 6. Summary
# ============================================
echo ""
echo "================================"
echo "🎉 Setup Complete!"
echo "================================"
echo ""
echo "Installed:"
echo "  • cc alias (run 'source $SHELL_RC' to activate)"
echo "  • Skills: /api-docs and more"
echo "  • Hooks: skill-activation, continuity, etc."
echo "  • Settings: permissions, plugins, hooks"
echo "  • MCP: hyperbrowser (browser automation)"
echo ""
echo "Next steps:"
echo "  1. source $SHELL_RC   # Activate cc alias"
echo "  2. Edit ~/.mcp.json   # Add your API keys"
echo "  3. cc                 # Start Claude Code"
echo ""
echo "Available skills:"
for skill in "$CLAUDE_DIR/commands"/*.md; do
    if [ -f "$skill" ]; then
        name=$(basename "$skill" .md)
        echo "  • /$name"
    fi
done
echo ""
