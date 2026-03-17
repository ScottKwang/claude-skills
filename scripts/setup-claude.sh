#!/bin/bash
# Claude Code Full Setup Script
# One-time setup to start ripping immediately
#
# Usage:
#   ./setup-claude.sh              # Interactive — prompts for global or project
#   ./setup-claude.sh --global     # Install to ~/.claude/ (all projects)
#   ./setup-claude.sh --project .  # Install to specific project directory
#
# Installs:
# - cc alias (skip permission prompts)
# - All custom skills
# - Hooks system (skill activation, continuity, etc.)
# - MCP servers (playwright, xcodebuildmcp)
# - Settings with expanded permissions
# - Plugins (swift-lsp, ralph-wiggum)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# ============================================
# Parse arguments
# ============================================
INSTALL_MODE=""
PROJECT_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)
            INSTALL_MODE="global"
            shift
            ;;
        --project)
            INSTALL_MODE="project"
            PROJECT_DIR="$(cd "$2" && pwd)"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--global | --project <path>]"
            exit 1
            ;;
    esac
done

echo "🚀 Claude Code Full Setup"
echo "========================="
echo ""

# ============================================
# 0. Check & install dependencies
# ============================================
echo "🔍 Checking dependencies..."

HAS_BREW=false
if command -v brew &>/dev/null; then
    HAS_BREW=true
fi

install_dep() {
    local name="$1"
    local check_cmd="$2"
    local brew_pkg="$3"

    if command -v "$check_cmd" &>/dev/null; then
        echo "   ✅ $name"
    elif $HAS_BREW; then
        echo "   📦 Installing $name..."
        brew install "$brew_pkg"
        echo "   ✅ $name installed"
    else
        echo "   ❌ $name not found — install manually: brew install $brew_pkg"
        MISSING_DEPS=true
    fi
}

MISSING_DEPS=false
install_dep "Node.js" "node" "node"
install_dep "git" "git" "git"
install_dep "GitHub CLI (gh)" "gh" "gh"
install_dep "jq" "jq" "jq"

if $MISSING_DEPS; then
    echo ""
    echo "   ⚠️  Some dependencies are missing. Install Homebrew first:"
    echo "      /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "   Then re-run this script."
    exit 1
fi

# Check gh authentication
if command -v gh &>/dev/null; then
    if ! gh auth status &>/dev/null; then
        echo ""
        echo "   ⚠️  GitHub CLI is not authenticated."
        echo "   Run: gh auth login"
        echo ""
    fi
fi

# ============================================
# Prompt for install mode if not specified
# ============================================
if [ -z "$INSTALL_MODE" ]; then
    echo ""
    echo "Where would you like to install?"
    echo "  1) Global (~/.claude/) — applies to all projects"
    echo "  2) Project directory — scoped to a specific project"
    echo ""
    read -p "Choose [1/2]: " choice
    case "$choice" in
        2)
            INSTALL_MODE="project"
            read -p "Project path (or . for current directory): " proj_path
            PROJECT_DIR="$(cd "$proj_path" && pwd)"
            ;;
        *)
            INSTALL_MODE="global"
            ;;
    esac
fi

# Set install directories based on mode
if [ "$INSTALL_MODE" = "project" ]; then
    INSTALL_DIR="$PROJECT_DIR/.claude"
    MCP_FILE="$PROJECT_DIR/.mcp.json"
    echo ""
    echo "📁 Installing to project: $PROJECT_DIR"
else
    INSTALL_DIR="$HOME/.claude"
    MCP_FILE="$HOME/.mcp.json"
    echo ""
    echo "📁 Installing globally to: ~/.claude/"
fi

# Create directories
mkdir -p "$INSTALL_DIR/commands"
mkdir -p "$INSTALL_DIR/hooks"
mkdir -p "$INSTALL_DIR/cache/hyperdocs"

# ============================================
# 1. Install cc alias (always global)
# ============================================
echo ""
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
        echo "# Claude Code aliases" >> "$SHELL_RC"
        echo "alias cc='claude --dangerously-skip-permissions'" >> "$SHELL_RC"
        echo "alias ccr='claude --dangerously-skip-permissions --resume'" >> "$SHELL_RC"
        echo "   ✅ Added 'cc' alias (skip permissions)"
        echo "   ✅ Added 'ccr' alias (skip permissions + resume)"
    else
        # Check if ccr exists, add if not
        if ! grep -q "alias ccr=" "$SHELL_RC" 2>/dev/null; then
            echo "alias ccr='claude --dangerously-skip-permissions --resume'" >> "$SHELL_RC"
            echo "   ✅ Added 'ccr' alias (skip permissions + resume)"
        fi
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
            cp "$skill" "$INSTALL_DIR/commands/"
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
    cp -r "$REPO_DIR/hooks/"* "$INSTALL_DIR/hooks/"

    # Make shell scripts executable
    chmod +x "$INSTALL_DIR/hooks/"*.sh 2>/dev/null || true

    echo "   ✅ Hooks installed to $INSTALL_DIR/hooks/"
    echo "   ✅ Shell scripts made executable"
else
    echo "   ⚠️  Hooks directory not found"
fi

# ============================================
# 4. Install agents
# ============================================
echo ""
echo "🤖 Installing agents..."

mkdir -p "$INSTALL_DIR/agents"

if [ -d "$REPO_DIR/agents" ]; then
    for agent in "$REPO_DIR/agents"/*.md; do
        if [ -f "$agent" ]; then
            cp "$agent" "$INSTALL_DIR/agents/"
            echo "   ✅ $(basename "$agent")"
        fi
    done
else
    echo "   ⚠️  Agents directory not found"
fi

# ============================================
# 5. Install settings
# ============================================
echo ""
echo "⚙️  Configuring settings..."

SETTINGS_FILE="$INSTALL_DIR/settings.json"

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
# 6. Install MCP config
# ============================================
echo ""
echo "🔌 Configuring MCP servers..."

if [ -f "$MCP_FILE" ]; then
    echo "   ℹ️  Existing MCP config found at $MCP_FILE"
    echo "   📋 Template available at: $REPO_DIR/mcp-configs/mcp.json"
    echo "   💡 Merge manually if needed"
else
    if [ -f "$REPO_DIR/mcp-configs/mcp.json" ]; then
        cp "$REPO_DIR/mcp-configs/mcp.json" "$MCP_FILE"
        echo "   ✅ MCP config installed (no API keys needed)"
    fi
fi

# ============================================
# 7. Summary
# ============================================
echo ""
echo "================================"
echo "🎉 Setup Complete!"
echo "================================"
echo ""
if [ "$INSTALL_MODE" = "project" ]; then
    echo "Installed to: $PROJECT_DIR/.claude/"
else
    echo "Installed to: ~/.claude/ (global)"
fi
echo ""
echo "Installed:"
echo "  • cc alias (run 'source $SHELL_RC' to activate)"
echo "  • Skills: /api-docs, /github-search, and more"
echo "  • Agents: codebase-analyzer, codebase-locator, etc."
echo "  • Hooks: skill-activation, continuity, etc."
echo "  • Settings: permissions, plugins, hooks"
echo "  • MCP: playwright (browser automation)"
echo ""
echo "Next steps:"
echo "  1. source $SHELL_RC   # Activate cc alias"
echo "  2. cc                 # Start Claude Code"
echo ""
echo "Available skills:"
for skill in "$INSTALL_DIR/commands"/*.md; do
    if [ -f "$skill" ]; then
        name=$(basename "$skill" .md)
        echo "  • /$name"
    fi
done
echo ""
