# Jira CLI helpers for Andromeda team

set -g JIRA_TEAM_ID 'e79aceb4-c14d-4932-b303-a055bf8181a9'
set -g JIRA_TEAM_QUERY "cf[10001] = $JIRA_TEAM_ID"
set -g JIRA_STATUS_NEW 'New (Ready to Assign)'

# Create a jira issue and move it to the 'New (Ready to Assign)' column
function jira-create-andromeda
    script -q /tmp/jira-create-output jira issue create --custom team=$JIRA_TEAM_ID $argv
    set issue_key (string match -r 'INT-\d+' < /tmp/jira-create-output)
    if test -n "$issue_key"
        jira issue move $issue_key $JIRA_STATUS_NEW
    end
    echo $issue_key | pbcopy
    echo "Issue key copied to clipboard"
end

abbr -a jiral "jira issue list -q '$JIRA_TEAM_QUERY' -s '$JIRA_STATUS_NEW' -s 'In Progress' -s 'Awaiting Review'"
abbr -a jiraln "jira issue list -q '$JIRA_TEAM_QUERY' -s '$JIRA_STATUS_NEW'"
abbr -a jiralm "jira issue list -q '$JIRA_TEAM_QUERY' -a (jira me)"
abbr -a jirac "jira-create-andromeda -tStory"
