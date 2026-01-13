#!/bin/bash
# Safe wrapper for updating context-progress branch
# Prevents accidental data loss

set -e

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Ensure we're on master
if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "❌ Must be on master branch to update context-progress"
    echo "   Current branch: $CURRENT_BRANCH"
    echo ""
    echo "   Run: git checkout master"
    exit 1
fi

# Ensure master is clean
if ! git diff-index --quiet HEAD --; then
    echo "❌ Working directory has uncommitted changes"
    echo "   Commit or stash changes before updating context-progress"
    exit 1
fi

echo "🔄 Updating context-progress branch..."
echo ""

# Create backup tag before any operations
BACKUP_TAG="context-progress-backup-$(date +%Y%m%d-%H%M%S)"
git tag "$BACKUP_TAG" context-progress 2>/dev/null || true
echo "✅ Created backup tag: $BACKUP_TAG"

# Switch to context-progress
git checkout context-progress

# Rebase onto master (safe - preserves progress commit)
echo "📝 Rebasing context-progress onto master..."
if ! git rebase master; then
    echo ""
    echo "❌ Rebase failed!"
    echo "   Aborting rebase and returning to master..."
    git rebase --abort
    git checkout master
    exit 1
fi

echo ""
echo "✅ context-progress successfully updated"
echo ""
echo "📋 Next steps:"
echo "   1. Edit the commit message to update progress:"
echo "      git commit --amend"
echo ""
echo "   2. Return to master:"
echo "      git checkout master"
echo ""
echo "💡 Backup tag available: $BACKUP_TAG"
echo "   (Delete old backups with: git tag -d context-progress-backup-*)"
