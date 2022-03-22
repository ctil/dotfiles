#!/bin/bash

# Install tools
brew install fzf
$(brew --prefix)/opt/fzf/install
brew install ripgrep

# Vim stuff
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.vimbackups

# Enable key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
