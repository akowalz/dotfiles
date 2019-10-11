#!/bin/bash

printf "Installing utilities.\n\n"

if ! type brew &> /dev/null; then
  echo "Installing homebrew."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! type mas &> /dev/null; then
  echo "Installing mas-cli."
  brew install mas
fi

echo "Installing dependencies from Brewfile"
brew bundle

echo "Checking for tmux plugin manager"
if [ -d ~/.tmux/plugins/tpm ]; then
  echo "Already installed."
else
  echo "Installing tmux plugin manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo "Done."
echo "Run the setup script to configure these utilites."
