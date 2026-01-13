---
name: context-progress
description: Update the context-progress branch to track project status, completed tasks, and current work using git commit --amend
---

# Update Project Progress

This skill guides you through updating the context-progress branch to reflect current project status.

## When to Use

Use this skill when:
- Completing a significant task or milestone
- Starting new work that should be tracked
- Updating project status after a development session
- The user requests to "update progress" or "track status"

## Why context-progress Branch?

The context-progress branch uses a unique approach:
- **Stable Reference**: CLAUDE.md references the branch name, not a commit hash
- **Mutable State**: Progress changes frequently, so we amend one commit rather than creating many
- **No Hash Updates**: Avoids needing to update CLAUDE.md constantly
- **Clean History**: Keeps the main branch clean from progress tracking commits

## Update Progress Workflow

### Method 1: Simple Amend (Recommended)

Use this when the context-progress branch is already on the latest work:

```bash
# Switch to context-progress branch
git checkout context-progress

# Amend the progress commit with updated status
git commit --amend

# This opens your editor to update the commit message

# Switch back to main working branch
git checkout master  # or main
```

### Method 2: Rebase and Amend

Use this when you've made new commits on master that should be included in progress:

```bash
# Ensure you're on your working branch (master/main)
git checkout master

# Switch to context-progress
git checkout context-progress

# Rebase onto master to include new work
git rebase master

# Amend the progress commit with updated checklist
git commit --amend

# Switch back to master
git checkout master
```

### Method 3: Force Update from Master

Use this to reset context-progress to current master state, then update progress:

```bash
# On master after new work is committed
git checkout master

# Force context-progress to match master
git branch -f context-progress master

# Switch to context-progress
git checkout context-progress

# Amend to update progress
git commit --amend

# Back to master
git checkout master
```

## Progress Commit Structure

The progress commit should follow this template:

```
[CONTEXT] Project Name Progress

This commit tracks the current state of project development.

## Completed ✓

### Category 1
- [x] Completed task 1
- [x] Completed task 2
- [x] Completed task 3

### Category 2
- [x] Another completed task
- [x] More completed work

## In Progress

- [ ] Current task being worked on
- [ ] Another active task

## Planned

- [ ] Future task 1
- [ ] Future task 2
- [ ] Future enhancement

## Metrics (Optional)

- Test Coverage: 85%
- Performance: 1.2ms average
- Build Status: Passing

---
Update this commit via: git commit --amend
Update from master via: git rebase master && git commit --amend
```

## Best Practices

### Checklist Guidelines

1. **Use Markdown Checkboxes**: `- [x]` for done, `- [ ]` for pending
2. **Group by Category**: Organize tasks into logical sections
3. **Be Specific**: "Implement user authentication" not just "Auth"
4. **Include Context**: Add enough detail to understand what was done
5. **Update Regularly**: Keep progress current (daily or per session)

### What to Track

**Completed Section:**
- Features implemented
- Bugs fixed
- Tests added
- Documentation written
- Performance improvements

**In Progress Section:**
- Current active work (1-3 tasks max)
- Blocked tasks with blockers noted
- Tasks started but not finished

**Planned Section:**
- Next tasks in the queue
- Future features or improvements
- Technical debt items
- Nice-to-have enhancements

### What NOT to Track

- Minute-by-minute changes (too granular)
- Temporary debugging steps
- Work-in-progress that's not committed
- Personal notes (use a separate system)

## Updating After Completing Tasks

When you complete tasks, follow this flow:

```bash
# 1. On master, do your work and commit normally
git add .
git commit -m "Implement feature X"

# 2. Switch to context-progress
git checkout context-progress

# 3. Rebase to include new work
git rebase master

# 4. Amend the progress commit
git commit --amend
# In editor, move completed tasks from "In Progress" to "Completed ✓"
# Add new tasks to "In Progress" or "Planned"

# 5. Back to master
git checkout master
```

## Reading Current Progress

To view current progress without switching branches:

```bash
# View the full progress commit
git log context-progress -1 --format=%B

# Or just the commit message
git show context-progress --format=%B --no-patch
```

## Handling Conflicts

If rebase causes conflicts:

```bash
# On context-progress branch after rebase conflict
git status  # See conflicting files

# Resolve conflicts in files
# Then continue rebase
git add .
git rebase --continue

# Amend progress commit
git commit --amend
```

## Sharing Progress

The context-progress branch can be pushed to share status with team:

```bash
# Push progress branch
git push origin context-progress --force

# Force is needed because we amend the commit
# This is safe because context-progress is a tracking branch, not a code branch
```

**Warning**: Only force-push the context-progress branch, never main/master!

## Integration with Claude Sessions

Claude reads progress automatically:
1. CLAUDE.md references `context-progress` branch
2. On session start, Claude runs `git log context-progress -1 --format=%B`
3. Claude sees current status and completed work
4. Can pick up where previous session left off

## Example Progress Update Session

```bash
# Scenario: Just finished implementing authentication

# 1. Commit the work on master
git add .
git commit -m "Implement JWT authentication with refresh tokens"

# 2. Update progress
git checkout context-progress
git rebase master
git commit --amend

# In the editor, update:
# Move "- [ ] Implement authentication" to Completed ✓ section
# Change to "- [x] Implement JWT authentication with refresh tokens"
# Add "- [ ] Add rate limiting to auth endpoints" to Planned

# 3. Return to master
git checkout master
```

## Troubleshooting

**Lost context-progress branch:**
```bash
# Recreate from master
git checkout -b context-progress master
git commit --allow-empty -m "[CONTEXT] Project Progress

## Completed ✓
(Add items here)

## In Progress
(Add items here)

## Planned
(Add items here)
"
```

**Progress out of sync with master:**
```bash
# Reset context-progress to master, then amend
git branch -f context-progress master
git checkout context-progress
git commit --amend
```

**Want to keep progress history:**
```bash
# Don't use context-progress for historical tracking
# Instead, create dated snapshot commits:
git commit --allow-empty -m "[PROGRESS-SNAPSHOT] 2026-01-12 Status

(Copy of progress at this point in time)
"
```

## Summary

- context-progress is a special mutable branch for tracking status
- Use `git commit --amend` to update progress without creating new commits
- Rebase onto master to include new work before amending
- Keep progress current and organized by category
- Claude automatically reads progress on session start
