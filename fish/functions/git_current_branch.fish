function git_current_branch
    set -l ref (git symbolic-ref --quiet HEAD 2>/dev/null)
    if test $status -ne 0
        set ref (git rev-parse --short HEAD 2>/dev/null)
        or return
    end
    echo (string replace 'refs/heads/' '' $ref)
end
