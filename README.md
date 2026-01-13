# Context Commit Plugin

A Claude Code plugin that implements the [CONTEXT] commit workflow for git-based project documentation and progress tracking.

## Overview

The Context Commit workflow uses git commits with `[CONTEXT]` prefixes to store project documentation, requirements, workflows, and progress. This keeps all project context version-controlled and automatically loaded by Claude Code.

**Key Benefits:**
- Documentation lives in git commits, not separate files
- Context is version-controlled alongside code
- Claude automatically reads context on session start
- **NEW: Automatic session capture** - Every commit captures your work state for instant session resumption
- No external documentation tools needed
- Shareable across teams via repository

## ✨ Automatic Session Capture (New!)

Every commit now automatically captures your session state, making sessions **resumable** for AI assistants!

When you commit to master, the pre-commit hook automatically:
1. Detects that context-progress is behind
2. Captures your session state (commit message, files modified, recent work)
3. Updates context-progress with a "Current Session" section
4. Rebases context-progress to stay in sync

**Result:** New Claude sessions can instantly resume where you left off by reading the "Current Session" section.

**Example captured session:**
```markdown
## Current Session (2026-01-12 17:45)
**Latest Commit:** Add JWT token generation
**Files Modified:**
  - src/auth.ts
  - src/middleware/auth.ts

**Recent Work:**
- Add JWT token generation (commit: abc1234)
- Update auth middleware (commit: def5678)
```

**Enable interactive mode for detailed notes:**
```bash
CONTEXT_SESSION_PROMPT=1 git commit -m "Your message"
```
Interactive mode prompts for accomplishments, next steps, and blockers.

See `hooks/README.md` for complete documentation.

## Installation

### Install from Marketplace (Recommended)

The easiest way to install this plugin:

```bash
# Add the marketplace
/plugin marketplace add KevinVitale/context-commit

# Install the plugin
/plugin install context-commit@context-commit-marketplace
```

That's it! The plugin will be automatically available in Claude Code.

### Install via Git Clone

```bash
# Clone the plugin to your Claude Code plugins directory
mkdir -p ~/.claude/plugins
cd ~/.claude/plugins
git clone https://github.com/KevinVitale/context-commit.git context-commit
```

### Manual Installation

1. Download or clone this repository
2. Move the `context-commit-plugin` directory to `~/.claude/plugins/context-commit`
3. Restart Claude Code

### Install Git Hooks (Recommended)

After initializing the workflow in your project, install the git hooks for workflow enforcement:

```bash
# From your project root (where you have CLAUDE.md)
~/.claude/plugins/context-commit/hooks/install-hooks.sh
```

The hooks enforce:
- All tests pass before commits (TDD workflow)
- **Automatic session capture** - Captures work state on every commit
- context-progress stays synchronized with master
- [CONTEXT] commits contain detailed content (5+ lines)
- Auto-generation of progress.html visualization
- Protection against accidental data loss on context-progress branch

## Components

This plugin provides four specialized skills and a comprehensive set of git hooks:

### Git Hooks

Located in `hooks/` directory:

- **pre-commit** - Runs tests, enforces synchronization, **auto-captures session state**
- **commit-msg** - Validates [CONTEXT] commit format (minimum 5 lines)
- **post-commit** - Auto-generates progress.html visualization
- **prepare-commit-msg** - Provides commit message templates
- **pre-push** - Ensures context-progress is synced before pushing
- **capture-session.sh** - **NEW**: Helper script for automatic session capture
- **install-hooks.sh** - Easy installation script
- **safe-context-update.sh** - Safe workflow for updating progress
- **recover-context-progress.sh** - Recovery tool for accidental data loss

See `hooks/README.md` for detailed hook documentation.

### Skills

### 1. context-init

Initialize the [CONTEXT] workflow in a repository.

**Use when:**
- Starting a new project
- Converting existing project to use [CONTEXT] workflow

**What it does:**
- Creates CLAUDE.md index file
- Guides creation of initial [CONTEXT] commits
- Sets up context-progress branch
- Verifies setup

**Example:**
```
User: "Initialize context workflow for this project"
Claude: [Uses context-init skill to guide setup]
```

### 2. context-add

Add new [CONTEXT] commits for documentation.

**Use when:**
- Documenting new requirements or specifications
- Adding workflow or process documentation
- Recording architectural decisions
- Documenting coding standards

**What it does:**
- Creates [CONTEXT] prefixed commits
- Updates CLAUDE.md with new references
- Verifies new context is accessible

**Example:**
```
User: "Add context for our API authentication workflow"
Claude: [Uses context-add skill to create commit and update CLAUDE.md]
```

### 3. context-progress

Update project progress on the context-progress branch.

**Use when:**
- Completing tasks or milestones
- Updating project status
- Tracking current work

**What it does:**
- Guides rebasing context-progress onto latest work
- Amends progress commit with updated checklist
- Maintains stable branch reference (no hash updates needed)

**Example:**
```
User: "Update progress - I just finished authentication"
Claude: [Uses context-progress skill to update status]
```

### 4. context-read

Read and summarize all project context.

**Use when:**
- Starting a new session
- Reviewing project documentation
- Onboarding to unfamiliar project
- Verifying context setup

**What it does:**
- Reads CLAUDE.md
- Fetches all referenced [CONTEXT] commits
- Summarizes requirements, workflows, and progress
- Acknowledges understanding

**Example:**
```
User: "Show me the project context"
Claude: [Uses context-read skill to display all context]
```

## Workflow Overview

### The [CONTEXT] Commit Pattern

1. **CLAUDE.md** - Index file in repository root that references context commits
2. **[CONTEXT] Commits** - Git commits with `[CONTEXT]` prefix containing documentation
3. **context-progress Branch** - Special branch for mutable progress tracking

### Basic Workflow

```bash
# 1. Initialize (once per project)
# Creates CLAUDE.md and context-progress branch

# 2. Work on your code and commit normally
git add .
git commit -m "Add JWT token generation"

# Pre-commit hook automatically:
# - Captures session state
# - Updates context-progress with "Current Session" section
# - Rebases context-progress
# - Runs tests

# 3. Add context commits for architecture/requirements (as needed)
git commit --allow-empty -m "[CONTEXT] Topic

Detailed documentation here
"

# Update CLAUDE.md with reference

# 4. Claude reads automatically on session start
# - Loads architecture/requirements from [CONTEXT] commits
# - Reads "Current Session" to resume exactly where you left off
```

### Manual Progress Updates (Optional)

The hooks now handle progress updates automatically, but you can still update manually:

```bash
git checkout context-progress
git rebase master
git commit --amend  # Manually edit progress checklist
git checkout master
```

## Example CLAUDE.md

```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [e7b0129] Project requirements and technical specifications
 2. [ae291fc] Development workflow and TDD practices
 3. [7cc3e39] Architecture decisions and patterns
 4. [context-progress] Current project progress (branch reference)

SESSION INITIALIZATION:
- Read the context-progress commit message using: `git log context-progress -1 --format=%B`
- Acknowledge that you have read and understood the project context
- Wait for the user's specific task request
```

## Templates

See the `templates/` directory for:
- `CLAUDE.md.template` - Starting template for CLAUDE.md
- `context-commit-template.md` - Template for [CONTEXT] commit messages
- `progress-template.md` - Template for progress tracking

## Git Hooks

The plugin includes comprehensive git hooks that enforce the [CONTEXT] workflow:

### Hook Features

1. **Automatic Session Capture** (pre-commit via capture-session.sh) **NEW!**
   - Auto-captures session state on every commit
   - Updates context-progress with "Current Session" section
   - Captures: commit message, modified files, recent commits, timestamp
   - Interactive mode available: `CONTEXT_SESSION_PROMPT=1 git commit -m "message"`
   - Makes every commit a resumption point for AI sessions

2. **TDD Enforcement** (pre-commit)
   - Runs all tests before allowing commits
   - Ensures context-progress is synchronized
   - Prevents commits when tests fail

3. **[CONTEXT] Validation** (commit-msg)
   - Requires [CONTEXT] commits to have 5+ lines
   - Ensures documentation quality

4. **Auto-Visualization** (post-commit)
   - Generates progress.html from context-progress commit
   - Provides browser-viewable progress tracking
   - Automatically includes HTML in commit

5. **Progress Protection** (pre-commit, pre-push)
   - Prevents accidental data loss on context-progress
   - Creates automatic backup tags
   - Blocks destructive operations

6. **Commit Guidance** (prepare-commit-msg)
   - Provides helpful templates
   - Shows formatting examples

### Installing Hooks

After setting up your project with the [CONTEXT] workflow:

```bash
# From your project root
~/.claude/plugins/context-commit/hooks/install-hooks.sh
```

Or copy hooks manually:
```bash
cp ~/.claude/plugins/context-commit/hooks/* your-project/.git/hooks/
```

### Hook Workflows

**Safe Progress Update:**
```bash
# Use the provided helper script
~/.claude/plugins/context-commit/hooks/safe-context-update.sh

# Or manually:
git checkout context-progress
git rebase master
git commit --amend  # Update checklist
git checkout master
```

**Recovery from Accidents:**
```bash
# If context-progress is lost or corrupted
~/.claude/plugins/context-commit/hooks/recover-context-progress.sh
```

See `hooks/README.md` for complete documentation.

## Concepts

### Why Git Commits?

- **Version Control**: Context evolves with the codebase
- **Immutability**: Historical context is preserved
- **Shareability**: Context travels with repository
- **No Sync Issues**: No external docs to keep in sync
- **Automatic Loading**: Claude Code reads CLAUDE.md automatically

### Why context-progress Branch?

- **Stable Reference**: CLAUDE.md references branch name, not changing hashes
- **Mutable State**: Progress changes frequently, amending is cleaner than many commits
- **Clean Main Branch**: Keeps commit noise out of main development branch
- **Easy Updates**: `git commit --amend` is simpler than creating/tracking new commits

### Context vs Progress

**Context Commits (Immutable):**
- Requirements and specifications
- Workflows and processes
- Architecture decisions
- Coding standards
- Referenced by commit hash in CLAUDE.md

**Progress Branch (Mutable):**
- Current project status
- Completed tasks
- Work in progress
- Next planned items
- **NEW: Current Session** - Active work state for session resumption
- Referenced by branch name in CLAUDE.md

### Session Resumption

The "Current Session" section in context-progress enables true session continuity:

**What gets captured automatically:**
- Latest commit message
- Files you modified
- Recent work history (last 3 commits)
- Timestamp

**Benefits:**
- New Claude sessions instantly understand what you were working on
- Zero onboarding time - sessions resume mid-task
- No manual note-taking needed
- Always accurate - reflects actual git state

**Example:**
A session reads the "Current Session" and knows:
- You were implementing JWT authentication
- You modified auth.ts and middleware/auth.ts
- You just completed token generation
- Next step is refresh token logic

This eliminates the "where was I?" problem when starting new sessions.

## Best Practices

### Creating Context Commits

1. Use `--allow-empty` for documentation-only commits
2. Always prefix with `[CONTEXT]`
3. Use markdown formatting in commit messages
4. Make each commit self-contained and complete
5. Don't amend [CONTEXT] commits - create new ones instead

### Organizing CLAUDE.md

1. Group related context commits together
2. Keep descriptions brief but clear
3. Always keep context-progress as last reference
4. Maintain clear session initialization instructions

### Updating Progress

**Automatic (Default with Hooks):**
1. Just commit normally - session state is captured automatically
2. Use `CONTEXT_SESSION_PROMPT=1` for end-of-day commits with detailed notes
3. Trust the automatic capture for day-to-day work

**Manual (When needed):**
1. Update regularly (daily or per session)
2. Use markdown checkboxes: `- [x]` and `- [ ]`
3. Move completed items to "Completed ✓" section
4. Keep "In Progress" focused (1-3 tasks)
5. Be specific in task descriptions

### Team Collaboration

1. Push [CONTEXT] commits to share with team
2. Force-push context-progress branch (it's safe for this branch)
3. Never force-push main/master branches
4. Coordinate on CLAUDE.md updates to avoid conflicts

## Advanced Usage

### Multiple Progress Branches

For large projects, you might use multiple progress branches:

```markdown
 - [context-progress-backend] Backend development progress
 - [context-progress-frontend] Frontend development progress
 - [context-progress-infra] Infrastructure progress
```

### Context Snapshots

For historical tracking, create snapshot commits:

```bash
git commit --allow-empty -m "[PROGRESS-SNAPSHOT] 2026-01-12 Status

(Copy of current progress for historical record)
"
```

### Context Categories

Organize context commits by category using prefixes:

```markdown
 1. [abc123] [REQ] User authentication requirements
 2. [def456] [WORKFLOW] TDD and testing practices
 3. [ghi789] [ARCH] Database schema design decision
```

## Troubleshooting

### CLAUDE.md Not Found

```bash
# Initialize the workflow
# Use context-init skill or create manually
```

### Commit Hash Not Found

```bash
# List all [CONTEXT] commits to find correct hash
git log --oneline --grep="^\[CONTEXT\]"
```

### context-progress Branch Missing

```bash
# Recreate the branch
git checkout -b context-progress
git commit --allow-empty -m "[CONTEXT] Project Progress

## Completed ✓
- [x] Items here

## In Progress
- [ ] Items here

## Planned
- [ ] Items here
"
git checkout master
```

### Merge Conflicts on Progress Branch

```bash
# On context-progress after rebase conflict
git status  # See conflicts
# Resolve conflicts
git add .
git rebase --continue
git commit --amend  # Update progress
```

## Examples from Real Projects

See the `examples/` directory for real-world usage from:
- [Add your project here]

## Contributing

Contributions welcome! Please:
- Follow the existing skill format
- Add examples and documentation
- Test skills in real projects
- Submit PRs with clear descriptions

## License

MIT License - See LICENSE file

## Credits

Created by Kevin Vitale for use with Claude Code.

Inspired by the need for version-controlled, git-native project context management.

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Agent Skills Guide](https://code.claude.com/docs/en/skills)
- [Git Commit Message Best Practices](https://chris.beams.io/posts/git-commit/)

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the skill documentation in `skills/`

---

Made with Claude Code
