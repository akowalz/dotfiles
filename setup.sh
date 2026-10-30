#!/bin/bash

realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# symlink <name> [dest]: link <name> to dest, which defaults to ~/.<name>
symlink () {
  dest=${2:-~/.$1}
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

symlink zshrc
symlink zprofile

symlink gitconfig
symlink gitignore

symlink tmux.conf

symlink vim
symlink vimrc

mkdir -p ~/.config/cmux
symlink cmux.json ~/.config/cmux/cmux.json

mkdir -p ~/.config/ghostty
symlink ghostty.conf ~/.config/ghostty/config

mkdir -p ~/.config/diffnav
symlink diffnav.yml ~/.config/diffnav/config.yml

# Link each script into a real ~/bin, rather than linking ~/bin to bin/,
# so whatever else installs into ~/bin stays out of this repo.
if [ -L ~/bin ] && [ "$(readlink ~/bin)" = "$(realpath bin)" ]
then
  echo "Replacing the old ~/bin link to this repo with a directory"
  rm ~/bin
fi
mkdir -p ~/bin
for script in bin/*
do
  symlink $script ~/$script
done

echo "Installing vim plugins."
vim +PlugInstall +qall

echo "Done."

./macos.sh
