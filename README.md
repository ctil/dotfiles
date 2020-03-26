Dotfiles
========
Contains customized configuration files for linux (aliases, vimrc, etc.).


SSH Keys
=========
Run these commands to generate an ssh key:
    
    ssh-keygen -t rsa -b 4096 -C "ctil@users.noreply.github.com" -f ~/.ssh/id_rsa.home
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_rsa.home
    
Then add ~/.ssh/id_rsa.home.pub to GitHub.

Cloning a Repo
==============
After cloning a github repo, run this command to set username and email:

    ./git_setup.sh

Mac Setup
=========
Add this to ~/.ssh/config:

    Host github.com
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_rsa.home

Install Powerline Fonts
=======================
These are needed by the vim-airline plugin. Run these commands:

    git clone https://github.com/powerline/fonts.git
    cd fonts
    ./install.sh
    rm -rf fonts
    
Then change terminal to use a powerline font.
