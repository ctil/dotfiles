#!/bin/bash

# Install tools
brew install fzf \
    gh \
    blueutil \
    ripgrep \
    starship \
    ghostty \
    tmux \
    zoxide \
    nvim

if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/ctil/nvim.git $HOME/.config/nvim
fi

if [ ! -d "$HOME/.nvm" ]; then
    git clone https://github.com/nvm-sh/nvm.git $HOME/.nvm
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

mkdir -p $HOME/code

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
