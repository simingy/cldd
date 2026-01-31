#!/bin/bash

# Chainlit Docked Docs (CLDD) Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/simingy/cldd/main/install.sh | bash

set -e

echo "📦 Installing Chainlit Docked Docs (CLDD)..."

# 1. Ensure absolute paths or project root
# We assume this is run from the project root.
if [ ! -f "chainlit.md" ] && [ ! -f ".chainlit/config.toml" ] && [ ! -f "app.py" ]; then
    echo "⚠️  Warning: Doesn't look like a Chainlit project root."
    echo "   (Checked for chainlit.md, .chainlit/config.toml, or app.py)"
    read -p "   Continue anyway? (y/N) " confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        exit 1
    fi
fi

# 2. Create public directory
mkdir -p public
echo "✅ Directory 'public/' prepared."

# 3. Download Assets
# Using main branch by default
BASE_URL="https://raw.githubusercontent.com/simingy/cldd/main/public"

echo "⬇️  Downloading custom.css..."
curl -fsSL "$BASE_URL/custom.css" -o public/custom.css

echo "⬇️  Downloading custom.js..."
curl -fsSL "$BASE_URL/custom.js" -o public/custom.js

echo "✅ Assets installed to public/custom.css and public/custom.js"

# 4. Config Check
CONFIG_FILE=".chainlit/config.toml"
NEEDS_CONFIG=true

if [ -f "$CONFIG_FILE" ]; then
    # Check if lines exist (simple grep)
    if grep -q 'custom_css = "/public/custom.css"' "$CONFIG_FILE" && grep -q 'custom_js = "/public/custom.js"' "$CONFIG_FILE"; then
        echo "✅ Configuration looks correct in $CONFIG_FILE"
        NEEDS_CONFIG=false
    fi
fi

if [ "$NEEDS_CONFIG" = true ]; then
    echo ""
    echo "⚠️  ACTION REQUIRED: Update your configuration"
    echo "   Edit $CONFIG_FILE and ensure [UI] section contains:"
    echo "   ------------------------------------------------"
    echo '   [UI]'
    echo '   custom_css = "/public/custom.css"'
    echo '   custom_js = "/public/custom.js"'
    echo "   ------------------------------------------------"
    if [ -f "$CONFIG_FILE" ]; then
        echo "   (File found, but lines seem missing or different)"
    else
        echo "   (File $CONFIG_FILE not found - run 'chainlit init' first)"
    fi
fi

echo ""
echo "🎉 CLDD Installation Complete!"
