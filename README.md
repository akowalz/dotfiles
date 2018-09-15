# Dotfiles

This repo includes my configuration files for vim, tmux, bash, git, and more.

## Install and Setup

The install script (intended for macOS) will install homebrew, tmux, and a few other things needed by the setup script.

```sh
./install.sh
```

The setup script will create symlinks from this repo to your home directory, skipping anything that already exists, and install vim plugins.

```sh
./setup.sh
```
