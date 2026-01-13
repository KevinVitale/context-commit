#!/bin/bash
# [CONTEXT] Git Hooks Installation Script
# Run this script to install the project's git hooks

HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
GIT_HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

echo "Installing [CONTEXT] git hooks..."
echo ""

# Create symlinks for each hook
for hook in pre-commit commit-msg post-commit prepare-commit-msg pre-push; do
    if [ -f "$HOOKS_DIR/$hook" ]; then
        # Remove existing hook if it exists
        if [ -e "$GIT_HOOKS_DIR/$hook" ]; then
            echo "  Removing existing $hook hook"
            rm "$GIT_HOOKS_DIR/$hook"
        fi

        # Create symlink
        ln -s "$HOOKS_DIR/$hook" "$GIT_HOOKS_DIR/$hook"
        echo "  ✓ Installed $hook"
    fi
done

# Copy the helper script (not a hook itself)
if [ -f "$HOOKS_DIR/generate-progress-html.sh" ]; then
    cp "$HOOKS_DIR/generate-progress-html.sh" "$GIT_HOOKS_DIR/generate-progress-html.sh"
    chmod +x "$GIT_HOOKS_DIR/generate-progress-html.sh"
    echo "  ✓ Installed generate-progress-html.sh"
fi

echo ""
echo "✅ Git hooks installed successfully!"
echo ""
echo "Hooks enforce:"
echo "  - All tests must pass before commits (pre-commit)"
echo "  - context-progress must stay synchronized before commits (pre-commit)"
echo "  - context-progress must stay synchronized before pushes (pre-push)"
echo "  - [CONTEXT] commits must be detailed (5+ lines) (commit-msg)"
echo "  - Auto-generation of progress.html from context-progress (post-commit)"
echo ""
