#!/bin/bash

# Install tools
brew install fzf \
    gh \
    ripgrep \
    starship \
    ghostty \
    tmux \
    zoxide \
    nvim

if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/ctil/nvim.git ~/.config/nvim
fi

if [ ! -d "$HOME/.config/.nvm" ]; then
    git clone https://github.com/nvm-sh/nvm.git .nvm
fi

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
