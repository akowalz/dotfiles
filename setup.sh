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
symlink git-prompt-colors.sh

symlink tmux.conf

symlink vim
symlink vimrc

echo "Done."
echo "Run the install script (./install.sh) to install dependencies."
