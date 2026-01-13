#!/bin/bash
# Auto-extract progress from git history
# Generates structured progress content inspired by /compact's extraction patterns

set -e

# Configuration
MAIN_BRANCH="${CONTEXT_MAIN_BRANCH:-master}"
PROGRESS_BRANCH="context-progress"
OUTPUT_FORMAT="${1:-markdown}"  # markdown or json

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if context-progress exists
if ! git rev-parse --verify "$PROGRESS_BRANCH" >/dev/null 2>&1; then
    echo -e "${RED}Error: $PROGRESS_BRANCH branch does not exist${NC}" >&2
    exit 1
fi

# Get the base commit (where context-progress diverged from main)
get_base_commit() {
    git merge-base "$MAIN_BRANCH" "$PROGRESS_BRANCH" 2>/dev/null || echo ""
}

# Get commits since last progress update
get_new_commits() {
    local base_commit
    base_commit=$(get_base_commit)

    if [ -z "$base_commit" ]; then
        git log "$MAIN_BRANCH" --oneline -20
    else
        git log "$base_commit".."$MAIN_BRANCH" --oneline
    fi
}

# Categorize a commit by its message
categorize_commit() {
    local msg="$1"
    local msg_lower
    msg_lower=$(echo "$msg" | tr '[:upper:]' '[:lower:]')

    # Priority order matters - check most specific first
    if echo "$msg_lower" | grep -qE '\[context\]|context-progress'; then
        echo "context"
    elif echo "$msg_lower" | grep -qE '^fix|bug|resolve|patch|hotfix'; then
        echo "fix"
    elif echo "$msg_lower" | grep -qE '^test|add.*test|spec|coverage'; then
        echo "test"
    elif echo "$msg_lower" | grep -qE '^refactor|cleanup|reorganize|restructure'; then
        echo "refactor"
    elif echo "$msg_lower" | grep -qE '^doc|readme|comment|changelog'; then
        echo "docs"
    elif echo "$msg_lower" | grep -qE '^add|implement|create|new|feature|enhance'; then
        echo "feature"
    elif echo "$msg_lower" | grep -qE '^update|improve|modify|change|adjust'; then
        echo "update"
    elif echo "$msg_lower" | grep -qE '^remove|delete|deprecate'; then
        echo "remove"
    else
        echo "other"
    fi
}

# Extract file changes with stats
get_file_changes() {
    local base_commit
    base_commit=$(get_base_commit)

    if [ -z "$base_commit" ]; then
        git diff --stat HEAD~10..HEAD 2>/dev/null | head -20
    else
        git diff --stat "$base_commit".."$MAIN_BRANCH" 2>/dev/null | head -30
    fi
}

# Get detailed file change list
get_file_list() {
    local base_commit
    base_commit=$(get_base_commit)

    if [ -z "$base_commit" ]; then
        git diff --name-status HEAD~10..HEAD 2>/dev/null
    else
        git diff --name-status "$base_commit".."$MAIN_BRANCH" 2>/dev/null
    fi
}

# Extract issues/fixes from commit messages
extract_issues_resolved() {
    local commits
    commits=$(get_new_commits)

    echo "$commits" | while read -r line; do
        local hash msg
        hash=$(echo "$line" | cut -d' ' -f1)
        msg=$(echo "$line" | cut -d' ' -f2-)

        # Look for fix-related commits
        if echo "$msg" | grep -qiE 'fix|resolve|patch|bug|issue|error'; then
            echo "- [$hash] $msg"
        fi
    done
}

# Extract key code references from recent diffs
extract_key_references() {
    local base_commit
    base_commit=$(get_base_commit)

    if [ -z "$base_commit" ]; then
        return
    fi

    # Find files with significant changes (functions/classes added)
    git diff "$base_commit".."$MAIN_BRANCH" --unified=0 2>/dev/null | \
        grep -E '^\+\+\+|^\+.*(func |class |struct |enum |protocol )' | \
        head -20 | while read -r line; do
            if [[ "$line" == "+++"* ]]; then
                current_file="${line#+++\ }"
                current_file="${current_file#b/}"
            elif [[ -n "$current_file" ]]; then
                # Extract function/class name
                name=$(echo "$line" | grep -oE '(func|class|struct|enum|protocol) [a-zA-Z_][a-zA-Z0-9_]*' | head -1)
                if [ -n "$name" ]; then
                    echo "- $current_file: $name"
                fi
            fi
        done
}

# Build categorized commit sections
# Outputs: category|[hash] message (one per line)
# Compatible with bash 3.x (no associative arrays)
build_commit_sections() {
    local commits
    commits=$(get_new_commits)

    # Categorize each commit and output as category|message
    echo "$commits" | while read -r line; do
        if [ -z "$line" ]; then continue; fi

        local hash msg category
        hash=$(echo "$line" | cut -d' ' -f1)
        msg=$(echo "$line" | cut -d' ' -f2-)
        category=$(categorize_commit "$msg")

        echo "$category|[$hash] $msg"
    done
}

# Generate markdown output
generate_markdown() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M")

    echo "[CONTEXT] Project Progress"
    echo ""
    echo "Auto-extracted progress as of $timestamp"
    echo ""

    # Recent Commits Section (categorized)
    echo "## Recent Commits"
    echo ""

    local commits_data
    commits_data=$(build_commit_sections)

    # Group by category
    local features fixes tests refactors updates others
    features=$(echo "$commits_data" | grep "^feature|" | cut -d'|' -f2)
    fixes=$(echo "$commits_data" | grep "^fix|" | cut -d'|' -f2)
    tests=$(echo "$commits_data" | grep "^test|" | cut -d'|' -f2)
    refactors=$(echo "$commits_data" | grep "^refactor|" | cut -d'|' -f2)
    updates=$(echo "$commits_data" | grep "^update|" | cut -d'|' -f2)
    others=$(echo "$commits_data" | grep -E "^(other|docs|remove|context)\|" | cut -d'|' -f2)

    if [ -n "$features" ]; then
        echo "### Features"
        echo "$features" | sed 's/^/- [x] /'
        echo ""
    fi

    if [ -n "$fixes" ]; then
        echo "### Fixes"
        echo "$fixes" | sed 's/^/- [x] /'
        echo ""
    fi

    if [ -n "$tests" ]; then
        echo "### Tests"
        echo "$tests" | sed 's/^/- [x] /'
        echo ""
    fi

    if [ -n "$refactors" ]; then
        echo "### Refactoring"
        echo "$refactors" | sed 's/^/- [x] /'
        echo ""
    fi

    if [ -n "$updates" ]; then
        echo "### Updates"
        echo "$updates" | sed 's/^/- [x] /'
        echo ""
    fi

    if [ -n "$others" ]; then
        echo "### Other"
        echo "$others" | sed 's/^/- [x] /'
        echo ""
    fi

    # File Changes Section
    echo "## File Changes"
    echo ""
    echo "\`\`\`"
    get_file_list | head -20
    echo "\`\`\`"
    echo ""

    # Issues Resolved Section
    local issues
    issues=$(extract_issues_resolved)
    if [ -n "$issues" ]; then
        echo "## Issues Resolved"
        echo ""
        echo "$issues"
        echo ""
    fi

    # Key References Section
    local refs
    refs=$(extract_key_references)
    if [ -n "$refs" ]; then
        echo "## Key Code References"
        echo ""
        echo "$refs"
        echo ""
    fi

    # Placeholder sections for manual editing
    echo "## In Progress"
    echo ""
    echo "- [ ] (add current work here)"
    echo ""
    echo "## Planned"
    echo ""
    echo "- [ ] (add planned items here)"
    echo ""
    echo "---"
    echo "Auto-extracted by context-commit. Review and edit before committing."
}

# Generate JSON output (for programmatic use)
generate_json() {
    local commits_json file_changes_json issues_json refs_json

    # Build commits JSON
    commits_json="["
    local first=true
    get_new_commits | while read -r line; do
        if [ -z "$line" ]; then continue; fi

        local hash msg category
        hash=$(echo "$line" | cut -d' ' -f1)
        msg=$(echo "$line" | cut -d' ' -f2- | sed 's/"/\\"/g')
        category=$(categorize_commit "$msg")

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        echo "    {\"hash\": \"$hash\", \"message\": \"$msg\", \"category\": \"$category\"}"
    done
    commits_json="$commits_json]"

    cat <<EOF
{
  "extracted_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "main_branch": "$MAIN_BRANCH",
  "commits": $commits_json,
  "file_count": $(get_file_list | wc -l | tr -d ' '),
  "issues_resolved": $(extract_issues_resolved | wc -l | tr -d ' ')
}
EOF
}

# Main execution
case "$OUTPUT_FORMAT" in
    json)
        generate_json
        ;;
    markdown|md|*)
        generate_markdown
        ;;
esac
