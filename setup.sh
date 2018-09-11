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
echo "You may want to install homebrew, bash-git-prompt, and install vim plugins."
