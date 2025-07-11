#!/bin/bash

ln -sf $PWD/.vimrc ~
ln -sf $PWD/.gitconfig ~
ln -sf $PWD/.tmux.conf ~
ln -sf $PWD/.zshrc ~
ln -sf $PWD/.ripgreprc ~
ln -sf $PWD/aliases.zsh ~/.oh-my-zsh/custom
ln -sf $PWD/settings.json ~/Library/Application\ Support/Code/User
ln -sf $PWD/keybindings.json ~/Library/Application\ Support/Code/User
mkdir -p ~/.config/ghostty
ln -sf $PWD/ghostty_config ~/.config/ghostty/config
ln -sf $PWD/starship.toml ~/.config
