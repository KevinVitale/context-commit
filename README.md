# Context Commit

**Git-native project documentation that Claude reads automatically.**

Store requirements, workflows, and progress in git commits. No external docs. No sync issues. Claude loads everything on session start and resumes exactly where you left off.

## Why This Matters

- **Zero Setup Per Session**: Claude reads your project context automatically
- **Auto Session Resume**: Every commit captures your work state - new sessions know exactly what you were doing
- **Version Controlled**: Documentation evolves with your code
- **Team Shareable**: Context lives in the repository

## Quick Start

```bash
# 1. Install from marketplace
/plugin marketplace add KevinVitale/context-commit
/plugin install context-commit@context-commit-marketplace

# 2. Initialize in your project
# Claude: "Initialize context workflow"

# 3. Install hooks for automatic session capture
~/.claude/plugins/marketplaces/context-commit-marketplace/hooks/install-hooks.sh

# Done. Work normally - context is captured automatically.
```

## How It Works

**Three components:**

1. **CLAUDE.md** - Index file that Claude reads automatically
2. **[CONTEXT] commits** - Documentation stored in git commits with `[CONTEXT]` prefix
3. **context-progress branch** - Mutable progress tracking with auto-captured session state

**On every commit, the pre-commit hook automatically:**
- Captures what you're working on (commit message, files modified, recent work)
- Updates `context-progress` with a "Current Session" section
- Runs tests and keeps branches synchronized

**Result:** New Claude sessions instantly resume your work. No manual notes needed.

## Skills

Use these slash commands to manage your project context:

- `/context-init` - Set up the workflow in a repository
- `/context-add` - Add documentation (requirements, architecture, workflows)
- `/context-progress` - Manually update progress (hooks handle this automatically)
- `/context-read` - View all project context and current session

## Example CLAUDE.md

```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [e7b0129] Project requirements and technical specifications
 2. [ae291fc] Development workflow and TDD practices
 3. [context-progress] Current project progress (branch reference)

SESSION INITIALIZATION:
- Read the context-progress commit message using: `git log context-progress -1 --format=%B`
- Acknowledge that you have read and understood the project context
- Wait for the user's specific task request
```

Claude reads this automatically and loads all referenced commits.

## Automatic Session Capture

**Default behavior** (no action required):
```bash
git commit -m "Add JWT authentication"
# Hook automatically captures session state in context-progress
```

**Detailed notes** (for end-of-day commits):
```bash
CONTEXT_SESSION_PROMPT=1 git commit -m "Complete auth system"
# Prompts for accomplishments, next steps, blockers
```

**What gets captured:**
- Latest commit message and modified files
- Recent work (last 3 commits)
- Timestamp

**Example captured session:**
```markdown
## Current Session (2026-01-12 17:45)
**Latest Commit:** Add JWT token generation
**Files Modified:**
  - src/auth.ts
  - src/middleware/auth.ts

**Recent Work:**
- Add JWT token generation (abc1234)
- Update auth middleware (def5678)
```

New sessions read this and know exactly what you were doing.

## Git Hooks

Install with: `~/.claude/plugins/context-commit/hooks/install-hooks.sh`

**Included hooks:**
- `pre-commit` - Auto-captures session state, runs tests, enforces sync
- `commit-msg` - Validates [CONTEXT] commit format
- `post-commit` - Auto-generates progress.html visualization
- `pre-push` - Ensures context-progress is synced
- `prepare-commit-msg` - Provides templates

See `hooks/README.md` for details.

## Best Practices

**Creating [CONTEXT] commits:**
```bash
git commit --allow-empty -m "[CONTEXT] API Authentication Design

Uses JWT tokens with 15-minute expiry and refresh tokens.

## Implementation
- Access tokens in Authorization header
- Refresh tokens in httpOnly cookies
- Token rotation on refresh

## Security
- bcrypt for password hashing
- Rate limiting on auth endpoints
"
```

Then update CLAUDE.md to reference the commit hash.

**What belongs in [CONTEXT] commits:**
- Requirements and specifications (immutable)
- Architecture decisions (immutable)
- Workflows and standards (immutable)

**What belongs in context-progress:**
- Task checklists (mutable)
- Current session state (auto-captured)
- Work-in-progress notes (mutable)

## Auto-Extraction (New!)

Automatically extract structured progress from git history, inspired by `/compact`:

```bash
# Preview what will be extracted
~/.claude/plugins/context-commit/hooks/update-progress.sh --preview

# Update context-progress with auto-extracted content
~/.claude/plugins/context-commit/hooks/update-progress.sh

# Non-interactive mode (for CI/automation)
CONTEXT_SKIP_EDIT=1 ~/.claude/plugins/context-commit/hooks/update-progress.sh
```

**What gets auto-extracted:**

| Category | Description |
|----------|-------------|
| **Commits** | Categorized by type (feature, fix, test, refactor) |
| **File Changes** | Added, modified, deleted files |
| **Issues Resolved** | Commits containing "fix", "resolve", etc. |
| **Key References** | Functions, classes, structs added |

**Merge modes:**
- `smart` (default): Preserve your manual "In Progress" and "Planned" edits
- `replace`: Use only auto-extracted content
- `append`: Add auto-extracted as new section

```bash
CONTEXT_MERGE_MODE=replace ./update-progress.sh
```

## Manual Progress Updates (Optional)

Hooks handle this automatically. For manual control:

```bash
git checkout context-progress
git rebase master
git commit --amend  # Edit checklist
git checkout master
```

## Installation Methods

**Marketplace (Recommended):**
```bash
/plugin marketplace add KevinVitale/context-commit
/plugin install context-commit@context-commit-marketplace
```

**Git Clone:**
```bash
mkdir -p ~/.claude/plugins
git clone https://github.com/KevinVitale/context-commit.git ~/.claude/plugins/context-commit
```

## Team Collaboration

- Push [CONTEXT] commits normally - they're immutable
- Force-push `context-progress` branch - it's safe and expected
- Never force-push main/master
- Coordinate CLAUDE.md updates to avoid conflicts

## Troubleshooting

**CLAUDE.md not found:**
Run `/context-init` to create it.

**Missing commit hash:**
```bash
git log --oneline --grep="^\[CONTEXT\]"
```

**Missing context-progress branch:**
```bash
git checkout -b context-progress
git commit --allow-empty -m "[CONTEXT] Project Progress

## Completed ✓
- [x] Initial setup

## In Progress
- [ ] Your tasks

## Planned
- [ ] Future tasks
"
git checkout master
```

**Merge conflicts on rebase:**
```bash
git status  # See conflicts
# Resolve manually
git add .
git rebase --continue
git commit --amend
```

## Advanced Usage

**Multiple progress branches:**
```markdown
 - [context-progress-backend] Backend progress
 - [context-progress-frontend] Frontend progress
```

**Progress snapshots:**
```bash
git commit --allow-empty -m "[PROGRESS-SNAPSHOT] 2026-01-12

Milestone: MVP complete
"
```

**Categorized context:**
```markdown
 1. [abc123] [REQ] User authentication requirements
 2. [def456] [WORKFLOW] TDD practices
 3. [ghi789] [ARCH] Database schema decisions
```

## Templates

See `templates/` directory:
- `CLAUDE.md.template` - Starting template
- `context-commit-template.md` - [CONTEXT] commit template
- `progress-template.md` - Progress tracking template

## License

MIT License

## Support

- GitHub Issues: Report bugs or request features
- Documentation: `hooks/README.md`

---

Made with Claude Code
