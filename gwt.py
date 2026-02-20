#!/usr/bin/env python3
"""gwt — Manage git worktrees and tmux sessions

Usage:
  gwt create [NAME]   → create/reuse worktrees and generate a tmux session
  gwt delete [NAME]   → remove worktree NAME and kill its tmux session
  gwt clean           → remove worktrees whose upstream branch is gone
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


def parse_worktree_map() -> dict[str, str]:
    """Return a mapping of branch name → worktree path from porcelain output."""
    rc, porcelain = run_output(["git", "worktree", "list", "--porcelain"])
    if rc != 0:
        die("failed to list worktrees")
    branch_to_path: dict[str, str] = {}
    current_path = ""
    for line in porcelain.splitlines():
        if line.startswith("worktree "):
            current_path = line.split(" ", 1)[1]
        elif line.startswith("branch refs/heads/"):
            branch = line.split("refs/heads/", 1)[1]
            branch_to_path[branch] = current_path
    return branch_to_path


def cmd_clean(args: argparse.Namespace) -> None:
    rc, root = run_output(["git", "-C", ".", "rev-parse", "--show-toplevel"])
    if rc != 0:
        die("not inside a Git repository")
    os.chdir(root)

    # 1 — fetch and prune remote tracking branches
    print("gwt: fetching and pruning remotes...")
    run(["git", "fetch", "--prune"], check=True)

    # 2 — find worktree branches whose upstream is gone
    rc, out = run_output(["git", "branch", "-vv"])
    if rc != 0:
        die("failed to list branches")

    stale_branches: list[str] = []
    for line in out.splitlines():
        stripped = line.lstrip()
        if not stripped.startswith("+"):
            continue
        if ": gone]" not in line:
            continue
        branch = stripped[1:].lstrip().split()[0]
        stale_branches.append(branch)

    if not stale_branches:
        print("gwt: no stale worktrees found")
        return

    # 3 — resolve branch → worktree path
    branch_to_path = parse_worktree_map()
    stale_pairs: list[tuple[str, str]] = []
    for branch in stale_branches:
        path = branch_to_path.get(branch)
        if path and path != root:
            stale_pairs.append((branch, path))

    if not stale_pairs:
        print("gwt: no stale worktrees found")
        return

    # 4 — print and confirm
    print("gwt: the following stale worktrees will be removed:")
    for branch, path in stale_pairs:
        print(f"  branch={branch}  path={path}")
    answer = input("Proceed? [y/N] ").strip().lower()
    if answer != "y":
        print("gwt: aborted")
        return

    # 5 — remove each stale worktree
    for branch, path in stale_pairs:
        safe_session = branch.replace("/", "_").replace(".", "-").replace(":", "-")
        has_session = run(
            ["tmux", "has-session", "-t", safe_session],
            capture_output=True,
        ).returncode
        if has_session == 0:
            run(["tmux", "kill-session", "-t", safe_session], check=True)
            print(f"gwt: killed tmux session '{safe_session}'")

        if Path(path, ".git").exists():
            print(f"gwt: removing worktree '{path}'...")
            run(["git", "worktree", "remove", "--force", path], check=True)
            print(f"gwt: removed worktree '{path}'")

        run(["git", "branch", "-D", branch], check=True)
        print(f"gwt: deleted branch '{branch}'")

    run(["git", "worktree", "prune"], check=True)
    print("gwt: pruned worktree metadata")


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
    sub.add_parser(
        "clean", help="remove worktrees whose upstream branch is gone",
    )

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)
    elif args.command == "create":
        cmd_create(args)
    elif args.command == "delete":
        cmd_delete(args)
    elif args.command == "clean":
        cmd_clean(args)


if __name__ == "__main__":
    main()
