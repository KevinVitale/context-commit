#!/bin/bash
# Capture session state for resumable [CONTEXT] workflow
# Auto-captures git state with optional interactive mode

set -e

# Configuration
INTERACTIVE_MODE="${CONTEXT_SESSION_PROMPT:-0}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# Check if context-progress exists
if ! git rev-parse --verify context-progress >/dev/null 2>&1; then
    echo "⚠️  context-progress branch does not exist. Skipping session capture."
    exit 0
fi

# Auto-capture git state
echo "📸 Capturing session state..."

# Get the commit message being made (from staged commit)
COMMIT_MSG_FILE=".git/COMMIT_EDITMSG"
LATEST_COMMIT_MSG=""
if [ -f "$COMMIT_MSG_FILE" ]; then
    LATEST_COMMIT_MSG=$(head -n 1 "$COMMIT_MSG_FILE")
fi

# Get files that will be in this commit
STAGED_FILES=$(git diff --cached --name-only | head -10)
if [ -z "$STAGED_FILES" ]; then
    STAGED_FILES="(no files staged)"
fi

# Get recent commits (last 3)
RECENT_COMMITS=$(git log --oneline -3 --format="- %s (commit: %h)" 2>/dev/null || echo "- Initial commit")

# Interactive mode: prompt for additional context
NEXT_STEPS=""
BLOCKERS=""
ACCOMPLISHMENTS=""

if [ "$INTERACTIVE_MODE" = "1" ]; then
    echo ""
    echo "📝 Session Capture (Interactive Mode)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Accomplishments
    echo "What did you accomplish this session?"
    echo "(Press Enter to use commit message: \"$LATEST_COMMIT_MSG\")"
    read -r input
    if [ -n "$input" ]; then
        ACCOMPLISHMENTS="$input"
    else
        ACCOMPLISHMENTS="$LATEST_COMMIT_MSG"
    fi

    # Next steps
    echo ""
    echo "Next steps? (Press Enter to skip)"
    read -r NEXT_STEPS

    # Blockers
    echo ""
    echo "Any blockers or questions? (Press Enter to skip)"
    read -r BLOCKERS

    echo ""
fi

# Checkout context-progress and rebase
echo "🔄 Updating context-progress branch..."
ORIGINAL_BRANCH="$CURRENT_BRANCH"
git checkout context-progress -q

# Rebase onto the branch we came from
if ! git rebase "$ORIGINAL_BRANCH" -q; then
    echo "❌ Failed to rebase context-progress. Resolve conflicts manually."
    exit 1
fi

# Read existing progress commit
EXISTING_COMMIT=$(git log -1 --format=%B)

# Extract existing sections (preserve Completed, In Progress, Planned sections)
COMPLETED_SECTION=""
IN_PROGRESS_SECTION=""
PLANNED_SECTION=""

# Simple extraction - look for major sections
if echo "$EXISTING_COMMIT" | grep -q "## Completed"; then
    COMPLETED_SECTION=$(echo "$EXISTING_COMMIT" | sed -n '/## Completed/,/^##/p' | sed '$d')
fi

if echo "$EXISTING_COMMIT" | grep -q "## In Progress"; then
    IN_PROGRESS_SECTION=$(echo "$EXISTING_COMMIT" | sed -n '/## In Progress/,/^##/p' | sed '$d')
fi

if echo "$EXISTING_COMMIT" | grep -q "## Planned"; then
    PLANNED_SECTION=$(echo "$EXISTING_COMMIT" | sed -n '/## Planned/,/^##/p' | sed '$d')
fi

# If sections are empty, use defaults
if [ -z "$COMPLETED_SECTION" ]; then
    COMPLETED_SECTION="## Completed ✓
- [x] Initial setup"
fi

if [ -z "$IN_PROGRESS_SECTION" ]; then
    IN_PROGRESS_SECTION="## In Progress
- [ ] Current work"
fi

if [ -z "$PLANNED_SECTION" ]; then
    PLANNED_SECTION="## Planned
- [ ] Future items"
fi

# Build new Current Session section
SESSION_SECTION="## Current Session ($TIMESTAMP)"

if [ -n "$LATEST_COMMIT_MSG" ]; then
    SESSION_SECTION="$SESSION_SECTION
**Latest Commit:** $LATEST_COMMIT_MSG"
fi

SESSION_SECTION="$SESSION_SECTION
**Files Modified:**
$(echo "$STAGED_FILES" | sed 's/^/  - /')"

if [ "$INTERACTIVE_MODE" = "1" ] && [ -n "$ACCOMPLISHMENTS" ]; then
    SESSION_SECTION="$SESSION_SECTION

**This Session:**
- $ACCOMPLISHMENTS"
else
    SESSION_SECTION="$SESSION_SECTION

**Recent Work:**
$RECENT_COMMITS"
fi

if [ -n "$NEXT_STEPS" ]; then
    SESSION_SECTION="$SESSION_SECTION

**Next Steps:**
- $NEXT_STEPS"
fi

if [ -n "$BLOCKERS" ]; then
    SESSION_SECTION="$SESSION_SECTION

**Questions/Blockers:**
- $BLOCKERS"
fi

# Build complete commit message
NEW_COMMIT_MSG="[CONTEXT] Project Progress

$SESSION_SECTION

---

$COMPLETED_SECTION

$IN_PROGRESS_SECTION

$PLANNED_SECTION"

# Amend the commit with new session info
git commit --amend -m "$NEW_COMMIT_MSG" --no-verify -q

echo "✅ Session captured in context-progress"

# Return to original branch
git checkout "$ORIGINAL_BRANCH" -q

# Verify synchronization
BEHIND=$(git rev-list context-progress.."$ORIGINAL_BRANCH" --count 2>/dev/null)
if [ "$BEHIND" -eq 0 ]; then
    echo "✅ context-progress is synchronized"
else
    echo "⚠️  Warning: context-progress still behind by $BEHIND commits"
fi

exit 0
