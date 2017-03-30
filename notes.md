Cloning a Repo
==============
After cloning a github repo, run these commands to set username and email:

    git config --local user.email "ctil@users.noreply.github.com"
    git config --local user.name "ctil"

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
