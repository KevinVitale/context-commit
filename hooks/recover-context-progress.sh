#!/bin/bash
# Recovery script for context-progress branch
# Restores from backup tags if accidentally destroyed

set -e

echo "🔍 Searching for context-progress backup tags..."
echo ""

# Find all backup tags
BACKUPS=$(git tag -l "context-progress-backup-*" | sort -r)

if [ -z "$BACKUPS" ]; then
    echo "❌ No backup tags found"
    echo ""
    echo "   Backup tags are created automatically by:"
    echo "   - pre-commit hook (before any commit on context-progress)"
    echo "   - safe-context-update.sh script"
    echo ""
    echo "   If you've never committed on context-progress, no backups exist."
    exit 1
fi

echo "📦 Available backups:"
echo ""

# Display backups with dates
COUNT=1
declare -a TAG_ARRAY
while IFS= read -r tag; do
    TAG_ARRAY[$COUNT]="$tag"
    COMMIT_DATE=$(git log -1 --format="%ai" "$tag" 2>/dev/null)
    COMMIT_MSG=$(git log -1 --format="%s" "$tag" 2>/dev/null | head -1)
    echo "  $COUNT. $tag"
    echo "     Date: $COMMIT_DATE"
    echo "     Message: $COMMIT_MSG"
    echo ""
    COUNT=$((COUNT + 1))
done <<< "$BACKUPS"

echo "Select a backup to restore (1-$((COUNT-1))), or 0 to cancel:"
read -r SELECTION

if [ "$SELECTION" = "0" ]; then
    echo "❌ Cancelled"
    exit 0
fi

if [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -ge "$COUNT" ]; then
    echo "❌ Invalid selection"
    exit 1
fi

SELECTED_TAG="${TAG_ARRAY[$SELECTION]}"

echo ""
echo "⚠️  This will restore context-progress to: $SELECTED_TAG"
echo "   Current context-progress will be backed up first."
echo ""
echo "Continue? (y/N):"
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "❌ Cancelled"
    exit 0
fi

# Backup current state if context-progress exists
if git rev-parse --verify context-progress >/dev/null 2>&1; then
    CURRENT_BACKUP="context-progress-backup-before-restore-$(date +%Y%m%d-%H%M%S)"
    git tag "$CURRENT_BACKUP" context-progress
    echo "✅ Current state backed up to: $CURRENT_BACKUP"
fi

# Restore from backup tag
git branch -f context-progress "$SELECTED_TAG"

echo ""
echo "✅ context-progress restored from $SELECTED_TAG"
echo ""
echo "📋 Next steps:"
echo "   1. Verify the restored commit:"
echo "      git show context-progress"
echo ""
echo "   2. If correct, you may want to clean up old backups:"
echo "      git tag -d context-progress-backup-*"
echo ""
echo "   3. Force push if needed:"
echo "      git push origin context-progress --force"
