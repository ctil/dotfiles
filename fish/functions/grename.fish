function grename
    if test (count $argv) -ne 2
        echo "Usage: grename old_branch new_branch"
        return 1
    end

    git branch -m $argv[1] $argv[2]
    if git push origin :$argv[1]
        git push --set-upstream origin $argv[2]
    end
end
