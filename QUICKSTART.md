# Quick Start Guide

Get started with the Context Commit workflow in 5 minutes.

## Installation

1. Copy the plugin to your Claude Code plugins directory:
```bash
mkdir -p ~/.claude/plugins
cp -r context-commit-plugin ~/.claude/plugins/context-commit
```

2. Restart Claude Code

## 5-Minute Setup

### Step 1: Create CLAUDE.md

In your project root:

```bash
cat > CLAUDE.md << 'EOF'
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [context-progress] Current project progress (branch reference)

SESSION INITIALIZATION:
- Read the context-progress commit message using: `git log context-progress -1 --format=%B`
- Acknowledge that you have read and understood the project context
- Wait for the user's specific task request
EOF
```

### Step 2: Create context-progress Branch

```bash
# Create orphan branch
git checkout --orphan context-progress

# Remove staged files
git rm -rf .

# Create initial progress commit
git commit --allow-empty -m "[CONTEXT] Project Progress

## Completed ✓
- [x] Context workflow initialized

## In Progress
- [ ] Setting up project

## Planned
- [ ] First feature

---
Update via: git commit --amend
"

# Return to main branch
git checkout master  # or main
```

### Step 3: Test It

```bash
# View your progress
git log context-progress -1 --format=%B

# You should see your progress checklist
```

### Step 4: Install Git Hooks (Recommended)

```bash
# Install workflow enforcement hooks
~/.claude/plugins/context-commit/hooks/install-hooks.sh
```

The hooks will:
- Run tests before commits
- Validate [CONTEXT] commit format
- Keep context-progress synchronized
- Auto-generate progress.html
- Protect against data loss

### Step 5: Add Context (Optional)

```bash
# Add a context commit for your project requirements
git commit --allow-empty -m "[CONTEXT] Project Requirements

## Goal
Build a [describe your project]

## Technical Stack
- Language: [language]
- Framework: [framework]
- Database: [database]

## Key Features
- Feature 1
- Feature 2
- Feature 3
"

# Get the commit hash
git log -1 --format=%h

# Update CLAUDE.md with the hash (e.g., abc1234)
```

Edit CLAUDE.md:
```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [abc1234] Project Requirements
 2. [context-progress] Current project progress (branch reference)
```

## Daily Usage

### Update Progress After Work

```bash
# Switch to progress branch
git checkout context-progress

# Rebase onto latest work
git rebase master

# Amend the progress commit
git commit --amend
# (Editor opens - update your checklist)

# Return to master
git checkout master
```

### What to Update

In the commit message editor, move tasks between sections:

**Completed ✓**: Mark done tasks with `[x]`
```markdown
## Completed ✓
- [x] Setup authentication
- [x] Create user model
```

**In Progress**: Current work (1-3 tasks)
```markdown
## In Progress
- [ ] Implement login endpoint
- [ ] Add input validation
```

**Planned**: Future tasks
```markdown
## Planned
- [ ] Password reset flow
- [ ] Email verification
```

## Using with Claude

When you start a Claude Code session:

1. Claude automatically reads CLAUDE.md
2. Claude runs `git log context-progress -1 --format=%B`
3. Claude knows your project context and current progress
4. You can continue from where you left off

Ask Claude:
- "What's the current project status?"
- "What should I work on next?"
- "Update progress - I finished the login feature"

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check [templates/](templates/) for more examples
- Learn about the four skills: context-init, context-add, context-progress, context-read

## Tips

1. **Install Hooks**: The git hooks enforce best practices automatically
2. **Commit Often**: Update progress after each significant task
3. **Be Specific**: "Implement JWT authentication" not just "Auth"
4. **Use Categories**: Group related tasks under headings
5. **Keep It Current**: Update progress daily or per session
6. **Share It**: Push context-progress branch to share status with team
7. **Use Helper Scripts**: `safe-context-update.sh` and `recover-context-progress.sh` make workflows safer

## Common Commands

```bash
# View progress
git log context-progress -1 --format=%B

# Update progress
git checkout context-progress && git rebase master && git commit --amend && git checkout master

# Add context
git commit --allow-empty -m "[CONTEXT] Topic

Details here
"

# View all context commits
git log --oneline --grep="^\[CONTEXT\]"

# Read specific context
git log [commit-hash] -1 --format=%B
```

## Troubleshooting

**"Can't find context-progress branch"**
```bash
git branch -a | grep context-progress
# If missing, recreate it (see Step 2)
```

**"CLAUDE.md not found"**
```bash
# Create it (see Step 1)
```

**"Context not loading in Claude"**
- Verify CLAUDE.md is in repository root
- Check commit hashes are correct
- Ensure context-progress branch exists

## Getting Help

- Check the [README.md](README.md) for full documentation
- Review skill docs in `skills/*/SKILL.md`
- Try asking Claude: "Help me set up the context workflow"

---

Ready to start? Follow the 5-minute setup above and you're good to go!
