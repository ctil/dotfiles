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

# Git
alias gam="git commit -a --amend --no-edit"
alias gl1="git log -1"
alias gfm="git fetch origin master:master"

# Simulate pbpaste/pbcopy if on Linux
if [ "$(uname 2> /dev/null)" = "Linux" ]; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
fi

alias mr='cd ~/code/monorepo && nvm use'
alias notify="~/notify_done.sh"
alias vi="nvim"

alias dm="diesel migration"
