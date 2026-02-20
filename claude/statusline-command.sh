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

# Session name (only when set via /rename)
if [ -n "$session_name" ]; then
    printf "${C_CYAN}%s${C_RESET}  " "$session_name"
fi

# Model
printf "${C_WHITE}%s${C_RESET}" "$model"

# Context usage
if [ -n "$used" ]; then
    if [ "$used" -ge 80 ]; then
        C_BAR="$C_RED"
    elif [ "$used" -ge 60 ]; then
        C_BAR="$C_YELLOW"
    else
        C_BAR="$C_GREEN"
    fi
    printf "  ${C_WHITE}ctx${C_RESET} ${C_BAR}%s%%${C_RESET} used" "$used"
    if [ -n "$remaining" ]; then
        printf " ${C_WHITE}(${C_RESET}${C_CYAN}%s%%${C_RESET}${C_WHITE} left)${C_RESET}" "$remaining"
    fi
fi
