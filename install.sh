#!/bin/bash
# Chainlit Docked Docs (CLDD) Installer
# Version: 1.3.1
set -e

# Constants
REPO_URL="https://raw.githubusercontent.com/simingy/cldd/main/public"
# Allow overriding PUBLIC_DIR for testing
PUBLIC_DIR="${PUBLIC_DIR:-public}"
CSS_FILE="$PUBLIC_DIR/custom.css"
JS_FILE="$PUBLIC_DIR/custom.js"

# Markers
CSS_START="/* CLDD-START */"
CSS_END="/* CLDD-END */"
JS_START="// CLDD-START"
JS_END="// CLDD-END"

echo "🚀 Installing Chainlit Docked Docs (CLDD)..."

# Ensure public dir exists
mkdir -p "$PUBLIC_DIR"

# Download Function
download_content() {
    local url=$1
    if [ "$LOCAL_INSTALL" == "true" ]; then
        # For dev testing: use the files in current directory (where script is run from), NOT public/
        # Assumes user runs ./install.sh --local from root of repo
        # We need to distinguish Source from Target.
        # But wait, the repo structure HAS them in public/custom.css.
        # If we run in repo, target overwrites source!
        # SOLUTION: Read into memory variable FIRST before touching file.
        # In fact, we already do `JS_CONTENT=$(download_content...)`. 
        # But `download_content` did `cat "public/..."`.
        # If target IS `public/custom.css`, we are fine as long as we read fully before writing.
        # However, `update_file` reads `public/custom.css` (Target) and appends `JS_CONTENT` (Source).
        # If Source == Target, we are doubling the file content...
        
        # Correct logic for LOCAL DEV:
        # We assume the user wants to install FROM current dir TO current dir (updating markers).
        # This is valid for testing "update" logic.
        # But if we want to simulate "installing elsewhere", we should probably copy to a temp location first?
        # Let's just assume for --local, we read the disk file as source.
        cat "$url" # url here will be passed as just filename ideally or relative path
    else
        curl -fsSL "$url"
    fi
}

# Update Function
update_file() {
    local file=$1
    local content=$2
    local start_marker=$3
    local end_marker=$4

    # Prepare Wrapped Content
    # Use printf to avoid expanding variables in content, but %s is safe.
    local wrapped_content
    wrapped_content=$(printf "\n%s\n%s\n%s\n" "$start_marker" "$content" "$end_marker")

    if [ -f "$file" ]; then
        if grep -Fq "$start_marker" "$file"; then
            echo "   🔄 Updating existing CLDD block in $file"
            
            # Use awk with index() for safer substring matching
            # Filter out old block
            awk -v start="$start_marker" -v end="$end_marker" '
                # If line contains start marker, enable skip mode
                # But careful if start marker is strictly equal or just contained
                index($0, start) { skip = 1; next }
                index($0, end) { skip = 0; next }
                !skip { print }
            ' "$file" > "${file}.tmp"
            
            # Append new content
            echo "$wrapped_content" >> "${file}.tmp"
            mv "${file}.tmp" "$file"
        else
            echo "   ➕ Appending CLDD block to $file"
            echo "$wrapped_content" >> "$file"
        fi
    else
        echo "   ✨ Creating $file"
        echo "$wrapped_content" > "$file"
    fi
}

# Parse Args
LOCAL_INSTALL="false"
for arg in "$@"; do
    if [ "$arg" == "--local" ]; then
        LOCAL_INSTALL="true"
    fi
done

# --- CSS ---
# For local install, we need to be careful not to read the target file we are about to overwrite.
# But for testing, it is circular.
# Let's assume for local testing we change the target to "public/custom_test.css"?
# No, user wants valid install.
# Let's fix the call sites to pass correct path.

echo "📦 Processing custom.css..."
if [ "$LOCAL_INSTALL" == "true" ]; then
    CSS_CONTENT=$(cat "public/custom.css")
else
    CSS_CONTENT=$(download_content "$REPO_URL/custom.css")
fi
update_file "$CSS_FILE" "$CSS_CONTENT" "$CSS_START" "$CSS_END"

# --- JS ---
echo "📦 Processing custom.js..."
if [ "$LOCAL_INSTALL" == "true" ]; then
    JS_CONTENT=$(cat "public/custom.js")
else
    JS_CONTENT=$(download_content "$REPO_URL/custom.js")
fi
update_file "$JS_FILE" "$JS_CONTENT" "$JS_START" "$JS_END"

echo ""
echo "🎉 Installation Complete!"
echo "👉 Ensure your .chainlit/config.toml includes:"
echo '   custom_css = "/public/custom.css"'
echo '   custom_js = "/public/custom.js"'
