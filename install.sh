#!/bin/bash

# Run from the repo, so brew bundle finds the Brewfile
cd "$(dirname "$0")"

printf "Installing utilities.\n\n"

if [ ! -x /opt/homebrew/bin/brew ]; then
  echo "Installing homebrew."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Put brew on this script's PATH. A just-installed brew isn't on it yet,
# and neither is one in a shell that doesn't read zprofile.
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Installing dependencies from Brewfile"
brew bundle

echo "Done."
echo "Run the setup script to configure these utilites."
