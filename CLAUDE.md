# CLAUDE.md

Personal dotfiles repo for a macOS development environment (zsh, tmux, git, CLI tools).

## Key Scripts
- `mac_setup.sh` - Install Homebrew tools and symlink dotfiles
- `symlink_configs.sh` - Symlink configs to their proper locations
- `gwt.py` - Git worktree manager; creates worktrees in `~/worktrees/[repo]/[name]` and opens tmux windows

## Workflow
Centered around git worktrees + tmux. Use `gwt [name]` to create/switch worktrees, each in its own tmux window.
