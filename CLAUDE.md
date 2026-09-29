# CLAUDE.md

Personal dotfiles for macOS: bash, vim, tmux, git, IdeaVim, plus small scripts in `bin/`.

## Layout

`setup.sh` symlinks each of these repo files to `~/.<name>`:
`bashrc`, `bash_profile`, `gitconfig`, `gitignore`, `git-prompt-colors.sh`,
`tmux.conf`, `vim/`, `vimrc`, `ideavimrc`. It also links `bin/` to `~/bin`.

- It skips any destination that already exists, so it never overwrites anything.
- A new top-level config file needs its own `symlink <name>` line in `setup.sh`.
- `gitignore` is the global git excludes file. `.gitignore` is this repo's own ignore file.
- Custom scripts go in `bin/` (on PATH as `~/bin`). Make them executable and give them a shebang.

## Bootstrapping a new machine

1. `./install.sh` installs Homebrew and `mas` if they're missing, runs `brew bundle` (Brewfile), clones tpm into `~/.tmux/plugins/tpm`, and downloads `~/.git-completion.bash`.
2. `./setup.sh` creates the symlinks, runs `vim +PlugInstall +qall` (vim-plug, installing into `vim/plugged/`, which is gitignored), and applies some macOS `defaults write` settings.
3. tmux plugins are installed by hand (tpm: `prefix + I`).

Add Homebrew packages to `Brewfile`, not to ad-hoc install steps.

## Working in this repo

- **Changes are live.** Files in `$HOME` are symlinks into `~/dotfiles`, so an edit takes effect as soon as it's saved or re-sourced.
- **Never use git worktrees here.** The symlinks point at `~/dotfiles`, so a worktree can't be tested. Make a branch in `~/dotfiles` itself.
- **This repo is public.** Never commit secrets, tokens, API keys, email addresses, hostnames, employer details, or machine-specific paths and state. Anything that only makes sense on one machine goes in an untracked local file.

## Testing changes

- Shell files: `bash -n <file>`, then `source ~/.bashrc` (or open a new shell).
- tmux: `tmux source-file ~/.tmux.conf`.
- vim: `vim +PlugInstall +qall` after changing plugins, then open vim and check for startup errors.
- Brewfile: `brew bundle check`.
- `setup.sh` is safe to re-run because it skips existing links. However, each run still re-runs PlugInstall and the `defaults write` commands.
