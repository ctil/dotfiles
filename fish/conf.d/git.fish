# Git abbreviations

abbr -a g git
abbr -a gb 'git branch'
abbr -a gba 'git branch --all'
abbr -a gbd 'git branch --delete'
abbr -a gbD 'git branch --delete --force'

abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gcm 'git checkout (git_main_branch)'
abbr -a gcd 'git checkout (git_develop_branch)'

abbr -a gd 'git diff'

abbr -a gf 'git fetch'
alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'

abbr -a glp 'git log --pretty'
abbr -a glg 'git log --stat'
abbr -a gm 'git merge'
abbr -a gmom 'git merge origin/(git_main_branch)'

abbr -a gl 'git pull'

abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease --force-if-includes'
abbr -a gpff 'git push --force'
abbr -a gpod 'git push origin --delete'

abbr -a grb 'git rebase'
abbr -a grbd 'git rebase (git_develop_branch)'
abbr -a grbm 'git rebase (git_main_branch)'
abbr -a grbom 'git rebase origin/(git_main_branch)'

abbr -a gst 'git status'

# From aliases.zsh
abbr -a gam 'git commit -a --amend --no-edit'
abbr -a gca 'git commit -am'
abbr -a gl1 'git log -1'
abbr -a gfm 'git fetch origin (git_main_branch):(git_main_branch)'
abbr -a gdn 'git diff (git_main_branch)...HEAD --name-only'
