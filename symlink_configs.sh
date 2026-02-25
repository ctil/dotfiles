#!/bin/bash

ln -sf $PWD/.vimrc ~
ln -sf $PWD/.gitconfig ~
ln -sf $PWD/.tmux.conf ~
ln -sf $PWD/zsh/zshrc ~/.zshrc
ln -sf $PWD/.ripgreprc ~

# VS Code
if [ -d ~/Library/Application\ Support/Code/User ]; then
  ln -sf $PWD/vscode/settings.json ~/Library/Application\ Support/Code/User
  ln -sf $PWD/vscode/keybindings.json ~/Library/Application\ Support/Code/User
fi

mkdir -p ~/.config/ghostty
ln -sf $PWD/ghostty_config ~/.config/ghostty/config
ln -sf $PWD/starship.toml ~/.config

# Claude Code
mkdir -p ~/.claude
ln -sf $PWD/claude/settings.json ~/.claude
ln -sf $PWD/claude/settings_permissive.json ~/.claude
ln -sf $PWD/claude/statusline-command.sh ~/.claude
ln -sf $PWD/claude/CLAUDE.md ~/.claude/CLAUDE.md

mkdir -p ~/.gemini
ln -sf $PWD/gemini/settings.json ~/.gemini

# Fish shell
mkdir -p ~/.config/fish
ln -sf $PWD/fish/config.fish ~/.config/fish/config.fish
ln -sfn $PWD/fish/conf.d ~/.config/fish/conf.d
ln -sfn $PWD/fish/functions ~/.config/fish/functions
ln -sfn $PWD/fish/completions ~/.config/fish/completions
