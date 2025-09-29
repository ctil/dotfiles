# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME=""

export PATH="/opt/homebrew/bin:$PATH:/Users/colin/.local/bin"
#NPM_DIR=`npm config get prefix`
#export PATH="$PATH:$NPM_DIR/bin"
export PATH="$PATH:$HOME/go/bin"

export XDG_CONFIG_HOME="$HOME/.config"

# Uncomment the following line if pasting URLs and other text is messed up.
# https://github.com/ohmyzsh/ohmyzsh/issues/11375
DISABLE_MAGIC_FUNCTIONS="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git rust docker fzf history tmux)

source $ZSH/oh-my-zsh.sh

# Override the oh-my-zsh git plugin function that I used in aliases like "gcm"
function git_main_branch() {
  command git rev-parse --git-dir &>/dev/null || return
  local ref
  for ref in refs/{heads,remotes/{origin,upstream}}/{main,trunk,mainline,default,master,stable}; do
    if command git show-ref -q --verify $ref; then
      echo ${ref:t}
      return 0
    fi
  done

  # If no main branch was found, fall back to master but return error
  echo master
  return 1
}

# Enable completions
compinit

# History settings
setopt hist_find_no_dups
setopt hist_ignore_all_dups


export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"

# Use ag for fzf search
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--layout reverse"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Lazy load nvm
export NVM_DIR="$HOME/.nvm"
nvm () {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # Load nvm
    nvm $@ # Copy arguments after nvm
}

nvm use default

# Bump up the memory for node so tsc doesn't crash
export NODE_OPTIONS="--max-old-space-size=8192"

# Postgres lib
export PQ_LIB_DIR="/opt/homebrew/opt/libpq/lib"

# Openssl lib
export OPENSSL_ROOT_DIR="/opt/homebrew/opt/openssl@1.1"
export OPENSSL_LIB_DIR="$OPENSSL_ROOT_DIR/lib"
export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/include"
export OPENSSL_BIN_DIR="$OPENSSL_ROOT_DIR/bin"
export PATH="$OPENSSL_BIN_DIR:$PATH"
export CFLAGS="-I$OPENSSL_INCLUDE_DIR"
export CPPFLAGS="-I$OPENSSL_INCLUDE_DIR"
export LDFLAGS="-L$OPENSSL_LIB_DIR"Tools

# PYTHON
export PATH="$PATH:${HOME}/Library/Python/3.9/bin/"

# Make sure the docker compose project name is consistent
export COMPOSE_PROJECT_NAME=monorepo


# Zoxide setup
zoxide_cmd=`which zoxide`
if ! [[ "$zoxide_cmd" =~ "not found" ]]; then eval "$(zoxide init zsh)"; fi

# Git branch fuzzy search
unalias gc
gc() {
 git checkout "$(git branch | fzf| sed 's/^[ *]*//')"
}


# Load environment variables from a .env file, if available
if [ -f "$HOME/.env" ]; then
  set -a
  source $HOME/.env
  set +x
fi

# Claude code
alias claude="~/.claude/local/claude"

eval "$(starship init zsh)"
