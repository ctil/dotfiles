#!/usr/bin/env bash
# gwt — "git worktree in tmux"
#  ▸ gwt NAME          → create/reuse worktrees/NAME
#  ▸ gwt               → pick an existing work-tree with fzf

set -euo pipefail

################################################################################
# 0 · ensure we're inside a Git repo and move to its root
################################################################################
root=$(git -C . rev-parse --show-toplevel 2>/dev/null) || {
  echo "gwt: not inside a Git repository" >&2
  exit 1
}
cd "$root"
repo_name=$(basename "$root")
worktrees_base="$HOME/worktrees/$repo_name"
mkdir -p "$worktrees_base" # folder that holds our work-trees

################################################################################
# 1 · pick/create the work-tree
################################################################################
if [[ $# -eq 0 ]]; then
  # interactive *pick* via fzf
  command -v fzf >/dev/null 2>&1 || {
    echo "gwt: fzf not found (needed for interactive selection)" >&2
    exit 1
  }

  # list all work-tree paths (absolute) and feed them to fzf
  wtdir=$(git worktree list --porcelain |
    awk '/^worktree / {print $2}' |
    fzf --prompt='Worktree ❯ ' --exit-0)

  [[ -n ${wtdir:-} ]] || exit 0 # user pressed <Esc>
  name=$(basename "$wtdir")     # eg. worktrees/feature → feature
else
  # create/reuse worktrees/NAME
  name=$1
  safe_name=${name//\//_}
  wtdir="$worktrees_base/$safe_name"
fi

window="WT-$name"   # tmux window name
session="$name"      # tmux session named after the worktree

################################################################################
# 2 · figure out the repo's default branch for *new* work-trees
################################################################################
if git branch --format='%(refname:short)' | grep -q '^master$'; then
  main_branch=master
else
  main_branch=main
fi

################################################################################
# 3 · create the worktree if needed
################################################################################
if [ ! -e "$wtdir/.git" ]; then
  if git show-ref --verify --quiet "refs/heads/$name"; then
    git worktree add "$wtdir" "$name"
  else
    git worktree add -b "$name" "$wtdir" "$main_branch"
  fi
fi

################################################################################
# 4 · inside-tmux vs. outside-tmux workflow
################################################################################
# Create session if it doesn't exist
if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -n "$window" -c "$wtdir"
fi

# Create window if it doesn't exist in the session
if ! tmux list-windows -t "$session" -F '#{window_name}' | grep -Fxq "$window"; then
  tmux new-window -t "$session" -n "$window" -c "$wtdir"
fi

if [[ -n ${TMUX:-} ]]; then
  # Inside tmux: switch to the session/window
  tmux switch-client -t "$session:$window"
else
  # Outside tmux: attach to the session
  tmux attach -t "$session:$window"
fi
