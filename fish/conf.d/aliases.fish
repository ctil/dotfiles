# Navigation
abbr -a b 'cd ..'
abbr -a bb 'cd ../../'
abbr -a bbb 'cd ../../../'
abbr -a bbbb 'cd ../../../../'
abbr -a bbbbb 'cd ../../../../../'

# General
abbr -a ltr 'ls -ltr'
abbr -a f 'rg --files -g'
abbr -a j just
abbr -a c clear
abbr -a sz 'exec fish'
abbr -a vi nvim
abbr -a notify '~/notify_done.sh'
abbr -a h history
abbr -a hs 'history | rg'

# Tmux
abbr -a tn 'tmux new-session -s'
abbr -a tk 'tmux kill-session -t'
abbr -a tl 'tmux list-sessions'
abbr -a ta 'tmux attach -t'

# Claude code
abbr -a cl claude
abbr -a cly 'claude --settings ~/.claude/settings_permissive.json'
abbr -a clu 'claude update'
abbr -a clq 'claude -p --no-chrome --model haiku'

# Work
abbr -a dm 'diesel migration'
abbr -a jn 'just nightly=1'
abbr -a gwt '~/dotfiles/gwt.py'
abbr -a gwtc '~/dotfiles/gwt.py create'
abbr -a gwtd '~/dotfiles/gwt.py delete'
abbr -a mr 'cd ~/code/monorepo && fnm use'

# Linux clipboard simulation
if uname | grep -q Linux
    abbr -a pbcopy 'xclip -selection clipboard'
    abbr -a pbpaste 'xclip -selection clipboard -o'
end
