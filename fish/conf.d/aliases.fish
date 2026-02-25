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

# Function to create a jira issue and move it to the 'New (Ready to assign)' column
function jira-create-andromeda
    script -q /tmp/jira-create-output jira issue create --custom team=e79aceb4-c14d-4932-b303-a055bf8181a9 $argv
    set issue_key (string match -r 'INT-\d+' < /tmp/jira-create-output)
    if test -n "$issue_key"
        jira issue move $issue_key "New (Ready to Assign)"
    end
    echo $issue_key | pbcopy
    echo "Issue key copied to clipboard"
end

abbr -a jiral "jira issue list -q 'cf[10001] = e79aceb4-c14d-4932-b303-a055bf8181a9' -s 'New (ready to assign)' -s 'In Progress' -s 'Awaiting Review'"
abbr -a jiraln "jira issue list -q 'cf[10001] = e79aceb4-c14d-4932-b303-a055bf8181a9' -s 'New (ready to assign)'"
abbr -a jiralm "jira issue list -q 'cf[10001] = e79aceb4-c14d-4932-b303-a055bf8181a9' -a (jira me)"
abbr -a jirac "jira-create-andromeda -tStory"


# Linux clipboard simulation
if uname | grep -q Linux
    abbr -a pbcopy 'xclip -selection clipboard'
    abbr -a pbpaste 'xclip -selection clipboard -o'
end
