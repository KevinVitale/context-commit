---
name: context-add
description: Add new [CONTEXT] commits to document workflows, requirements, or architectural decisions, then update CLAUDE.md references
---

# Add Context Commits

This skill guides you through creating new [CONTEXT] commits to document project knowledge and updating CLAUDE.md to reference them.

## When to Use

Use this skill when:
- Adding new project requirements or specifications
- Documenting a new workflow or process
- Recording architectural decisions
- Adding coding standards or conventions
- The user requests to "add context" or "document workflow"

## Steps to Add Context

### 1. Determine Context Type

Ask the user what type of context they want to add:
- **Requirements/Specifications**: Project goals, features, technical requirements
- **Workflows**: Development processes, TDD practices, deployment procedures
- **Architecture**: Design decisions, patterns, trade-offs, technical choices
- **Standards**: Coding conventions, style guides, best practices
- **Domain Knowledge**: Business logic, domain concepts, terminology

### 2. Create the [CONTEXT] Commit

Create an empty commit with [CONTEXT] prefix and detailed message:

```bash
git commit --allow-empty -m "[CONTEXT] Brief title here

Detailed explanation of the context.

## Section 1
- Point 1
- Point 2

## Section 2
- More details
- Guidelines
- Examples

## Notes
Additional information or rationale.
"
```

**Important**: Use `--allow-empty` to create documentation commits without file changes.

### 3. Get the Commit Hash

Retrieve the hash of the newly created commit:

```bash
git log -1 --format=%H
```

Or for abbreviated hash:

```bash
git log -1 --format=%h
```

### 4. Update CLAUDE.md

Read the current CLAUDE.md and add the new commit reference:

```bash
# Read current CLAUDE.md
cat CLAUDE.md
```

Add a new line to the context list with format:
```
 N. [commit-hash] Brief description
```

Maintain numbering sequence and keep context-progress as the last item.

### 5. Verify the Addition

Confirm the new context is accessible:

```bash
# Read the new context commit
git log [new-commit-hash] -1 --format=%B

# Verify CLAUDE.md updated
cat CLAUDE.md
```

## Best Practices

### Context Commit Guidelines

1. **Use [CONTEXT] Prefix**: Always start the commit message with `[CONTEXT]`
2. **Descriptive Titles**: First line should briefly summarize the context topic
3. **Structured Content**: Use markdown sections (##) to organize information
4. **Self-Contained**: Each commit should be complete and understandable on its own
5. **Immutable**: Once created, context commits should not be amended (create new ones instead)

### CLAUDE.md Organization

1. **Logical Ordering**: Group related context commits together
2. **Brief Descriptions**: Keep the reference line concise but clear
3. **Progress Last**: Always keep context-progress branch as the last reference
4. **Session Instructions**: Maintain clear SESSION INITIALIZATION section

### When to Create New vs Update Existing

**Create New Context Commit When:**
- Adding completely new topic or workflow
- Context represents a significant change in approach
- Want to preserve history of decision changes

**Update Existing (via new commit):**
- Refining or expanding existing context
- Correcting outdated information
- Evolution of a process or pattern

## Example Context Commit Types

### Requirements Example

```bash
git commit --allow-empty -m "[CONTEXT] API Authentication Requirements

The application must support multiple authentication methods:

## Supported Methods
- OAuth 2.0 (Google, GitHub)
- JWT tokens for API access
- API keys for service-to-service

## Security Requirements
- All tokens must expire within 24 hours
- Refresh tokens valid for 30 days
- Rate limiting: 1000 requests/hour per user

## Implementation Notes
- Use industry-standard libraries
- Store tokens securely (encrypted at rest)
- Implement token rotation
"
```

### Workflow Example

```bash
git commit --allow-empty -m "[CONTEXT] Code Review Process

All code changes must follow this review process:

## Steps
1. Create feature branch from main
2. Implement with tests (TDD required)
3. Self-review checklist before PR
4. Submit PR with description and test evidence
5. Address review feedback
6. Require 2 approvals before merge
7. Squash commits on merge

## Review Focus Areas
- Test coverage (minimum 80%)
- Code clarity and documentation
- Performance implications
- Security considerations

## Timeline
- Reviews should complete within 24 hours
- PRs open longer than 3 days need re-review
"
```

### Architecture Example

```bash
git commit --allow-empty -m "[CONTEXT] Database Architecture Decision

We chose PostgreSQL with the following schema design:

## Decision Rationale
- Need for complex queries and joins
- ACID compliance required
- Strong typing and constraints
- JSON support for flexible data

## Schema Pattern
- Normalized relational design for core entities
- JSONB columns for extensible metadata
- Separate schemas for multi-tenancy

## Trade-offs
- More complex migrations vs MongoDB flexibility
- Better data integrity vs NoSQL scalability
- Chose consistency over eventual consistency
"
```

## After Adding Context

Remind the user that:
- New context is immediately available via git log
- Claude will see it on next session (reads CLAUDE.md)
- Context commits are immutable - create new ones to update
- Push commits to share with team
