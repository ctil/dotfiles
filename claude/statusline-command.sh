#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
session_name=$(echo "$input" | jq -r '.session_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

C_RESET='\033[0m'
C_WHITE='\033[37m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[91m'

# Starship prompt (first line only), --terminal-width 1 suppresses right-alignment padding
starship_raw=$(starship prompt --terminal-width 1 2>/dev/null | head -n1)
if [ -n "$starship_raw" ]; then
    starship_clean=$(printf '%s' "$starship_raw" | sed 's/%{//g; s/%}//g; s/[[:space:]]*$//')
    printf '%b  ' "$starship_clean"
fi

# Session name (only when set via /rename)
if [ -n "$session_name" ]; then
    printf "${C_CYAN}%s${C_RESET}  " "$session_name"
fi

# Model
printf "${C_WHITE}%s${C_RESET}" "$model"

# Context usage progress bar
if [ -n "$used" ]; then
    if [ "$used" -ge 80 ]; then
        C_BAR="$C_RED"
    elif [ "$used" -ge 60 ]; then
        C_BAR="$C_YELLOW"
    else
        C_BAR="$C_GREEN"
    fi

    bar_width=10
    filled=$(( used * bar_width / 100 ))
    empty=$(( bar_width - filled ))

    bar=""
    i=0
    while [ $i -lt $filled ]; do bar="${bar}█"; i=$(( i + 1 )); done
    i=0
    while [ $i -lt $empty ]; do bar="${bar}░"; i=$(( i + 1 )); done

    printf "  ${C_BAR}%s${C_RESET} ${C_BAR}%s%%${C_RESET}" "$bar" "$used"
fi
