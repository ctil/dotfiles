# Navigation
alias b="cd .."
alias bb="cd ../../"
alias bbb="cd ../../../"
alias bbbb="cd ../../../../"
alias bbbbb="cd ../../../../../"
alias wk="cd ~/work"

alias ltr="ls -ltr"
alias f="find . -name"

# Git
alias gam="git commit -a --amend --no-edit"
alias gl1="git log -1"
alias gfm="git fetch origin master:master"

# Simulate pbpaste/pbcopy if on Linux
if [ "$(uname 2> /dev/null)" = "Linux" ]; then
    alias pbcopy="xclip -selection clipboard"
    alias pbpaste="xclip -selection clipboard -o"
fi

alias mr='cd ~/work/monorepo'
alias rust="evcxr"
alias n="~/notify_done.sh"
