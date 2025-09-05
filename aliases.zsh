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

# Git
alias gam="git commit -a --amend --no-edit"
alias gca="git commit -am "
alias gl1="git log -1"
alias gfm="git fetch origin master:master"
alias gdn="git diff master...HEAD --name-only"
alias gwt="~/dotfiles/gwt.sh"

# Simulate pbpaste/pbcopy if on Linux
if [ "$(uname 2> /dev/null)" = "Linux" ]; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
fi

alias notify="~/notify_done.sh"
alias vi="nvim"

# Wyyerd Stuff
alias dm="diesel migration"
alias mr='cd ~/code/monorepo && nvm use'

# Tmux
alias tn="tmux new-session -s "
alias tk="tmux kill-session -t "

alias cl="claude"
