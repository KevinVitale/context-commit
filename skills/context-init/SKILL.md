---
name: context-init
description: Initialize the [CONTEXT] commit workflow in a git repository by creating CLAUDE.md and setting up the context-progress branch
---

# Context Commit Initialization

This skill helps you set up the [CONTEXT] commit workflow in a git repository. The workflow uses git commits with [CONTEXT] prefixes to store project documentation and instructions.

## When to Use

Use this skill when:
- Starting a new project that needs structured context management
- Converting an existing project to use the [CONTEXT] workflow
- The user requests to "initialize context workflow" or "set up CLAUDE.md"

## Initialization Steps

When initializing the [CONTEXT] workflow, follow these steps:

### 1. Create CLAUDE.md

Create a `CLAUDE.md` file in the repository root with the following structure:

```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [commit-hash] Brief description of context topic
 2. [commit-hash] Another context topic
 3. [context-progress] Current project progress (branch reference)

SESSION INITIALIZATION:
- Read the context-progress commit message using: `git log context-progress -1 --format=%B`
- Acknowledge that you have read and understood the project context
- Wait for the user's specific task request
- [Add any project-specific initialization instructions]
```

### 2. Create Initial [CONTEXT] Commits

Guide the user to create initial context commits for:
- **Project requirements and technical specifications** - Core project goals, technical stack, requirements
- **Development workflows** - TDD practices, code standards, review processes
- **Architecture decisions** - Design patterns, architectural choices, trade-offs

For each context commit:
```bash
git commit --allow-empty -m "[CONTEXT] Topic name

Detailed context content goes here.
Can span multiple lines and sections.

## Example Section
- Bullet points
- Guidelines
- Requirements
"
```

### 3. Create context-progress Branch

Create an orphan branch for progress tracking:

```bash
# Create orphan branch (no history)
git checkout --orphan context-progress

# Remove all files from staging
git rm -rf .

# Create the initial progress commit
git commit --allow-empty -m "[CONTEXT] Project Progress

This commit tracks the current state of the project.

## Completed ✓
- [x] [CONTEXT] workflow initialized
- [x] CLAUDE.md created

## In Progress
- [ ] (Add current work here)

## Planned
- [ ] (Add future tasks here)

---
Update this commit via: git commit --amend
"

# Return to main branch
git checkout master  # or main
```

### 4. Update CLAUDE.md with Commit References

After creating context commits, update CLAUDE.md with the actual commit hashes:

```bash
# Get the commit hash
git log --oneline -1 [commit-containing-context]

# Update CLAUDE.md with the hash
```

### 5. Install Git Hooks (Recommended)

Install the workflow enforcement hooks:

```bash
# Run the hook installer from the plugin directory
~/.claude/plugins/context-commit/hooks/install-hooks.sh
```

The hooks will:
- Run tests before commits (TDD enforcement)
- Validate [CONTEXT] commit format
- Keep context-progress synchronized
- Auto-generate progress.html visualization
- Protect against accidental data loss

### 6. Verify Setup

Confirm the setup works:

```bash
# Read CLAUDE.md
cat CLAUDE.md

# Read a context commit
git log [commit-hash] -1 --format=%B

# Read progress
git log context-progress -1 --format=%B

# Verify hooks are installed
ls -la .git/hooks/ | grep -E "(pre-commit|commit-msg|post-commit|pre-push)"
```

## Key Principles

1. **Commit Messages as Documentation**: Use [CONTEXT] prefix for commits that contain instructions or documentation
2. **CLAUDE.md as Index**: Keep CLAUDE.md lightweight - it just references commits
3. **Branch-based Progress**: Use context-progress branch for mutable state (progress tracking)
4. **Hash-based Context**: Use commit hashes for immutable context (requirements, workflows)
5. **Version Controlled**: All context travels with the repository

## Benefits

- No external documentation files to maintain
- Context is version controlled alongside code
- Claude automatically reads CLAUDE.md on session start
- Progress updates don't change CLAUDE.md (stable reference)
- Shareable across teams and repositories

## Example CLAUDE.md

```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [abc1234] Project requirements and technical specifications
 2. [def5678] Development workflow and TDD practices
 3. [ghi9012] Architecture decisions and patterns
 4. [context-progress] Current project progress (branch reference)

SESSION INITIALIZATION:
- Read the context-progress commit message using: `git log context-progress -1 --format=%B`
- Acknowledge that you have read and understood the project context
- Wait for the user's specific task request
```

## After Initialization

Once setup is complete, remind the user they can:
- Use the `context-add` skill to add new context commits
- Use the `context-progress` skill to update progress
- Use the `context-read` skill to review current context
- Install git hooks for workflow enforcement (see step 5 above)
- Use helper scripts in `~/.claude/plugins/context-commit/hooks/`:
  - `safe-context-update.sh` - Safe progress update workflow
  - `recover-context-progress.sh` - Recover from accidental data loss
  - `generate-progress-html.sh` - Generate browser-viewable progress
