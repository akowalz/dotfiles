#!/bin/bash

printf "Installing utilities.\n\n"

if ! type brew &> /dev/null; then
  echo "Installing homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing dependencies from Brewfile"
brew bundle

echo "Done."
echo "Run the setup script to configure these utilites."
