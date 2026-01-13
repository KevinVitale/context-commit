# [CONTEXT] Prompting: A Git-Based Knowledge System for AI-Assisted Development

> **🚀 Update**: A [Claude Code plugin](https://github.com/KevinVitale/context-commit) now automates this entire workflow with slash commands and git hooks. Jump to the [Automation section](#automation-the-claude-code-plugin) to get started quickly, or read on to understand the concepts behind the approach.

## The Problem: AI Context Amnesia

If you've worked with AI coding assistants like Claude, ChatGPT, or GitHub Copilot, you've experienced a frustrating reality: **every new chat session starts from zero**. The AI doesn't remember your project's architecture, your coding standards, or the work you did yesterday. You end up repeating the same context over and over:

- "This is a Swift Entity Component System framework"
- "We're using TDD with strict concurrency"
- "We have 102 passing tests"
- "The query caching system works like this..."

Each session burns tokens and time re-explaining what should already be known.

## The Solution: [CONTEXT] Commits

What if your project could **teach itself** to new AI sessions? What if context wasn't stored in external systems or proprietary tools, but right in your **git history** where it belongs?

That's what [CONTEXT] commits do.

## What Are [CONTEXT] Commits?

[CONTEXT] commits are special git commits that store structured project knowledge. They follow a simple convention:

```bash
git commit -m "[CONTEXT] Project requirements and technical specifications

SPECIFICATIONS:
- Swift 6 with strict concurrency enabled
- Entity Component System architecture
- Test-driven development workflow
- Performance target: <1ms queries for 1000 entities

ARCHITECTURE:
- Entity: UUID-based lightweight identifiers
- Component: Sendable marker protocol for data
- System: Protocol for behavior logic
- World: Central coordinator with thread-safe operations
..."
```

The `[CONTEXT]` prefix signals that this commit contains **knowledge**, not code changes. Think of them as executable documentation that AI assistants can quickly parse and understand.

## How It Works

### 1. CLAUDE.md: The AI's Instruction Manual

At your project root, create a `CLAUDE.md` file:

```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [e7b0129] Project requirements and technical specifications
 2. [ae291fc] Context pattern explanation
 3. [7cc3e39] Strict TDD workflow
 4. [c8da0e3] Progress tracking workflow
 5. [context-progress] Current project progress (branch)

SESSION INITIALIZATION:
- Acknowledge that you have read and understood the project context
- Wait for the user's specific task request
```

When Claude starts a new session, it reads `CLAUDE.md` and immediately fetches those commit messages. In seconds, it has your entire project context.

### 2. Structured Knowledge in Commits

Each [CONTEXT] commit focuses on one aspect:

**Requirements & Specs** (`e7b0129`):
- Technical requirements
- Architecture decisions
- Performance targets
- Platform requirements

**TDD Workflow** (`7cc3e39`):
- Testing requirements
- What to test first
- Test naming conventions
- When tests are required

**Progress Tracking** (`context-progress` branch):
- ✅ Completed features (102 tests passing)
- ⏳ In progress work
- 📋 Future enhancements
- 📊 Performance achievements

### 3. The context-progress Branch

This is where it gets powerful. Create a dedicated branch that tracks only progress:

```bash
git checkout -b context-progress
git commit --allow-empty -m "[CONTEXT] ECSKit Project Progress

## Completed ✓
- [x] Entity system with UUID-based identification
- [x] Component protocol (Sendable marker)
- [x] Advanced query system (1-3 components, optionals, exclusions)
- [x] Query caching with automatic invalidation
- [x] Packed component arrays (28-103x faster mutations)
- [x] 102 tests across 12 test suites - ALL PASSING

## In Progress / To Do
- [ ] Example game demo
- [ ] Interactive benchmark suite
..."
```

The context-progress branch is always **one commit ahead** of master, containing the latest project state. AI sessions can reference it instantly.

## Real-World Example: ECSKit

Let's see [CONTEXT] prompting in action with ECSKit, a high-performance Entity Component System framework:

### Before [CONTEXT] Prompting

**User:** "Help me add documentation to my ECS framework"

**Claude:** "I'd be happy to help! First, could you tell me about your framework? What does it do? What's the architecture? What features are implemented? What's the performance like?"

*5 minutes of back-and-forth explaining the project...*

### After [CONTEXT] Prompting

**User:** "Help me add documentation to my ECS framework"

**Claude:** *Reads CLAUDE.md, fetches 5 [CONTEXT] commits in 10 seconds*

"I've reviewed your ECSKit project context:
- Production-ready Swift 6 ECS with 102 passing tests
- Query performance: 0.59ms for 1k entities
- 28-103x speedup with packed arrays
- Full concurrency support

I'll create comprehensive DocC documentation highlighting these performance achievements. I'll include:
1. README with quick start (showing your proven API patterns)
2. 6 DocC articles (covering your advanced query system)
3. Performance guide (documenting your actual benchmarks)

Ready to proceed?"

**The AI already knows everything**. No explanation needed.

## The Architecture

### Git Hooks for Automation

Enforce [CONTEXT] commit quality with hooks:

```bash
# hooks/commit-msg
if [[ $COMMIT_MSG =~ ^\[CONTEXT\] ]]; then
    LINE_COUNT=$(wc -l < "$1")
    if [ "$LINE_COUNT" -lt 5 ]; then
        echo "❌ [CONTEXT] commits must be detailed (5+ lines)"
        exit 1
    fi
fi
```

### Progress Tracking Hook

Auto-generate visualizations from [CONTEXT] commits:

```bash
# hooks/post-commit (on context-progress branch)
# Generates progress.html from markdown checklist
# Automatically amends commit to include visualization
```

### Branch Protection

Two layers of enforcement protect the workflow:

```bash
# Pre-commit hook (first line of defense):
- Validates context-progress is in sync BEFORE committing
- Prevents non-[CONTEXT] commits on context-progress
- Creates automatic backup tags before destructive operations

# Pre-push hook (enforces synchronization):
- Blocks pushes to master if context-progress is out of sync
- Catches the gap where you commit then immediately push
- Ensures remote always has synchronized branches
```

The two-hook approach is necessary because pre-commit checks sync status *before* the commit happens. If you commit then immediately push, pre-commit passed but context-progress is now behind. Pre-push blocks this at push time.

## Benefits

### 1. **Instant Context Loading**
New sessions get full project understanding in seconds, not minutes.

### 2. **Version-Controlled Knowledge**
Project knowledge lives in git, not external tools. It follows your code everywhere.

### 3. **Self-Documenting Repositories**
The git history *is* the documentation. No separate wiki to maintain.

### 4. **Cross-Session Continuity**
Different AI instances (or even different AI models) can pick up where others left off.

### 5. **Historical Context**
See not just what the code is, but **why decisions were made**:

```bash
git show ae291fc  # Why we chose this architecture
git show 7cc3e39  # Why we require tests first
```

### 6. **Reduced Token Usage**
Instead of re-explaining context in every message, load it once at session start.

## Implementation Guide

### Step 1: Create CLAUDE.md

```markdown
READ THESE COMMIT MESSAGES FOR CONTEXT:
 1. [abc1234] Project requirements
 2. [def5678] Architecture decisions
 3. [context-progress] Current progress (branch)

SESSION INITIALIZATION:
- Read and acknowledge context above
- Wait for user's task request
```

### Step 2: Write Your First [CONTEXT] Commit

```bash
git commit --allow-empty -m "[CONTEXT] Project requirements and technical specifications

PROJECT: YourAwesomeProject
PURPOSE: [Brief description]

TECHNICAL REQUIREMENTS:
- Language/Framework: [Your stack]
- Key dependencies: [List]
- Coding standards: [Your standards]

ARCHITECTURE:
[High-level architecture overview]

PERFORMANCE TARGETS:
[Any performance goals]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### Step 3: Create context-progress Branch

```bash
git checkout -b context-progress
git commit --allow-empty -m "[CONTEXT] Project Progress

## Completed ✓
- [x] Initial setup
- [x] Core functionality

## In Progress
- [ ] Feature X
- [ ] Feature Y

## To Do
- [ ] Future enhancement"

git checkout main
```

### Step 4: Install Git Hooks (Optional but Recommended)

Create hooks to:
- Validate [CONTEXT] commit format
- Keep context-progress synchronized
- Generate progress visualizations

See the [ECSKit hooks directory](https://github.com/KevinVitale/ECSKit/tree/master/hooks) for reference implementations.

## Advanced Patterns

### Documentation [CONTEXT] Commits

After completing major work, create a [CONTEXT] commit documenting the resources:

```bash
git commit --allow-empty -m "[CONTEXT] Documentation structure and resources

DOCUMENTATION OVERVIEW:
1. README.md (5.2KB)
   - Quick start with working code example
   - Performance highlights

2. Inline API Documentation
   - All public types documented with /// comments
   - Located in: Sources/*/

3. DocC Catalog
   - 6 comprehensive articles
   - Performance guide with benchmarks

KEY PERFORMANCE NUMBERS:
- Query speed: 0.59ms / 1k entities
- Mutation speed: 28-103x faster than baseline

DOCUMENTATION COMMANDS:
- Generate: swift package generate-documentation
- Preview: swift package --disable-sandbox preview-documentation"
```

Future sessions can instantly locate and understand all documentation.

### Multi-Project Knowledge Sharing

[CONTEXT] commits are just git commits. You can:

```bash
# Cherry-pick knowledge from other projects
git cherry-pick other-project:abc1234

# Create [CONTEXT] commit templates
git config commit.template .gitmessage-context
```

### AI-Assisted Context Updates

Let the AI help maintain [CONTEXT] commits:

**User:** "We just finished implementing the query caching system. Update the progress."

**Claude:** *Updates context-progress branch with new checkmarks, regenerates progress.html*

## Real Results

From the ECSKit project:

- **Before:** 5-10 minute onboarding per session
- **After:** 10-20 second context loading
- **Token savings:** ~5,000 tokens per session (saved from repeated explanations)
- **Continuity:** Seamless handoffs between sessions
- **Documentation:** Git history serves as complete project narrative

With automatic session capture (plugin):

- **Session resumption:** Zero onboarding - sessions pick up mid-task instantly
- **Workflow friction:** None - capture happens automatically on every commit
- **Context accuracy:** Always current - reflects exact work state, not stale docs
- **Developer overhead:** Zero - no manual progress updates needed

## Comparison with Other Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **External context files** | Simple | Not versioned with code, easy to get out of sync, no session tracking |
| **Project wikis** | Rich formatting | Separate system, overhead to maintain, manual updates |
| **Long system prompts** | Works everywhere | Static, not version-controlled, no work-in-progress tracking |
| **[CONTEXT] commits (manual)** | ✅ Versioned, ✅ AI-friendly, ✅ Self-documenting | Requires discipline, manual updates |
| **[CONTEXT] commits + plugin** | ✅ All above, ✅ **Auto session capture**, ✅ Zero friction | Requires git hooks setup |

## Critical Analysis: Is This Overengineered?

After developing and using this approach, it's important to address legitimate criticisms. Here's a balanced look at concerns you might have.

### The Skeptic's View

**"This is git abuse"**
> Git is for code, not documentation. [CONTEXT] commits pollute the history with non-functional changes. A simple `docs/PROJECT_CONTEXT.md` file would do the same thing without the ceremony.

**"Overcomplicated workflow"**
> The context-progress branch requires rebasing, backup tags, special hooks, and recovery scripts. For what? Just to avoid a markdown file? This is solving a problem that doesn't exist.

**"Merge conflict risks"**
> Multiple developers updating context-progress from different branches creates merge conflicts in the progress commit. Git wasn't designed for this collaborative documentation pattern.

**"Maintenance burden"**
> You need to maintain git hooks, backup systems, and special workflows. On a team, everyone needs to learn these conventions. That's friction.

### What the Critique Gets Right

1. **Simpler alternatives exist** - A `PROJECT_CONTEXT.md` file *can* work for many projects. If you have a small codebase and rarely switch AI tools, the added complexity may not be worth it.

2. **Git philosophy concerns are valid** - Git purists have a point: commits should represent atomic code changes. Using commits for documentation metadata is unconventional.

3. **Team coordination unspecified** - The blog post doesn't address how multiple developers coordinate [CONTEXT] updates. This is a gap in solo-developer-focused documentation.

4. **Setup complexity** - The hooks, backup scripts, and recovery mechanisms add cognitive load. This isn't "just git" - it's git plus custom tooling.

### What the Critique Gets Wrong

1. **"Merge conflicts with context-progress"** - This misunderstands the workflow. The branch is rebased, not merged:
   ```bash
   git checkout context-progress
   git rebase master  # Replays the single progress commit on top
   git commit --amend # Update the progress
   ```
   There are no merge conflicts because context-progress is always exactly one commit ahead. Multiple developers work on master and rebase context-progress after their changes merge.

2. **"Same thing as a markdown file"** - Not quite. Key differences:
   - Git history: `git log --grep="\[CONTEXT\]"` shows evolution of decisions
   - Searchability: `git show ae291fc` instantly loads any past context state
   - Tool independence: Works with any AI that can read git (not just those that read project files)
   - Atomicity: Context is versioned with the code state it describes

3. **"Solves a problem that doesn't exist"** - From ECSKit results:
   - 5-10 minute onboarding → 10-20 seconds (measured across 15+ sessions)
   - ~5,000 tokens saved per session
   - Zero context loss when switching between Claude, ChatGPT, and GitHub Copilot

   These are real, measured improvements.

### Where Both Views Have Merit

**Git Philosophy: Pragmatist vs Purist**
- **Purist:** "Git commits should only contain code changes"
- **Pragmatist:** "Git is a version control system for *project artifacts*, including knowledge"

Both perspectives are valid. The [CONTEXT] approach is pragmatic at the cost of conventional purity.

**Complexity vs Power Tradeoff**
- **Simple approach:** `PROJECT_CONTEXT.md` - Easy to understand, no hooks needed
- **Power approach:** [CONTEXT] commits - Version history, searchability, tool independence

Choose based on your project's needs. For a 500-line script? Overkill. For a multi-month framework with 102 tests and evolving architecture? The power is worth it.

### When to Use [CONTEXT] Commits

✅ **Good fit:**
- Medium to large codebases (>5k lines)
- Long-running projects (weeks to months)
- Projects that switch between AI tools
- Solo developers or small teams with good git hygiene
- Projects where "why" matters as much as "what"

❌ **Not worth it:**
- Small scripts or one-off projects
- Teams with weak git practices
- Projects with simple, stable requirements
- When your AI tool doesn't support reading git commits
- Strict "commits must be code" team policies

### The Real Question

It's not "Is [CONTEXT] prompting better than markdown files?"

It's "Does version-controlled, searchable, tool-independent context deliver enough value to justify the workflow overhead *for your project*?"

For ECSKit, the answer was yes. The framework has:
- 102 tests across 12 suites
- 28-103x performance optimizations
- Complete documentation written in one session with full context
- Seamless handoffs across multiple AI sessions

That complexity demanded the power of [CONTEXT] commits. Your mileage may vary.

## Automation: The Claude Code Plugin

Since developing the [CONTEXT] prompting approach, I've created a **Claude Code plugin** that automates the entire workflow with slash commands and git hooks.

### Plugin Features

The `context-commit` plugin provides:

**Four Specialized Skills:**
- `/context-init` - Initialize CLAUDE.md and context-progress branch
- `/context-add` - Create new [CONTEXT] commits and update references
- `/context-progress` - Update progress tracking with automatic rebasing
- `/context-read` - Load and summarize all project context

**Comprehensive Git Hooks:**
- Pre-commit: Run tests, enforce synchronization, **automatic session capture**
- Commit-msg: Validate [CONTEXT] format (5+ lines)
- Post-commit: Auto-generate progress.html visualization
- Pre-push: Ensure context-progress is synced
- Recovery tools for accidental data loss

### Automatic Session Capture: The Resume Feature

The plugin now includes **automatic session capture** - solving the "how do I pick up where I left off?" problem.

**The Problem:**
Even with [CONTEXT] commits documenting your architecture and requirements, when you start a new Claude session after a few hours or days, you still have to explain:
- "I was working on the authentication system"
- "I just implemented JWT tokens"
- "Next I need to add refresh token logic"

**The Solution:**
Every commit automatically captures your **current session state** in context-progress:

```markdown
## Current Session (2026-01-12 17:45)
**Latest Commit:** Add JWT token generation
**Files Modified:**
  - src/auth.ts
  - src/middleware/auth.ts

**Recent Work:**
- Add JWT token generation (commit: abc1234)
- Update auth middleware (commit: def5678)

**Next Steps:**
- Add refresh token logic
- Write auth middleware tests
```

**How It Works:**
1. You make changes and commit normally: `git commit -m "Add JWT tokens"`
2. Pre-commit hook automatically captures session state
3. Context-progress updates with "Current Session" section
4. New Claude sessions read this and **instantly resume** where you left off

**Interactive Mode** for detailed notes:
```bash
CONTEXT_SESSION_PROMPT=1 git commit -m "Add JWT tokens"
```
You'll be prompted for accomplishments, next steps, and blockers - perfect for end-of-day commits.

**Result:** Zero-friction session tracking. Every commit becomes a resumption point. New sessions understand not just your architecture, but exactly where you are in active development.

### Installation

```bash
# Clone the plugin to your Claude Code plugins directory
mkdir -p ~/.claude/plugins
cd ~/.claude/plugins
git clone https://github.com/KevinVitale/context-commit.git

# In your project, initialize the workflow
/context-init

# Install git hooks (optional but recommended)
~/.claude/plugins/context-commit/hooks/install-hooks.sh
```

### Quick Workflow with Plugin

```bash
# Initialize once per project
/context-init

# Add context as needed
/context-add "Explain your API authentication workflow"

# Update progress regularly
/context-progress "Completed authentication, started dashboard"

# Load context in new sessions
/context-read
```

The plugin handles all the git commands, validation, and bookkeeping automatically.

## Getting Started

### Option 1: Use the Plugin (Recommended)

1. **Install the plugin** - Follow installation steps above
2. **Initialize your project** - Run `/context-init` in your repo
3. **Add context** - Use `/context-add` after completing features
4. **Track progress** - Use `/context-progress` to update status

### Option 2: Manual Setup

1. **Start small** - Just add a CLAUDE.md with one [CONTEXT] commit
2. **Add as you go** - After completing major features, document them
3. **Let the AI help** - Ask your AI assistant to create [CONTEXT] commits
4. **Iterate** - Refine the format based on what works for your project

## Conclusion

[CONTEXT] prompting turns your git repository into an **AI knowledge base**. Instead of fighting context limits and session amnesia, you get:

- **Instant project understanding** for new sessions
- **Version-controlled knowledge** that evolves with your code
- **Self-documenting repositories** that tell their own story
- **Seamless handoffs** between AI sessions
- **Session resumption** - New sessions pick up exactly where you left off

The best part? It's just git. No vendor lock-in, no external services, no special tools. Just commits with a [CONTEXT] prefix.

With the Claude Code plugin's automatic session capture, you get the holy grail: **true session continuity**. Stop mid-thought, commit your work, and the next Claude session understands not just your codebase architecture, but exactly what you were doing and what comes next.

Your repository becomes not just a code archive, but a **knowledge archive** - one that AI assistants can navigate as easily as developers do.

---

## Try It Yourself

The `context-commit` Claude Code plugin automates everything:

- **Plugin Repository**: [github.com/KevinVitale/context-commit](https://github.com/KevinVitale/context-commit)
- **Documentation**: Full README with installation and usage
- **Git Hooks**: Automated workflow enforcement
- **Skills**: Four slash commands for the complete workflow

```bash
# Get started in 30 seconds
mkdir -p ~/.claude/plugins
cd ~/.claude/plugins
git clone https://github.com/KevinVitale/context-commit.git
# Then in your project: /context-init
```

Or see the complete ECSKit implementation with example [CONTEXT] commits: [github.com/KevinVitale/ECSKit](https://github.com/KevinVitale/ECSKit)

**Happy context building!**

---

*This approach was developed while building ECSKit, a production-ready Entity Component System framework for Swift. After implementing [CONTEXT] commits, documentation that would have taken multiple sessions was completed in one, with the AI maintaining full context throughout.*

*Co-authored by Kevin Vitale and Claude Sonnet 4.5*
