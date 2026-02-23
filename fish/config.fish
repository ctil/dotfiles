# PATH
fish_add_path /opt/homebrew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin
fish_add_path /opt/homebrew/opt/openssl@1.1/bin
fish_add_path $HOME/Library/Python/3.9/bin
fish_add_path $HOME/.bun/bin

# Environment variables
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx RIPGREP_CONFIG_PATH $HOME/.ripgreprc

# fzf
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_DEFAULT_OPTS "--layout reverse"

# Node
set -gx NODE_OPTIONS "--max-old-space-size=8192"

# Postgres
set -gx PQ_LIB_DIR /opt/homebrew/opt/libpq/lib

# OpenSSL
set -gx OPENSSL_ROOT_DIR /opt/homebrew/opt/openssl@1.1
set -gx OPENSSL_LIB_DIR $OPENSSL_ROOT_DIR/lib
set -gx OPENSSL_INCLUDE_DIR $OPENSSL_ROOT_DIR/include
set -gx OPENSSL_BIN_DIR $OPENSSL_ROOT_DIR/bin
set -gx CFLAGS "-I$OPENSSL_INCLUDE_DIR"
set -gx CPPFLAGS "-I$OPENSSL_INCLUDE_DIR"
set -gx LDFLAGS "-L$OPENSSL_LIB_DIR"

# Docker Compose
set -gx COMPOSE_PROJECT_NAME monorepo

# Bun
set -gx BUN_INSTALL $HOME/.bun

# sccache
set -gx SCCACHE_IDLE_TIMEOUT 2500
set -gx SCCACHE_CACHE_SIZE 20G

# Tool init
fnm env --use-on-cd --shell fish | source

if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    fzf --fish | source
end

starship init fish | source

# Load .env file if available
if test -f $HOME/.env
    while read -l line
        switch $line
            case '#*' ''
                # skip comments and empty lines
            case '*'
                set -l parts (string split -m 1 '=' $line)
                if test (count $parts) -eq 2
                    set -gx $parts[1] $parts[2]
                end
        end
    end < $HOME/.env
end
