# [CONTEXT] Git Hooks

This directory contains git hooks that enforce the project's development workflows.

## ✨ New: Automatic Session Capture

Every commit now automatically captures your session state in context-progress, making sessions **resumable** for AI assistants!

**What gets captured:**
- 📝 Latest commit message
- 📁 Files you modified
- 🔄 Recent work history
- ⏰ Timestamp

**Result:** New Claude sessions can instantly resume where you left off by reading the "Current Session" section in context-progress.

**Enable interactive mode for detailed notes:**
```bash
CONTEXT_SESSION_PROMPT=1 git commit -m "Your message"
```

See [capture-session.sh](#capture-sessionsh) for details.

## 🛡️ IMPORTANT: context-progress Branch Protection

The `context-progress` branch is **protected** against accidental destruction. Multiple safety mechanisms prevent data loss.

### Automatic Protections

1. **Pre-commit Hook Protection**
   - Prevents non-[CONTEXT] commits on context-progress
   - Creates automatic backup tags before any commit
   - Enforces synchronization with master

2. **Automatic Backups**
   - Every commit on context-progress creates a timestamped backup tag
   - Format: `context-progress-backup-YYYYMMDD-HHMMSS`
   - Can be restored using `hooks/recover-context-progress.sh`

### Safe Workflows

**✅ CORRECT: Update context-progress**
```bash
# Use the safe update script
./hooks/safe-context-update.sh

# Or manually with safety checks:
git checkout master              # Start on master
git checkout context-progress    # Switch to context-progress
git rebase master                # Rebase (safe - preserves progress commit)
git commit --amend              # Update progress checklist
git checkout master             # Return to master
```

**❌ DANGEROUS: Never do these on context-progress**
```bash
git reset --hard master         # DESTROYS progress commit!
git reset --hard HEAD~1         # DESTROYS progress commit!
git rebase -i master            # Can accidentally drop progress commit
```

### Recovery from Accidents

If context-progress is accidentally destroyed:

```bash
# Run the recovery script
./hooks/recover-context-progress.sh

# It will show available backups and let you restore
```

View available backups:
```bash
git tag -l "context-progress-backup-*"
```

Manually restore from a backup:
```bash
git branch -f context-progress context-progress-backup-YYYYMMDD-HHMMSS
```

---

## Installation

Run the installation script from the project root:

```bash
./hooks/install-hooks.sh
```

This creates symlinks from `.git/hooks/` to the versioned hooks in this directory.

## Hooks Overview

### pre-commit
**Purpose**: Enforce TDD workflow and automatic session capture

**Checks**:
- On master branch: Ensures `context-progress` is synchronized (not behind master)
- **NEW**: Automatically captures session state when context-progress is behind
- Runs all tests with strict concurrency (`swift test -Xswiftc -strict-concurrency=complete`)
- Blocks commit if tests fail

**Automatic Session Capture**:
- When context-progress is behind, automatically runs `capture-session.sh`
- Captures: latest commit message, modified files, recent work
- Updates context-progress with "Current Session" section
- Makes sessions resumable for new Claude sessions

**Interactive Mode**:
Set `CONTEXT_SESSION_PROMPT=1` to enable interactive prompts:
```bash
CONTEXT_SESSION_PROMPT=1 git commit -m "Your commit message"
```
You'll be prompted for:
- What you accomplished this session
- Next steps
- Blockers/questions

**Why**: Guarantees that every commit has passing tests AND captures resumable session context.

### commit-msg
**Purpose**: Validate commit message format

**Checks**:
- `[CONTEXT]` commits must have at least 5 lines
- Ensures documentation commits contain substantial content

**Why**: Maintains quality of project knowledge base stored in git commits.

### post-commit
**Purpose**: Auto-generate progress visualization and provide reminders

**Behavior on `context-progress` branch**:
- Auto-generates `progress.html` from the [CONTEXT] commit message
- Parses markdown checkboxes and creates styled HTML
- Amends commit to include the generated HTML file

**Behavior on `master` branch**:
- Shows reminder to update `context-progress` branch after commits

**Why**: Keeps progress tracking automated and visual.

### prepare-commit-msg
**Purpose**: Provide commit message guidance

**Behavior**:
- Populates editor with commit message template
- Shows examples and formatting guidelines
- Reminds about TDD requirements

**Why**: Helps maintain consistent commit message style.

### capture-session.sh
**Purpose**: Automatic session state capture for resumable workflows

**Behavior**:
- Auto-captures current git state (files, commits, messages)
- Updates context-progress with "Current Session" section
- Preserves existing Completed/In Progress/Planned sections
- Rebases context-progress and amends commit
- Supports interactive mode via `CONTEXT_SESSION_PROMPT=1`

**Auto-Captured Data**:
- Latest commit message
- Modified files (from staging area)
- Recent commits (last 3)
- Timestamp

**Interactive Mode Additions**:
- Custom accomplishments summary
- Next steps
- Blockers/questions

**Why**: Makes every commit a potential session resumption point for AI assistants. New Claude sessions can read "Current Session" and immediately understand what was being worked on, what was accomplished, and what's next.

### generate-progress-html.sh
**Purpose**: Helper script for HTML generation

**Behavior**:
- Converts markdown from [CONTEXT] commit to styled HTML
- Handles checkboxes `[x]` and `[ ]`, headers, lists, inline code
- Adds timestamp and styling

**Why**: Provides visual progress tracking that can be viewed in a browser.

## Workflow

### Making Changes on Master (With Automatic Session Capture)

1. Make your changes
2. Write tests (TDD workflow)
3. Stage and commit:
   ```bash
   git add .
   git commit -m "Your commit message"
   ```
4. Pre-commit hook automatically:
   - Detects context-progress is behind
   - **Captures session state** (files, commit msg, recent work)
   - Updates context-progress with "Current Session" section
   - Rebases context-progress onto current commit
   - Runs tests
5. Commit succeeds - **session is now resumable!**

**Interactive Session Capture:**
For detailed session notes:
```bash
CONTEXT_SESSION_PROMPT=1 git commit -m "Your commit message"
```
You'll be prompted to add:
- Custom accomplishments
- Next steps
- Blockers/questions

### Making Changes on Master (Manual Mode - Old Workflow)

Still works if you prefer manual control:

1. Make your changes
2. Write tests (TDD workflow)
3. Try to commit
4. If `context-progress` is behind → Hook auto-updates it
5. Or update manually:
   ```bash
   git checkout context-progress
   git rebase master
   git commit --amend  # Edit progress checklist in commit message
   git checkout master
   ```
6. Commit now succeeds (tests pass, progress synced)

### Updating Progress

When on `context-progress` and amending the [CONTEXT] commit:
- Edit the markdown checklist in the commit message
- Save and commit
- `progress.html` is automatically generated and included
- No manual HTML editing needed!

## Bypassing Hooks

**Not recommended**, but hooks can be bypassed with:
```bash
git commit --no-verify
```

Only use this for emergencies or when you understand the implications.

## Uninstalling

Remove the symlinks:
```bash
rm .git/hooks/pre-commit
rm .git/hooks/commit-msg
rm .git/hooks/post-commit
rm .git/hooks/prepare-commit-msg
rm .git/hooks/generate-progress-html.sh
```

## Troubleshooting

**Hook doesn't run:**
- Ensure hooks are executable: `chmod +x hooks/*`
- Verify symlinks exist: `ls -la .git/hooks/`

**Tests fail unexpectedly:**
- Run tests manually: `swift test -Xswiftc -strict-concurrency=complete`
- Check for uncommitted changes affecting tests

**context-progress out of sync:**
- Follow the workflow above to sync it
- Check how many commits behind: `git rev-list context-progress..master --count`
