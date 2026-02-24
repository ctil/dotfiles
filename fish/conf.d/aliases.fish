# Navigation
alias b='cd ..'
alias bb='cd ../../'
alias bbb='cd ../../../'
alias bbbb='cd ../../../../'
alias bbbbb='cd ../../../../../'

# General
alias ltr='ls -ltr'
alias f='rg --files -g'
alias j='just'
alias c='clear'
alias sz='exec fish'
alias vi='nvim'
alias notify='~/notify_done.sh'
alias h='history'
alias hs='history | rg'

# Tmux
alias tn='tmux new-session -s'
alias tk='tmux kill-session -t'
alias tl='tmux list-sessions'
alias ta='tmux attach -t'

# Claude code
alias cl='claude'
alias cly='claude --settings ~/.claude/settings_permissive.json'
alias clu='claude update'
alias clq='claude -p --no-chrome --model haiku'

# Work
alias dm='diesel migration'
alias jn='just nightly=1'
alias gwt='~/dotfiles/gwt.py'
alias gwtc='~/dotfiles/gwt.py create'
alias gwtd='~/dotfiles/gwt.py delete'
alias mr='cd ~/code/monorepo && fnm use'

# Linux clipboard simulation
if uname | grep -q Linux
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
end
