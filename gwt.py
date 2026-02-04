#!/usr/bin/env python3
"""gwt — Manage git worktrees and tmux sessions

Usage:
  gwt create [NAME]   → create/reuse worktrees and generate a tmux session
  gwt delete [NAME]   → remove worktree NAME and kill its tmux session
  gwt                  → show help
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, NoReturn

WORKTREES_BASE = Path.home() / "worktrees"

# The first tmux window will be called WT-{name}. These are additional windows that will be created.
TMUX_WINDOWS = ["shell", "claude"]


def run(cmd: list[str], **kwargs: Any) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, **kwargs)


def run_output(cmd: list[str]) -> tuple[int, str]:
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.returncode, r.stdout.strip()


def die(msg: str) -> NoReturn:
    print(f"gwt: {msg}", file=sys.stderr)
    sys.exit(1)


def detect_main_branch() -> str:
    rc, branches = run_output(["git", "branch", "--format=%(refname:short)"])
    if rc != 0:
        die("failed to list branches")
    for line in branches.splitlines():
        if line == "master":
            return "master"
    return "main"


def fzf_pick_worktree() -> tuple[str, str]:
    if not shutil.which("fzf"):
        die("fzf not found (needed for interactive selection)")

    rc, porcelain = run_output(["git", "worktree", "list", "--porcelain"])
    if rc != 0:
        die("failed to list worktrees")

    paths = []
    for line in porcelain.splitlines():
        if line.startswith("worktree "):
            paths.append(line.split(" ", 1)[1])

    if not paths:
        die("no worktrees found")

    fzf = subprocess.run(
        ["fzf", "--prompt=Worktree ❯ ", "--exit-0"],
        input="\n".join(paths),
        capture_output=True,
        text=True,
    )

    if fzf.returncode != 0 or not fzf.stdout.strip():
        sys.exit(0)  # user pressed Esc

    wtdir = fzf.stdout.strip()
    rc, name = run_output(
        ["git", "-C", wtdir, "rev-parse", "--abbrev-ref", "HEAD"])
    if rc != 0:
        die(f"failed to get branch name for {wtdir}")
    return wtdir, name


def fzf_pick_worktree_delete(root: str) -> tuple[str, str]:
    if not shutil.which("fzf"):
        die("fzf not found (needed for interactive selection)")

    rc, porcelain = run_output(["git", "worktree", "list", "--porcelain"])
    if rc != 0:
        die("failed to list worktrees")

    paths = []
    for line in porcelain.splitlines():
        if line.startswith("worktree "):
            path = line.split(" ", 1)[1]
            if path != root:
                paths.append(path)

    if not paths:
        die("no non-root worktrees found")

    fzf = subprocess.run(
        ["fzf", "--prompt=Remove worktree ❯ ", "--exit-0"],
        input="\n".join(paths),
        capture_output=True,
        text=True,
    )

    if fzf.returncode != 0 or not fzf.stdout.strip():
        sys.exit(0)  # user pressed Esc

    wtdir = fzf.stdout.strip()
    name = Path(wtdir).name
    return wtdir, name


def cmd_create(args: argparse.Namespace) -> None:
    # 0 — ensure we're in a git repo
    rc, root = run_output(["git", "-C", ".", "rev-parse", "--show-toplevel"])
    if rc != 0:
        die("not inside a Git repository")
    os.chdir(root)

    repo_name = Path(root).name
    worktrees_base = WORKTREES_BASE / repo_name
    worktrees_base.mkdir(parents=True, exist_ok=True)

    # 1 — pick or create the worktree
    if args.name is None:
        wtdir, name = fzf_pick_worktree()
    else:
        name = args.name
        safe_name = name.replace("/", "_")
        wtdir = str(worktrees_base / safe_name)

    safe_session = name.replace("/", "_").replace(".", "-").replace(":", "-")

    # 2 — detect main branch
    main_branch = detect_main_branch()

    # 3 — create worktree if needed
    if not Path(wtdir, ".git").exists():
        rc, _ = run_output(
            ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{name}"]
        )
        if rc == 0:
            run(["git", "worktree", "add", wtdir, name], check=True)
        else:
            run(
                ["git", "worktree", "add", "-b", name, wtdir, main_branch],
                check=True,
            )

    # 4 — create tmux session if needed, then switch/attach
    has_session = run(
        ["tmux", "has-session", "-t", safe_session],
        capture_output=True,
    ).returncode
    if has_session != 0:
        run(
            ["tmux", "new-session", "-d", "-s", safe_session,
                "-n", f"WT-{safe_session}", "-c", wtdir],
            check=True,
        )
        for win in TMUX_WINDOWS:
            run(
                ["tmux", "new-window", "-t", safe_session, "-n", win, "-c", wtdir],
                check=True,
            )
        run(["tmux", "select-window", "-t",
            f"{safe_session}:WT-{safe_session}"], check=True)

    if os.environ.get("TMUX"):
        run(["tmux", "switch-client", "-t", safe_session], check=True)
    else:
        run(["tmux", "attach", "-t", safe_session], check=True)


def cmd_delete(args: argparse.Namespace) -> None:
    # 0 — ensure we're in a git repo
    rc, root = run_output(["git", "-C", ".", "rev-parse", "--show-toplevel"])
    if rc != 0:
        die("not inside a Git repository")
    os.chdir(root)

    repo_name = Path(root).name
    worktrees_base = WORKTREES_BASE / repo_name

    # 1 — pick the worktree to remove
    if args.name is None:
        wtdir, name = fzf_pick_worktree_delete(root)
    else:
        name = args.name
        safe_name = name.replace("/", "_")
        wtdir = str(worktrees_base / safe_name)

    # 2 — kill tmux session if it exists
    safe_session = name.replace("/", "_").replace(".", "-").replace(":", "-")
    has_session = run(
        ["tmux", "has-session", "-t", safe_session],
        capture_output=True,
    ).returncode
    if has_session == 0:
        run(["tmux", "kill-session", "-t", safe_session], check=True)
        print(f"gwt: killed tmux session '{safe_session}'")

    # 3 — remove the worktree
    if Path(wtdir, ".git").exists():
        run(["git", "worktree", "remove", wtdir], check=True)
        print(f"gwt: removed worktree '{wtdir}'")
    else:
        print(f"gwt: no worktree found at '{wtdir}'")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="gwt — git worktree in tmux",
    )
    sub = parser.add_subparsers(dest="command")

    p_create = sub.add_parser(
        "create", help="create or switch to a worktree"
    )
    p_create.add_argument(
        "name",
        nargs="?",
        help="worktree/branch name (omit for interactive fzf picker)",
    )

    p_delete = sub.add_parser(
        "delete", help="remove a worktree and kill its tmux session"
    )
    p_delete.add_argument(
        "name",
        nargs="?",
        help="worktree name to remove (omit for interactive fzf picker)",
    )

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)
    elif args.command == "create":
        cmd_create(args)
    elif args.command == "delete":
        cmd_delete(args)


if __name__ == "__main__":
    main()
