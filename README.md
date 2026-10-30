# Dotfiles

My macOS setup.

## What's here

- zsh
- git
- vim
- tmux
- cmux and Ghostty
- `bin/` scripts, including `t` (plain English to shell commands) and `dps` (a tidier `docker ps`)

## Setup

```sh
./install.sh   # installs Homebrew if needed, then the Brewfile
./setup.sh     # symlinks everything into ~, installs vim plugins, runs macos.sh
./macos.sh     # macOS settings on their own (safe to re-run)
```

`setup.sh` never overwrites anything: a file already where a link goes moves aside to `<name>.pre-dotfiles`, and links already in place are skipped, so it's safe to re-run.

Machine-specific settings stay out of this public repo, in untracked files:

- `~/.gitconfig.local`: your git `[user]` name and email (required).
- `~/.zshrc.local`: anything else, such as language runtimes and version managers.
