function git_previous_branch
    set -l ref (git rev-parse --abbrev-ref '@{-1}' 2>/dev/null)
    if test $status -ne 0; or test -z "$ref"
        return
    end
    echo (string replace 'refs/heads/' '' $ref)
end
