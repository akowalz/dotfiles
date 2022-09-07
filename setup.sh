#!/bin/bash

symlink () {
  dest=~/.$1
  echo "Setting up $1"

  if [ -e $dest ]
  then
    echo "$dest already exists, skipping."
  else
    echo "Linking $1 to $dest"
    ln -fs $(realpath $1) $dest
  fi

  printf "\n"
}

printf "Setting up config files.\n\n"

symlink bashrc
symlink bash_profile

symlink gitconfig
symlink gitignore
symlink git-prompt-colors.sh

symlink tmux.conf

symlink vim
symlink vimrc
symlink ideavimrc

echo "Installing vim plugins."
vim +PlugInstall +qall

echo "tmux plugins must be installed manually!"

echo "Done."

echo "Running mac defaults commands"
defaults write -g ApplePressAndHoldEnabled -bool false

defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.2
defaults write com.apple.screencapture type jpg
defaults write com.apple.Dock showhidden -bool TRUE

echo "Log out and back in order for changes to take effect"
