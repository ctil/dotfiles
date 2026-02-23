function __fish_tmux_sessions
    tmux list-sessions -F '#{session_name}' 2>/dev/null
end

complete -c tmux -n "__fish_seen_subcommand_from attach-session a switch-client" \
    -s t -l target-session -r -xa "(__fish_tmux_sessions)"

# Alias completions
complete -c ta -f -xa "(__fish_tmux_sessions)"
complete -c tk -f -xa "(__fish_tmux_sessions)"
