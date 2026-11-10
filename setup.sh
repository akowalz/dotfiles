#!/bin/bash

# Run from the repo, since the links point at its files
cd "$(dirname "$0")"

realpath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# Files that were where a link goes, moved aside to <file>.pre-dotfiles,
# and links not made because an earlier .pre-dotfiles copy was in the way
moved=()
skipped=()

# symlink <name> [dest]: link <name> to dest, which defaults to ~/.<name>.
# A file already at dest, such as a ~/.zshrc an installer wrote or a config an app
# created on first launch, moves aside to dest.pre-dotfiles, so nothing is overwritten.
symlink () {
  src=$(realpath $1)
  dest=${2:-~/.$1}
  echo "Setting up $1"

  if [ "$(readlink "$dest")" = "$src" ]
  then
    echo "$dest is already linked."
  elif [ -e "$dest" ] && [ -e "$dest.pre-dotfiles" ]
  then
    echo "$dest is in the way, and so is $dest.pre-dotfiles. Move one of them and re-run. Skipping."
    skipped+=("$dest")
  else
    if [ -e "$dest" ]
    then
      echo "Moving the existing $dest to $dest.pre-dotfiles"
      mv "$dest" "$dest.pre-dotfiles"
      moved+=("$dest.pre-dotfiles")
    fi
    echo "Linking $1 to $dest"
    ln -sfn "$src" "$dest"
  fi

  printf "\n"
}

printf "Setting up config files.\n\n"

# Remove links into this repo whose file it no longer has, such as ~/.bashrc
# from before the switch to zsh. Broken links pointing anywhere else stay.
for link in ~/.[!.]* ~/.[!.]*/* ~/.config/*/* ~/bin/*
do
  if [ -L "$link" ] && [ ! -e "$link" ] && [[ $(readlink "$link") = "$PWD"/* ]]
  then
    echo "Removing $link, a link to $(readlink "$link"), which is no longer in this repo"
    rm "$link"
  fi
done
printf "\n"

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

# Neovim, the editor, reads vim's setup (vim/ and vimrc) through this
mkdir -p ~/.config/nvim
symlink nvim.vim ~/.config/nvim/init.vim

# gdc's VS Code extension (gdc in zshrc), which opens its diffs in one multi-file diff tab.
# Installed rather than linked: VS Code ignores extensions it didn't install itself.
vscode/gdc/install
printf "\n"

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

# zsh is the login shell, since zshrc and zprofile are written for it.
# chsh asks for your password.
if [ "$(dscl . -read /Users/$USER UserShell | awk '{print $2}')" != /bin/zsh ]
then
  echo "Changing your login shell to zsh."
  chsh -s /bin/zsh && echo "Open a new terminal (quit and reopen cmux) to start using it."
  printf "\n"
fi

echo "Installing vim plugins."
vim +PlugInstall +qall

echo "Done."

./macos.sh

if [ ${#moved[@]} -gt 0 ]
then
  printf "\nThese were in the way of a link and moved aside. Keep anything you still want\n"
  printf "(machine-specific shell setup goes in ~/.zshrc.local), then delete them:\n"
  printf "  %s\n" "${moved[@]}"
fi
if [ ${#skipped[@]} -gt 0 ]
then
  printf "\nNot linked, because both the file and its .pre-dotfiles copy exist. Move one and re-run:\n"
  printf "  %s\n" "${skipped[@]}"
fi
