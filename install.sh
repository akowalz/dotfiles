#!/bin/bash

printf "Installing necessary utilities.\n\n"

if ! type brew &> /dev/null; then
  echo "Installing homebrew."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Checking for coreutils..."
if ! brew list coreutils &> /dev/null; then
  echo "Installing coreutils via homebrew."
  brew install coreutils
fi

echo "Checking for tmux..."
if ! type tmux &> /dev/null; then
  echo "Installing tmux."
  brew install tmux
else
  echo "Already installed."
fi

echo "Checking for tmux plugin manager"
if [ -d ~/.tmux/plugins/tpm ]; then
  echo "Already installed."
else
  echo "Installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Checking for bash-git-prompt..."
if ! brew list bash-git-prompt &> /dev/null; then
  echo "Installing bash-git-prompt via homebrew."
  brew install bash-git-prompt
else
  echo "Already installed."
fi

echo "Done."
echo "Run the setup script to configure these utilites."
