# Git aliases

alias g='git'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'

alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout (git_main_branch)'
alias gcd='git checkout (git_develop_branch)'

alias gd='git diff'

alias gf='git fetch'
alias gg='git gui citool'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
alias glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
alias glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'

alias glp='git log --pretty'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias gfg='git ls-files | grep'
alias gm='git merge'
alias gmom='git merge origin/(git_main_branch)'

alias gl='git pull'

alias gp='git push'
alias gpf='git push --force-with-lease --force-if-includes'
alias gpff='git push --force'
alias gpod='git push origin --delete'

alias grb='git rebase'
alias grbd='git rebase (git_develop_branch)'
alias grbm='git rebase (git_main_branch)'
alias grbom='git rebase origin/(git_main_branch)'

alias gst='git status'

# From aliases.zsh
alias gam='git commit -a --amend --no-edit'
alias gca='git commit -am'
alias gl1='git log -1'
alias gfm='git fetch origin (git_main_branch):(git_main_branch)'
alias gdn='git diff (git_main_branch)...HEAD --name-only'
