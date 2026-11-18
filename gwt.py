#!/usr/bin/env python3
"""gwt — Manage git worktrees and tmux/rex sessions

Uses rex when run inside the rex multiplexer ($REX_SESSION is set), tmux otherwise.

Usage:
  gwt create NAME     → create a worktree and multiplexer session
  gwt delete [NAME]   → remove worktree NAME and kill its session
  gwt switch          → switch between worktrees
  gwt clean           → remove worktrees whose upstream branch is gone
  gwt                  → show help
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Any, NoReturn

WORKTREES_BASE = Path.home() / "worktrees"

# The first window/tab will be called WT-{name}. These are additional windows that will be created.
EXTRA_WINDOWS = ["shell", "claude"]


def run(cmd: list[str], **kwargs: Any) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, **kwargs)


def run_output(cmd: list[str]) -> tuple[int, str]:
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.returncode, r.stdout.strip()


def die(msg: str) -> NoReturn:
    print(f"gwt: {msg}", file=sys.stderr)
    sys.exit(1)


class Tmux:
    name = "tmux"

    def has_session(self, session: str) -> bool:
        return run(["tmux", "has-session", "-t", session],
                   capture_output=True).returncode == 0

    def create_session(self, session: str, cwd: str) -> None:
        run(["tmux", "new-session", "-d", "-s", session,
             "-n", f"WT-{session}", "-c", cwd], check=True)
        for win in EXTRA_WINDOWS:
            run(["tmux", "new-window", "-t", session, "-n", win, "-c", cwd],
                check=True)
        run(["tmux", "select-window", "-t", f"{session}:WT-{session}"],
            check=True)

    def switch_to(self, session: str) -> None:
        if os.environ.get("TMUX"):
            run(["tmux", "switch-client", "-t", session], check=True)
        else:
            run(["tmux", "attach", "-t", session], check=True)

    def kill_session(self, session: str) -> None:
        run(["tmux", "kill-session", "-t", session], check=True)


class Rex:
    """Rex sessions are addressed by label; we resolve labels to session IDs."""
    name = "rex"

    def _rex_json(self, args: list[str]) -> Any:
        r = subprocess.run(["rex", *args, "--json"],
                           capture_output=True, text=True)
        if r.returncode != 0:
            die(f"rex {' '.join(args)} failed: {r.stderr.strip()}")
        return json.loads(r.stdout or "null")

    def _session_id(self, session: str) -> str | None:
        for s in self._rex_json(["ls"]).get("sessions", []):
            if s.get("label") == session:
                return s["session_id"]
        return None

    def has_session(self, session: str) -> bool:
        return self._session_id(session) is not None

    def create_session(self, session: str, cwd: str) -> None:
        created = self._rex_json(
            ["new", session, "-c", cwd, "--window", f"WT-{session}"])
        sid = created["session_id"]
        for win in EXTRA_WINDOWS:
            self._rex_json(["window", "new", "-s", sid, win,
                            "-c", cwd, "--focus=false"])

    def _app_client(self) -> str | None:
        """Find the Rex app showing the session gwt was run from."""
        args = ["client", "ls"]
        if os.environ.get("REX_SESSION"):
            args += ["-s", os.environ["REX_SESSION"]]
        clients = self._rex_json(args).get("clients", [])
        for c in clients:
            if c.get("info", {}).get("kind") == "app":
                return c["client_id"]
        return None

    def switch_to(self, session: str) -> None:
        sid = self._session_id(session)
        if sid is None:
            die(f"no rex session '{session}'")
        cmd = ["rex"]
        client = self._app_client()
        if client:
            cmd += ["-C", client]
        cmd += ["do", "session.select", f"session_id={sid}"]
        r = run(cmd, capture_output=True, text=True)
        if r.returncode != 0:
            # session.select is a client action; it needs Remote Control
            # enabled in the Rex app.
            print(f"gwt: couldn't switch to rex session '{session}' "
                  f"(select it in the sidebar instead): {r.stderr.strip()}",
                  file=sys.stderr)

    def kill_session(self, session: str) -> None:
        sid = self._session_id(session)
        if sid:
            run(["rex", "kill", sid], check=True)


def get_mux() -> Tmux | Rex:
    if os.environ.get("REX_SESSION") and shutil.which("rex"):
        return Rex()
    return Tmux()


def ensure_git_repo() -> str:
    """Ensure we're in a git repo, chdir to root, and return the root path."""
    rc, root = run_output(["git", "-C", ".", "rev-parse", "--show-toplevel"])
    if rc != 0:
        die("not inside a Git repository")
    os.chdir(root)
    return root


def safe_session_name(name: str) -> str:
    """Convert a branch name to a tmux-safe session name."""
    return name.replace("/", "_").replace(".", "-").replace(":", "-")


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


def cmd_switch(args: argparse.Namespace) -> None:
    ensure_git_repo()

    wtdir, name = fzf_pick_worktree()
    safe_session = safe_session_name(name)

    mux = get_mux()
    if not mux.has_session(safe_session):
        die(f"no {mux.name} session '{safe_session}' (use 'gwt create' first)")
    mux.switch_to(safe_session)


def cmd_create(args: argparse.Namespace) -> None:
    root = ensure_git_repo()
    repo_name = Path(root).name
    worktrees_base = WORKTREES_BASE / repo_name
    worktrees_base.mkdir(parents=True, exist_ok=True)

    name = args.name
    safe_name = name.replace("/", "_")
    wtdir = str(worktrees_base / safe_name)

    safe_session = safe_session_name(name)

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

    # 4 — create multiplexer session if needed, then switch/attach
    mux = get_mux()
    if not mux.has_session(safe_session):
        mux.create_session(safe_session, wtdir)
    mux.switch_to(safe_session)


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
    root = ensure_git_repo()

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
    answer = input("Proceed? [Y/n] ").strip().lower()
    if answer == "n":
        print("gwt: aborted")
        return

    # 5 — remove each stale worktree
    mux = get_mux()
    for branch, path in stale_pairs:
        safe_session = safe_session_name(branch)
        if mux.has_session(safe_session):
            mux.kill_session(safe_session)
            print(f"gwt: killed {mux.name} session '{safe_session}'")

        if Path(path, ".git").exists():
            print(f"gwt: removing worktree '{path}'...")
            run(["git", "worktree", "remove", "--force", path], check=True)
            print(f"gwt: removed worktree '{path}'")

        run(["git", "branch", "-D", branch], check=True)
        print(f"gwt: deleted branch '{branch}'")

    run(["git", "worktree", "prune"], check=True)
    print("gwt: pruned worktree metadata")


def cmd_delete(args: argparse.Namespace) -> None:
    root = ensure_git_repo()
    repo_name = Path(root).name
    worktrees_base = WORKTREES_BASE / repo_name

    # 1 — pick the worktree to remove
    if args.name is None:
        wtdir, name = fzf_pick_worktree_delete(root)
    else:
        name = args.name
        safe_name = name.replace("/", "_")
        wtdir = str(worktrees_base / safe_name)

    # 2 — kill multiplexer session if it exists
    safe_session = safe_session_name(name)
    mux = get_mux()
    if mux.has_session(safe_session):
        mux.kill_session(safe_session)
        print(f"gwt: killed {mux.name} session '{safe_session}'")

    # 3 — get the branch name before removing the worktree
    rc, branch = run_output(["git", "-C", wtdir, "rev-parse", "--abbrev-ref", "HEAD"])
    branch = branch if rc == 0 else None

    # 4 — remove the worktree
    if Path(wtdir, ".git").exists():
        cmd = ["git", "worktree", "remove", wtdir]
        if args.force:
            cmd.append("--force")
        result = run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            stderr = result.stderr.strip()
            if "modified or untracked files" in stderr:
                die(f"'{wtdir}' contains modified or untracked files; re-run with --force to delete")
            die(stderr or f"failed to remove worktree '{wtdir}'")
        print(f"gwt: removed worktree '{wtdir}'")
    else:
        print(f"gwt: no worktree found at '{wtdir}'")

    # 5 — delete the local branch
    if branch and branch not in ("HEAD", ""):
        run(["git", "branch", "-D", branch], check=True)
        print(f"gwt: deleted branch '{branch}'")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="gwt — git worktree in tmux or rex",
    )
    sub = parser.add_subparsers(dest="command")

    p_create = sub.add_parser(
        "create", help="create or switch to a worktree"
    )
    p_create.add_argument(
        "name",
        help="worktree/branch name",
    )

    p_delete = sub.add_parser(
        "delete", help="remove a worktree and kill its tmux/rex session"
    )
    p_delete.add_argument(
        "name",
        nargs="?",
        help="worktree name to remove (omit for interactive fzf picker)",
    )
    p_delete.add_argument(
        "-f", "--force",
        action="store_true",
        help="force removal even with modified or untracked files",
    )
    sub.add_parser(
        "switch", help="switch to an existing worktree's tmux/rex session",
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
    elif args.command == "switch":
        cmd_switch(args)
    elif args.command == "clean":
        cmd_clean(args)


if __name__ == "__main__":
    main()
