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

## Other notes

Some Vim settings and plugins require Vim 8+, which can be install via homebrew.

To automatically attach to a tmux session every time a new terminal window is opened, configure Terminal to run the following on startup (Terminal > Preferences > Shell > Startup > Run Command):

```sh
tmux new-session -A -s main
```
