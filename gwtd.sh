#!/usr/bin/env bash
# gwtd — "git worktree delete + tmux kill"
#  ▸ gwtd NAME          → remove worktree NAME and kill its tmux session
#  ▸ gwtd               → pick an existing work-tree with fzf

set -euo pipefail

################################################################################
# 0 · ensure we're inside a Git repo and move to its root
################################################################################
root=$(git -C . rev-parse --show-toplevel 2>/dev/null) || {
  echo "gwtd: not inside a Git repository" >&2
  exit 1
}
cd "$root"
repo_name=$(basename "$root")
worktrees_base="$HOME/worktrees/$repo_name"

################################################################################
# 1 · pick the work-tree to remove
################################################################################
if [[ $# -eq 0 ]]; then
  command -v fzf >/dev/null 2>&1 || {
    echo "gwtd: fzf not found (needed for interactive selection)" >&2
    exit 1
  }

  wtdir=$(git worktree list --porcelain |
    awk '/^worktree / {print $2}' |
    grep -v "^${root}$" |
    fzf --prompt='Remove worktree ❯ ' --exit-0) || true

  [[ -n ${wtdir:-} ]] || exit 0
  name=$(basename "$wtdir")
else
  name=$1
  safe_name=${name//\//_}
  wtdir="$worktrees_base/$safe_name"
fi

################################################################################
# 2 · kill the tmux session if it exists
################################################################################
if tmux has-session -t "$name" 2>/dev/null; then
  tmux kill-session -t "$name"
  echo "gwtd: killed tmux session '$name'"
fi

################################################################################
# 3 · remove the worktree
################################################################################
if [ -e "$wtdir/.git" ]; then
  git worktree remove "$wtdir"
  echo "gwtd: removed worktree '$wtdir'"
else
  echo "gwtd: no worktree found at '$wtdir'"
fi
