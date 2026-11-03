# AGENTS.md

Personal dotfiles for macOS: zsh, vim, tmux, git, cmux/Ghostty, plus small scripts in `bin/`.

## Layout

`setup.sh` symlinks each of these repo files to `~/.<name>`:
`zshrc`, `zprofile`, `gitconfig`, `gitignore`,
`tmux.conf`, `vim/`, `vimrc`. It also links each script in `bin/` into a real `~/bin` directory, so other tools that install into `~/bin` stay out of this repo.
Claude Code's settings (`~/.claude/settings.json`) are deliberately not tracked: Claude Code saves them by
replacing the file, which turns a symlink back into a plain file.
Its status line script is tracked, though: `bin/claude-statusline`, which that settings file runs as `~/bin/claude-statusline`.
cmux's settings live in `cmux.json`, linked to `~/.config/cmux/cmux.json` (`symlink` takes an optional destination).
`ghostty.conf` is linked to `~/.config/ghostty/config`; cmux reads it for terminal behavior.
`diffnav.yml` is linked to `~/.config/diffnav/config.yml`.
`nvim.vim` is linked to `~/.config/nvim/init.vim`. Neovim is the editor (`EDITOR`, and `vi`/`vim` are aliases for it), and it reads `vim/` and `vimrc`, which still work in plain Vim. Keep them working in both: Neovim-only parts go behind `has('nvim')` in vimrc or in `vim/lua/nvim.lua`, and Vim-only parts behind `!has('nvim')`.

- It never overwrites anything. A file already at a destination (say, a `~/.zshrc` an installer wrote) moves aside to `<dest>.pre-dotfiles`, and the run ends by listing them.
- It removes links into this repo whose file is gone (say, `~/.bashrc` from before the switch to zsh), and leaves other broken links alone.
- A new top-level config file needs its own `symlink <name>` line in `setup.sh`.
- `gitignore` is the global git excludes file. `.gitignore` is this repo's own ignore file.
- Custom scripts go in `bin/` (on PATH via `~/bin`). Make them executable, give them a shebang, and re-run `setup.sh` (or `ln -s`) to link a new one.

## Bootstrapping a new machine

1. `./install.sh` installs Homebrew if it's missing and runs `brew bundle` (Brewfile).
2. `./setup.sh` creates the symlinks, makes zsh your login shell (`chsh` asks for your password), runs `vim +PlugInstall +qall` (vim-plug, installing into `vim/plugged/`, which is gitignored), and runs `macos.sh`.
3. Create `~/.gitconfig.local` with a `[user]` name and email. `gitconfig` includes it, so the identity stays out of this repo.

Add Homebrew packages to `Brewfile`, not to ad-hoc install steps.
Add macOS settings (`defaults write` and the like) to `macos.sh`, grouped under a comment for their area, with a comment saying what each one does.

## Working in this repo

- **Changes are live.** Files in `$HOME` are symlinks into `~/dotfiles`, so an edit takes effect as soon as it's saved or re-sourced.
- **Never use git worktrees here.** The symlinks point at `~/dotfiles`, so a worktree can't be tested. Make a branch in `~/dotfiles` itself.
- **This repo is public.** Never commit secrets, tokens, API keys, email addresses, hostnames, employer details, or machine-specific paths and state. Anything that only makes sense on one machine goes in an untracked local file.

## Testing changes

- Shell files: `zsh -n <file>` (`bash -n` for the bash scripts), then `source ~/.zshrc` (or open a new shell).
- tmux: `tmux source-file ~/.tmux.conf`.
- vim plugins: run `nvim +PlugInstall +qall` after changing them, then open nvim and `command vim` and check both for startup errors.
- Brewfile: `brew bundle check`.
- `setup.sh` is safe to re-run because it skips links that are already in place. However, each run still re-runs PlugInstall and `macos.sh`.
- macOS settings: `bash -n macos.sh`, then `./macos.sh` on its own. Check a value with `defaults read <domain> <key>`.
- Ask user to individually test changes
