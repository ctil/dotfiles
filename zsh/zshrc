# Uncomment to profile startup time
# zmodload zsh/zprof

export PATH="/opt/homebrew/bin:$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export XDG_CONFIG_HOME="$HOME/.config"

# Completion — single cached call (must come before anything that calls compdef)
fpath=(~/.bun $fpath)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Completion styles (menu selection with highlighting + descriptions)
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
bindkey '^[[Z' reverse-menu-complete

# Git plugin
source ~/dotfiles/zsh/git/git.plugin.zsh

# History settings
setopt hist_find_no_dups
setopt hist_ignore_all_dups

# Custom aliases
source ~/dotfiles/zsh/aliases.zsh

export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--layout reverse"
source "/opt/homebrew/opt/fzf/shell/completion.zsh"
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# fnm (Node version manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# Bump up the memory for node so tsc doesn't crash
export NODE_OPTIONS="--max-old-space-size=8192"

# Postgres lib
export PQ_LIB_DIR="/opt/homebrew/opt/libpq/lib"

# OpenSSL
export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@1.1"
export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/lib"
export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/include"
export OPENSSL_BIN_DIR="$OPENSSL_ROOT_DIR/bin"
export PATH="$OPENSSL_BIN_DIR:$PATH"
export CFLAGS="-I$OPENSSL_INCLUDE_DIR"
export CPPFLAGS="-I$OPENSSL_INCLUDE_DIR"
export LDFLAGS="-L$OPENSSL_LIB_DIR"

# Python
export PATH="$PATH:${HOME}/Library/Python/3.9/bin/"

# Make sure the docker compose project name is consistent
export COMPOSE_PROJECT_NAME=monorepo

# Zoxide
if (( $+commands[zoxide] )); then eval "$(zoxide init zsh)"; fi

# Git branch fuzzy search (overrides gc='git commit --verbose' from git plugin)
gc() {
  git checkout "$(git branch | fzf | sed 's/^[ *]*//')"
}

# Load environment variables from a .env file, if available
if [ -f "$HOME/.env" ]; then
  set -a
  source $HOME/.env
  set +a
fi

# Starship prompt
eval "$(starship init zsh)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# This is supposed to prevent sccache shutting down the server
export SCCACHE_IDLE_TIMEOUT=2500
export SCCACHE_CACHE_SIZE=20G

# Uncomment to profile startup time
# zprof
