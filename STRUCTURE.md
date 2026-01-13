# Context Commit Plugin Structure

Complete file tree and component overview.

## Directory Structure

```
context-commit-plugin/
├── .claude-plugin/
│   └── plugin.json                   # Plugin metadata and configuration
│
├── hooks/                             # Git hooks for workflow enforcement
│   ├── README.md                      # Comprehensive hook documentation
│   ├── install-hooks.sh               # Hook installation script
│   ├── pre-commit                     # Test running + progress sync enforcement
│   ├── commit-msg                     # [CONTEXT] commit validation
│   ├── post-commit                    # Auto-generate progress.html
│   ├── prepare-commit-msg             # Commit message templates
│   ├── pre-push                       # Pre-push progress sync check
│   ├── safe-context-update.sh         # Safe progress update workflow
│   ├── recover-context-progress.sh    # Recovery from data loss
│   └── generate-progress-html.sh      # HTML generation helper
│
├── skills/                            # Claude Code skills
│   ├── context-init/
│   │   └── SKILL.md                   # Initialize workflow in repository
│   ├── context-add/
│   │   └── SKILL.md                   # Add new [CONTEXT] commits
│   ├── context-progress/
│   │   └── SKILL.md                   # Update progress tracking
│   └── context-read/
│       └── SKILL.md                   # Read and display context
│
├── templates/                         # Starter templates
│   ├── CLAUDE.md.template             # CLAUDE.md index file template
│   ├── context-commit-template.md     # [CONTEXT] commit message template
│   └── progress-template.md           # Progress tracking commit template
│
├── README.md                          # Full documentation
├── QUICKSTART.md                      # 5-minute setup guide
├── STRUCTURE.md                       # This file
├── LICENSE                            # MIT License
└── .gitignore                         # Git ignore rules
```

## Component Breakdown

### Plugin Metadata (13 lines)
- **plugin.json**: Name, version, author, skills list, tags

### Git Hooks (468 lines)
- **README.md**: 188 lines - Complete hook documentation
- **install-hooks.sh**: 43 lines - Symlink installer
- **pre-commit**: 75 lines - Test + sync enforcement
- **commit-msg**: 24 lines - Format validation
- **post-commit**: 61 lines - HTML generation + reminders
- **prepare-commit-msg**: 36 lines - Commit templates
- **pre-push**: 38 lines - Push-time sync check
- **safe-context-update.sh**: (helper script)
- **recover-context-progress.sh**: (recovery script)
- **generate-progress-html.sh**: (HTML generator)

### Skills (2,030 lines)
- **context-init**: 180 lines - Setup workflow
- **context-add**: 193 lines - Add context commits
- **context-progress**: 229 lines - Update progress
- **context-read**: 228 lines - Read context

### Templates (108 lines)
- **CLAUDE.md.template**: 10 lines
- **context-commit-template.md**: 28 lines
- **progress-template.md**: 54 lines

### Documentation (1,000+ lines)
- **README.md**: 450+ lines - Complete reference
- **QUICKSTART.md**: 230+ lines - Quick setup
- **STRUCTURE.md**: This file
- **LICENSE**: 21 lines - MIT

## Total Statistics

- **Total Lines**: ~2,619
- **Markdown Files**: 15
- **Shell Scripts**: 6
- **JSON Files**: 1
- **Skills**: 4
- **Hooks**: 5 (+ 3 helpers)
- **Templates**: 3

## Key Features

### Workflow Automation
- Git hooks enforce TDD and synchronization
- Auto-generation of progress visualization
- Automatic backup and recovery mechanisms

### Claude Integration
- Four specialized skills for different workflow stages
- Automatic context loading on session start
- Guided workflows for consistency

### Documentation
- Comprehensive README with examples
- Quick start guide for 5-minute setup
- Individual skill documentation
- Template files for all components

### Safety Features
- Automatic backup tags on context-progress
- Recovery scripts for data loss
- Protection against destructive operations
- Validation hooks for quality control

## Usage Flow

1. **Install Plugin** → Copy to ~/.claude/plugins/context-commit
2. **Initialize Project** → Use context-init skill or manual setup
3. **Install Hooks** → Run install-hooks.sh
4. **Add Context** → Use context-add skill to document
5. **Track Progress** → Use context-progress skill to update
6. **Read Context** → Use context-read skill to review
7. **Daily Work** → Hooks enforce workflow automatically

## Dependencies

- **Git**: Required for version control operations
- **Bash**: For hook scripts (standard on macOS/Linux)
- **Swift**: Only if using test-running hooks (project-specific)
- **Claude Code**: For skill integration

## Customization

The plugin can be customized for different project types:

- **Hooks**: Modify pre-commit to run different test commands
- **Skills**: Adjust templates and workflows
- **Templates**: Create project-specific templates
- **HTML Generation**: Customize progress.html styling

## Version

**Current Version**: 1.0.0
**Author**: Kevin Vitale
**License**: MIT
