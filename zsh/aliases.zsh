# Navigation
alias b="cd .."
alias bb="cd ../../"
alias bbb="cd ../../../"
alias bbbb="cd ../../../../"
alias bbbbb="cd ../../../../../"

alias ltr="ls -ltr"
alias f="rg --files -g "
alias j="just"
alias c="clear"
alias sz="source ~/.zshrc"

# Git (many other aliases are defined in zsh/git/git.plugin.zsh)
alias gam="git commit -a --amend --no-edit"
alias gca="git commit -am "
alias gl1="git log -1"
alias gfm='git fetch origin $(git_main_branch):$(git_main_branch)'
alias gdn='git diff $(git_main_branch)...HEAD --name-only'
alias gwt="~/dotfiles/gwt.py"
alias gwtc="~/dotfiles/gwt.py create"
alias gwtd="~/dotfiles/gwt.py delete"

# History
alias h='history'
alias hs='history | rg'

# Simulate pbpaste/pbcopy if on Linux
if [ "$(uname 2> /dev/null)" = "Linux" ]; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
fi

alias notify="~/notify_done.sh"
alias vi="nvim"

# Wyyerd Stuff
alias dm="diesel migration"
alias mr='cd ~/code/monorepo && fnm use'

# Tmux
alias tn="tmux new-session -s "
alias tk="tmux kill-session -t "

# Claude code
alias cl="claude"
alias cly="claude --settings ~/.claude/settings_permissive.json"
alias clu="claude update"
