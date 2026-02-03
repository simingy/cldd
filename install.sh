#!/bin/bash
# Chainlit Docked Docs (CLDD) Installer
# Version: 1.3.2
set -e

# Constants
REPO_URL="https://raw.githubusercontent.com/simingy/cldd/main/public"
DEFAULT_PUBLIC_DIR="public"

# Markers
CSS_START="/* CLDD-START */"
CSS_END="/* CLDD-END */"
JS_START="// CLDD-START"
JS_END="// CLDD-END"

# State
TEMP_FILES=()

# --- Functions ---

cleanup() {
    for tmp in "${TEMP_FILES[@]}"; do
        rm -f "$tmp"
    done
}
trap cleanup EXIT INT TERM

fetch_content() {
    local filename=$1
    if [ "$LOCAL_INSTALL" == "true" ]; then
        # In local dev mode, we read from the current directory (source repo)
        # We assume the script is run from the repo root
        if [ ! -f "public/$filename" ]; then
             echo "❌ Error: Source file 'public/$filename' not found in local repo." >&2
             exit 1
        fi
        cat "public/$filename"
    else
        # Remote mode
        local content
        # Capture stderr to suppress curl progress
        if ! content=$(curl -fsSL "$REPO_URL/$filename"); then
             echo "❌ Error: Failed to download $filename from $REPO_URL/$filename" >&2
             exit 1
        fi
        echo "$content"
    fi
}

install_asset() {
    local filename=$1
    local content=$2
    local start_marker=$3
    local end_marker=$4
    local target_path="$PUBLIC_DIR/$filename"

    echo "📦 Processing $filename..."
    
    # Create wrapped content block
    local wrapped_content
    wrapped_content=$(printf "\n%s\n%s\n%s\n" "$start_marker" "$content" "$end_marker")
    
    local temp_file="${target_path}.tmp"
    TEMP_FILES+=("$temp_file")

    if [ -f "$target_path" ]; then
        if grep -Fq "$start_marker" "$target_path"; then
            echo "   🔄 Updating existing CLDD block in $target_path"
            # Filter out old block using awk
            # atomic write to temp file
            awk -v start="$start_marker" -v end="$end_marker" '
                index($0, start) { skip = 1; next }
                index($0, end) { skip = 0; next }
                !skip { print }
            ' "$target_path" > "$temp_file"
            
            # Append new block
            echo "$wrapped_content" >> "$temp_file"
        else
            echo "   ➕ Appending CLDD block to $target_path"
            cp "$target_path" "$temp_file"
            echo "$wrapped_content" >> "$temp_file"
        fi
    else
        echo "   ✨ Creating $target_path"
        echo "$wrapped_content" > "$temp_file"
    fi

    # Atomic Move
    mv "$temp_file" "$target_path"
}

# --- Main ---

# Parse Args
LOCAL_INSTALL="false"
PUBLIC_DIR="$DEFAULT_PUBLIC_DIR"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --local) LOCAL_INSTALL="true" ;;
        --dir) PUBLIC_DIR="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "🚀 Installing Chainlit Docked Docs (CLDD)..."
echo "   📂 Target Directory: $PUBLIC_DIR"

# Ensure public dir exists calls are atomic enough (mkdir -p)
if ! mkdir -p "$PUBLIC_DIR"; then
    echo "❌ Error: Could not create directory $PUBLIC_DIR" >&2
    exit 1
fi

# Fetch and Install CSS
CSS_CONTENT=$(fetch_content "custom.css")
install_asset "custom.css" "$CSS_CONTENT" "$CSS_START" "$CSS_END"

# Fetch and Install JS
JS_CONTENT=$(fetch_content "custom.js")
install_asset "custom.js" "$JS_CONTENT" "$JS_START" "$JS_END"

echo ""
echo "🎉 Installation Complete!"
echo "👉 Ensure your .chainlit/config.toml includes:"
echo "   custom_css = \"/$PUBLIC_DIR/custom.css\""
echo "   custom_js = \"/$PUBLIC_DIR/custom.js\""
