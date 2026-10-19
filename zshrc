# Keep PATH entries unique, since nested and login shells re-add them.
# -g keeps them global if this is ever sourced from inside a function (typeset would make them local).
typeset -gU path fpath

# Aliases
alias g='git'
alias gs='git status'
alias gl='git log'
alias gp='git pull --prune'

# git diff, including untracked files as new, so new files get reviewed along with changes.
# It marks them intent-to-add (git add -N) in a throwaway copy of the index,
# so the real index is left alone.
gd() {
  local idx tmp
  idx=$(git rev-parse --git-path index) || return
  tmp=$(mktemp)
  cp "$idx" "$tmp" 2>/dev/null || rm "$tmp" # no index yet in a brand-new repo
  GIT_INDEX_FILE=$tmp git add -N :/
  GIT_INDEX_FILE=$tmp git diff "$@"
  local ret=$?
  rm -f "$tmp"
  return $ret
}

alias bi='bundle install'
alias be='bundle exec'

alias dc-exec='docker compose exec'
alias dc='docker compose'

alias tf='terraform'

alias vi='vim'

alias ll='ls -al'
alias l='fc -e -' # run last command

# Pipe into here to format json nicely, e.g:
# curl http://api.com/endpoint.json | j
alias j='python -m json.tool'

alias weather='curl wttr.in/chicago'

# Replace this shell with a fresh one, so removed aliases and functions go away too
# (source only adds). Refuses while jobs are running, since exec would kill them.
reload() {
  if [[ -n $(jobs) ]]; then
    echo "reload: background jobs are running; finish or disown them first" >&2
    return 1
  fi
  exec zsh
}

# History. zsh saves none by default.
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history      # write each command immediately and share it across shells
setopt extended_history   # record timestamps
setopt hist_ignore_dups
setopt hist_ignore_space  # a leading space keeps a command out of history
setopt hist_reduce_blanks

setopt interactive_comments # allow "# comments" at the prompt

# Key bindings. Emacs mode, like bash; zsh would pick vi mode because EDITOR=vim.
bindkey -e
bindkey '^U' backward-kill-line  # delete to start of line, like bash (zsh deletes the whole line)
WORDCHARS=${WORDCHARS//\/}       # Ctrl+W / Alt+Backspace stop at "/"

# Ctrl+X Ctrl+E: edit the current command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# t (bin/t) takes plain English. noglob passes ? and * through as-is, so
#   t which process is using port 3000?
# works instead of failing with "no matches found". Quote the request when it has
# an apostrophe, $, `backticks` or #, which zsh still interprets:
#   t "find files that don't end in .txt"
alias t='noglob t'

# Completion. git completion comes built in, and covers the g alias.
autoload -Uz compinit
compinit

# fzf (Brewfile): Ctrl+R fuzzy history, Ctrl+T paste a file path, Option+C cd into a subdirectory.
# After bindkey -e and compinit, which would otherwise undo its bindings and completion.
(( $+commands[fzf] )) && source <(fzf --zsh)

# Appearance
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# Prompt: path on branch ●✚? ✘ exit-code
#         ❯
# ● staged, ✚ changed, ? untracked. ❯ turns red when the last command failed.
# Every color here is one of the 16 the terminal theme defines (named ones, and 8 = bright black),
# so the prompt follows the theme. Colors 16-255 would be fixed regardless of theme.
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{green}●'
zstyle ':vcs_info:git:*' unstagedstr '%F{red}✚'
zstyle ':vcs_info:git:*' formats ' %F{8}on%f %F{cyan}%b%c%u%m%f'
zstyle ':vcs_info:git:*' actionformats ' %F{8}on%f %F{cyan}%b%c%u%m %F{yellow}(%a)%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-separator

+vi-git-untracked() {
  if [[ -n $(git ls-files --others --exclude-standard --directory --no-empty-directory -- ':/' 2>/dev/null | head -1) ]]; then
    hook_com[misc]+='%F{cyan}?'
  fi
}

# Put a space between the branch and the status flags, when there are any
+vi-git-separator() {
  if [[ -n ${hook_com[staged]}${hook_com[unstaged]}${hook_com[misc]} ]]; then
    hook_com[branch]+=' '
  fi
}

setopt prompt_subst
PROMPT='%B%F{blue}%~%f%b${vcs_info_msg_0_}%(?.. %F{red}✘ %?%f)
%(?.%F{magenta}.%F{red})❯%f '

export EDITOR=vim

# Tool configs and path adjustments (some of these may not be very cross-platform)
# ~/.local/bin holds Claude Code's native install
path=(/usr/local/bin $HOME/bin $HOME/.local/bin $path)

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Machine-specific settings that don't belong in this public repo,
# including language runtimes and version managers (mise, uv, bun, ...)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Plugins (Brewfile)
[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] &&
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
