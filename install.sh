#!/bin/bash

printf "Installing necessary utilities.\n\n"

if ! type brew &> /dev/null; then
  echo "Installing homebrew."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Checking for tmux..."
if ! type tmux &> /dev/null; then
  echo "Installing tmux."
  brew install tmux
else
  echo "Already installed."
fi

echo "Checking for bash-git-prompt..."
if ! brew list bash-git-prompt &> /dev/null; then
  echo "Installing bash-git-prompt via homebrew."
  brew install bash-git-prompt
else
  echo "Already installed."
fi

echo "Installing vim plugins."
vim +PlugInstall +qall

echo "Done."
