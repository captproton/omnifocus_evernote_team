# CLAUDE.md

This file provides guidance to AI coding assistants when working with code in this repository.

## Using This Documentation

**For Claude Code users:**
- Use slash commands: `/new-pr` and `/new-article` in `.claude/commands/`
- This file provides the coding standards and architecture context

**For GitHub Copilot users:**
- Reference `.github/copilot/new-pr-instructions.md` for PR workflow
- Reference `.github/copilot/new-article-instructions.md` for content generation
- Use: `@workspace start new PR using .github/copilot/new-pr-instructions.md`
- This file (CLAUDE.md) will be automatically read for coding standards

## Development Philosophy

This project follows two core principles:

### Sandi Metz Principles (Ruby Object-Oriented Design)
- **Small methods**: Keep methods to 5 lines or fewer when practical.
- **Single Responsibility Principle**: Classes and methods should do one thing well.
- **Prefer composition over inheritance**: Use modules and delegation.
- **Intention-revealing names**: Code should read like well-written prose.
- **Objects collaborate by sending messages**: Focus on behavior, not data.
- **SOLID principles**: Make code that is easy to change and reason about.

### Test-Driven Development (TDD)
- **Always write tests first** before implementing new CLI features.
- Follow the **Red-Green-Refactor** cycle.

## Overview

`omnifocus_obsidian_team` is a Ruby-based Command Line Interface (CLI) application built using the `Thor` gem. 
Its primary purpose is to orchestrate cross-platform project setups by:
1. Generating local file system directories.
2. Creating local markdown notes (Obsidian).
3. Orchestrating project creation in OmniFocus via deep links.
4. Tying them all together with `.inetloc` macOS shortcut files.

## Technology Stack
- **Ruby** (Core language)
- **Thor** (CLI framework)
- **Nokogiri** (XML building for `.inetloc` files)

## Development Commands

```bash
# Run the main CLI tool
bundle exec ruby project_action

# Testing (if RSpec is configured)
bundle exec rspec 
```

## Pull Request Workflow

When starting work on a new feature, use the Advanced Worktree Workflow for isolation.

### Advanced: Worktree Workflow

**1. Preparation**
```bash
git checkout develop
git pull origin develop
```

**2. Create Worktree**
```bash
# Creates isolated directory with new branch
git worktree add ../omnifocus_worktrees/issue_<NUM> -b feature/issue_<NUM>_pr_<PR_NUM>

# Navigate to worktree
cd ../omnifocus_worktrees/issue_<NUM>
```

### Critical: Working Directory Management ⚠️

**The Bash tool resets working directory after each command execution.**
Always use absolute paths when working in worktrees.

```bash
# 1. Calculate absolute path once at the beginning
WORKTREE_PATH="${HOME}/ruby_apps/omnifocus_worktrees/issue_<NUM>"

# 2. Use absolute path with EVERY git command
cd $WORKTREE_PATH && git add .
cd $WORKTREE_PATH && git commit -m "Add feature"
cd $WORKTREE_PATH && git push -u origin feature/issue_<NUM>_pr_<PR_NUM>
```

### GitHub API Usage

When `gh` CLI is not available, use the GitHub API directly:

```bash
# Create Pull Request
curl -s -X POST \
  -H "Authorization: token YOUR_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/captproton/omnifocus_obsidian_team/pulls \
  -d '{
    "title": "PR Title",
    "head": "feature-branch",
    "base": "develop",
    "body": "PR description"
  }'
```
