#!/bin/bash

printf "Installing necessary utilities.\n\n"

if ! type brew &> /dev/null; then
  echo "Installing homebrew."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing tmux."
brew install tmux

echo "Installing bash-git-prompt via homebrew."
brew install bash-git-prompt

echo "Install vim plugins."
vim +PlugInstall +qall

echo "Done."
