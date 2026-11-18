#!/bin/bash
# This is an idempotent script that sets up my macOS environment

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Brewfile dependencies
brew bundle

if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/ctil/nvim.git $HOME/.config/nvim
fi

if [ ! -d "$HOME/.nvm" ]; then
    git clone https://github.com/nvm-sh/nvm.git $HOME/.nvm
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

if [ ! -d "$HOME/.delta" ]; then
    mkdir -p $HOME/.delta
    git clone https://github.com/dandavison/delta $HOME/.delta
fi

mkdir -p $HOME/code
mkdir -p $HOME/.zsh/cache

# Make fish the login shell
FISH_PATH="$(brew --prefix)/bin/fish"
if [ -x "$FISH_PATH" ]; then
    grep -qxF "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
    if [ "$(dscl . -read ~ UserShell | awk '{print $2}')" != "$FISH_PATH" ]; then
        chsh -s "$FISH_PATH"
    fi
fi

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

./symlink_configs.sh
