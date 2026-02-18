# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files and setup scripts for a macOS development environment. The repository provides a comprehensive shell and development environment setup including tmux, zsh, git, and various CLI tools.

## Key Scripts and Commands

### Setup Commands
- `./mac_setup.sh` - Install essential development tools via Homebrew (fzf, gh, ripgrep, starship, ghostty, tmux, zoxide, nvim)
- `./symlink_configs.sh` - Create symbolic links for all configuration files to their proper locations
- `./git_setup.sh` - Configure git username and email for new repositories

### Git Worktree Management
- `./gwt.sh [NAME]` - Core script for git worktree management in tmux
  - `gwt NAME` - Create or switch to a worktree named NAME
  - `gwt` - Interactive worktree selection via fzf
  - Creates worktrees in `~/worktrees/[repo-name]/[worktree-name]`
  - Automatically creates tmux windows for each worktree

## Configuration Files Architecture

### Shell Environment (.zshrc)
- Oh-my-zsh with plugins: git, rust, docker, fzf, history, tmux
- Custom git_main_branch() function that intelligently detects main/master branches
- Lazy-loaded nvm for Node.js version management
- FZF integration with ripgrep for file searching
- Path setup for Homebrew, Go, Python, and Node.js

## Development Workflow

The repository is designed around a git worktree + tmux workflow:

1. Use `gwt [feature-name]` to create isolated worktrees for different features/branches
2. Each worktree gets its own tmux window
3. The main branch detection automatically handles repos using either `main` or `master`
4. Worktrees are organized in `~/worktrees/[repo-name]/` structure

## Environment Setup

### Prerequisites
- Oh-my-zsh framework

### Initial Setup Process
1. Clone this dotfiles repository
2. Run `./mac_setup.sh` to install tools and symlink dotfiles
3. Restart terminal or source ~/.zshrc

### Tool Dependencies
Essential tools that must be installed:
- fzf (fuzzy finder)
- ripgrep (fast grep replacement)
- tmux (terminal multiplexer)
- starship (shell prompt)
- zoxide (directory jumping)
- nvim (Neovim editor)
