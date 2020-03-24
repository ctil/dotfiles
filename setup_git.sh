#!/bin/bash

git config user.name "ctil"
git config user.email "ctil@users.noreply.github.com"

# Only use pager when output does not fit on screen
git config --global --replace-all core.pager "less -F -X"
