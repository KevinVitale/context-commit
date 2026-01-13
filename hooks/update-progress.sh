#!/bin/bash
# Update context-progress with auto-extracted content
# Combines auto-extraction (inspired by /compact) with safe git workflow

set -e

# Configuration
MAIN_BRANCH="${CONTEXT_MAIN_BRANCH:-master}"
PROGRESS_BRANCH="context-progress"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTO_EXTRACT="$SCRIPT_DIR/auto-extract-progress.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Flags
SKIP_EDIT="${CONTEXT_SKIP_EDIT:-0}"
PREVIEW_ONLY="${1:-}"
MERGE_MODE="${CONTEXT_MERGE_MODE:-smart}"  # smart, replace, append

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}=== Context Progress Auto-Update ===${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}>>>${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[X]${NC} $1" >&2
}

# Check prerequisites
check_prerequisites() {
    # Check we're in a git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi

    # Check context-progress exists
    if ! git rev-parse --verify "$PROGRESS_BRANCH" >/dev/null 2>&1; then
        print_error "$PROGRESS_BRANCH branch does not exist"
        echo ""
        echo "Initialize with: /context-init"
        exit 1
    fi

    # Check auto-extract script exists
    if [ ! -x "$AUTO_EXTRACT" ]; then
        print_error "Auto-extract script not found: $AUTO_EXTRACT"
        exit 1
    fi
}

# Get existing progress content
get_existing_progress() {
    git log "$PROGRESS_BRANCH" -1 --format=%B 2>/dev/null || echo ""
}

# Extract a section from existing progress
extract_section() {
    local content="$1"
    local section="$2"

    echo "$content" | awk -v section="$section" '
        $0 ~ "^## " section { found=1; next }
        found && /^## / { found=0 }
        found { print }
    '
}

# Smart merge: preserve manual edits while adding new auto-extracted content
smart_merge() {
    local auto_content="$1"
    local existing_content="$2"

    # Extract sections from existing content worth preserving
    local existing_in_progress existing_planned existing_notes
    existing_in_progress=$(extract_section "$existing_content" "In Progress")
    existing_planned=$(extract_section "$existing_content" "Planned")
    existing_notes=$(extract_section "$existing_content" "Notes")

    # Start with auto-extracted content
    local merged="$auto_content"

    # Replace placeholder "In Progress" if user has real content
    if [ -n "$existing_in_progress" ] && ! echo "$existing_in_progress" | grep -q "(add current work here)"; then
        merged=$(echo "$merged" | awk -v section="$existing_in_progress" '
            /^## In Progress/ { print; getline; print section; skip=1; next }
            skip && /^## / { skip=0 }
            !skip { print }
        ')
    fi

    # Replace placeholder "Planned" if user has real content
    if [ -n "$existing_planned" ] && ! echo "$existing_planned" | grep -q "(add planned items here)"; then
        merged=$(echo "$merged" | awk -v section="$existing_planned" '
            /^## Planned/ { print; getline; print section; skip=1; next }
            skip && /^## / { skip=0 }
            !skip { print }
        ')
    fi

    # Append Notes section if it exists
    if [ -n "$existing_notes" ]; then
        merged="$merged

## Notes

$existing_notes"
    fi

    echo "$merged"
}

# Main update workflow
update_progress() {
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Ensure we're on main branch
    if [ "$current_branch" != "$MAIN_BRANCH" ]; then
        print_warning "Not on $MAIN_BRANCH branch (current: $current_branch)"
        echo ""
        read -p "Switch to $MAIN_BRANCH? [Y/n] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            print_error "Aborting. Switch to $MAIN_BRANCH first."
            exit 1
        fi
        git checkout "$MAIN_BRANCH"
    fi

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_warning "You have uncommitted changes"
        echo ""
        git status --short
        echo ""
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Commit or stash changes first"
            exit 1
        fi
    fi

    print_step "Extracting progress from git history..."
    local auto_content
    auto_content=$("$AUTO_EXTRACT" markdown)

    print_step "Reading existing progress..."
    local existing_content
    existing_content=$(get_existing_progress)

    print_step "Merging content (mode: $MERGE_MODE)..."
    local final_content
    case "$MERGE_MODE" in
        replace)
            final_content="$auto_content"
            ;;
        append)
            final_content="$existing_content

---
## Auto-Extracted Update ($(date '+%Y-%m-%d'))

$auto_content"
            ;;
        smart|*)
            final_content=$(smart_merge "$auto_content" "$existing_content")
            ;;
    esac

    # Preview mode: just show content and exit
    if [ "$PREVIEW_ONLY" = "--preview" ] || [ "$PREVIEW_ONLY" = "-p" ]; then
        echo ""
        echo -e "${BOLD}=== Preview of auto-extracted progress ===${NC}"
        echo ""
        echo "$final_content"
        echo ""
        print_success "Preview complete. Run without --preview to apply."
        exit 0
    fi

    # Create backup
    local backup_tag="context-progress-backup-$(date +%Y%m%d-%H%M%S)"
    git tag "$backup_tag" "$PROGRESS_BRANCH" 2>/dev/null || true
    print_success "Created backup: $backup_tag"

    # Switch to context-progress
    print_step "Switching to $PROGRESS_BRANCH..."
    git checkout "$PROGRESS_BRANCH" -q

    # Rebase onto main
    print_step "Rebasing onto $MAIN_BRANCH..."
    if ! git rebase "$MAIN_BRANCH" -q 2>/dev/null; then
        print_warning "Rebase conflict - attempting auto-resolution..."
        git rebase --abort 2>/dev/null || true
        git reset --hard "$MAIN_BRANCH" -q
        print_success "Reset to $MAIN_BRANCH (progress will be regenerated)"
    fi

    # Write content to temp file for editing
    local tmpfile
    tmpfile=$(mktemp)
    echo "$final_content" > "$tmpfile"

    if [ "$SKIP_EDIT" = "1" ]; then
        # Non-interactive: commit directly
        git commit --amend -m "$final_content" --no-verify -q
        print_success "Progress updated (non-interactive mode)"
    else
        # Interactive: open editor
        print_step "Opening editor for review..."
        echo ""
        echo -e "${YELLOW}Review the auto-extracted progress and make any edits.${NC}"
        echo -e "${YELLOW}The file will be used as the new progress commit message.${NC}"
        echo ""

        # Use git's configured editor
        local editor="${GIT_EDITOR:-${VISUAL:-${EDITOR:-vi}}}"
        "$editor" "$tmpfile"

        # Commit with edited content
        local edited_content
        edited_content=$(cat "$tmpfile")
        git commit --amend -m "$edited_content" --no-verify -q
        print_success "Progress updated with your edits"
    fi

    rm -f "$tmpfile"

    # Return to main branch
    print_step "Returning to $MAIN_BRANCH..."
    git checkout "$MAIN_BRANCH" -q

    echo ""
    print_success "Context progress updated successfully!"
    echo ""
    echo -e "${CYAN}View progress:${NC} git log context-progress -1 --format=%B"
    echo -e "${CYAN}Delete backup:${NC} git tag -d $backup_tag"
}

# Show help
show_help() {
    echo -e "${BOLD}Context Progress Auto-Update${NC}"
    echo ""
    echo "Automatically extracts progress from git history and updates the"
    echo "context-progress branch. Inspired by /compact's extraction patterns."
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "    update-progress.sh [OPTIONS]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "    --preview, -p    Show extracted content without applying"
    echo "    --help, -h       Show this help message"
    echo ""
    echo -e "${BOLD}Environment Variables:${NC}"
    echo "    CONTEXT_MAIN_BRANCH    Main branch name (default: master)"
    echo "    CONTEXT_SKIP_EDIT      Skip editor, commit directly (default: 0)"
    echo "    CONTEXT_MERGE_MODE     How to merge with existing content:"
    echo "                           - smart: preserve manual edits (default)"
    echo "                           - replace: use only auto-extracted content"
    echo "                           - append: append to existing content"
    echo ""
    echo -e "${BOLD}What Gets Extracted:${NC}"
    echo "    - Commits since last progress update (categorized)"
    echo "    - File changes with status"
    echo "    - Issues/fixes from commit messages"
    echo "    - Key code references (functions, classes added)"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "    # Preview what will be extracted"
    echo "    ./update-progress.sh --preview"
    echo ""
    echo "    # Update with editor review"
    echo "    ./update-progress.sh"
    echo ""
    echo "    # Update without editor (CI/automation)"
    echo "    CONTEXT_SKIP_EDIT=1 ./update-progress.sh"
    echo ""
    echo "    # Full replace mode"
    echo "    CONTEXT_MERGE_MODE=replace ./update-progress.sh"
}

# Main
print_header

case "$1" in
    --help|-h)
        show_help
        ;;
    *)
        check_prerequisites
        update_progress
        ;;
esac
