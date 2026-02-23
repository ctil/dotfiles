function gc
    git checkout (git branch | fzf | string trim --left --chars '* ')
end
