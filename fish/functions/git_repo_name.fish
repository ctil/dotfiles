function git_repo_name
    set -l repo_path (git rev-parse --show-toplevel 2>/dev/null)
    if test $status -eq 0; and test -n "$repo_path"
        basename $repo_path
    end
end
