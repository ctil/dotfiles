function git_main_branch
    command git rev-parse --git-dir &>/dev/null; or return

    for ref in refs/heads/main refs/heads/trunk refs/heads/mainline refs/heads/default refs/heads/master refs/heads/stable \
               refs/remotes/origin/main refs/remotes/origin/trunk refs/remotes/origin/mainline refs/remotes/origin/default refs/remotes/origin/master refs/remotes/origin/stable \
               refs/remotes/upstream/main refs/remotes/upstream/trunk refs/remotes/upstream/mainline refs/remotes/upstream/default refs/remotes/upstream/master refs/remotes/upstream/stable
        if command git show-ref -q --verify $ref
            echo (basename $ref)
            return 0
        end
    end

    # Fallback: try to get the default branch from remote HEAD symbolic refs
    for remote in origin upstream
        set -l ref (command git rev-parse --abbrev-ref $remote/HEAD 2>/dev/null)
        if string match -q "$remote/*" $ref
            echo (string replace "$remote/" "" $ref)
            return 0
        end
    end

    echo master
    return 1
end
