# Vim refresh: what changed

> **Don't commit this note onto master.** It's only for the `vim-refresh`
> branch. Before merging, remove it with `git rm VIM-REFRESH.md && git commit`,
> or drop its commit.

## Picking this up on another machine

```sh
git fetch && git checkout vim-refresh
brew bundle                        # installs the new language servers
vim +PlugClean! +PlugInstall +qall # drops the removed plugins, installs the new ones
```

## Look

- One Dark (`joshdick/onedark.vim`) in true color, on a near-black `#0a0a0a`
  background (`g:onedark_color_overrides` in vimrc), with italic comments
- lightline in One Dark colors, now showing the git branch
- Bar cursor in insert mode, underline in replace mode, block otherwise
- Thin solid split lines, no `~` past the end of a file, the current line's
  number brightened
- `»` for tabs (they used to show as `^I`), `·` for trailing spaces
- Ctrl-P opens fzf in a floating window with a preview; files are listed with
  `fd`, which skips whatever `.gitignore` lists

## Feel

- No second's wait after `Esc` (`ttimeout` was never set)
- Undo history survives restarts (`~/.local/state/vim/undo`)
- Yanked text flashes (`hlyank`); a project's `.editorconfig` is followed
- `:` completions pop up in a menu and match fuzzily
- Wrapped lines keep their indent and break between words

## LSP (`yegappan/lsp`)

- `gd` definition, `gr` references, `K` docs, `[d` / `]d` previous/next
  problem, `<Leader>d` problem on this line, `<Leader>rn` rename,
  `<Leader>ca` code action
- Errors get a curly underline, with the message after the line
- Completion is manual: `<C-x><C-o>`
- Servers (Brewfile):
  - TypeScript/JS in a project on TypeScript 6 or older, and Vue's
    `<script>`: `typescript-language-server`, plus the Vue TypeScript plugin
    from `vue-language-server`
  - TypeScript/JS anywhere else: TypeScript 7's own server (`tsc --lsp`).
    Homebrew's `typescript` is 7, which has no `tsserver.js`.
  - Ruby: `ruby-lsp`. It creates a `.ruby-lsp/` folder in each project (that
    folder ignores itself in git).
  - Python: `pyright`
  - Swift: `sourcekit-lsp`, from Xcode

## Git gutter (`vim-gitgutter`)

- Thin bars for added and changed lines
- `]c` / `[c` next/previous hunk, `<Leader>hp` preview (popup), `<Leader>hs`
  stage, `<Leader>hu` undo

## Cleanup

- Removed ALE, vimux, `lightline-ale`, PaperColor, `typescript-vim` and
  `python-syntax` (Vim's own TypeScript and Python syntax are better)
- fzf's vim plugin comes from Homebrew's fzf instead of a separate `~/.fzf`
  clone, which can be deleted
- Fixed: the gitconfig augroup reused the js.snap one's name, so `*.js.snap`
  files never got their filetype
- Removed `<Leader>ft`, which called a function deleted long ago
- tmux passes true color and curly underlines through to the terminal.
  Italics still don't show inside tmux, because its `TERM` is
  `screen-256color`.
