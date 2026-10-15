# Keep PATH entries unique, since nested and login shells re-add them.
# -g, because reload sources this from inside a function, where typeset would make them local.
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

alias dc-exec='docker-compose exec'
alias dc='docker-compose'

alias tf='terraform'

alias vi='vim'

alias ll='ls -al'
alias l='fc -e -' # run last command

# Default docker ps output is too wide
alias dps='docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"'

# Pipe into here to format json nicely, e.g:
# curl http://api.com/endpoint.json | j
alias j='python -m json.tool'

alias weather='curl wttr.in/chicago'

reload() {
  source ~/.zshrc;
  echo 'Done.';
}

# --- Claude Code worktrees ---
# Worktrees live at .claude/worktrees/<name> on branch worktree-<name>.
# Each command takes the name or the branch name, and works from anywhere in the repo.
#   wtcd <name>          cd into the worktree
#   wthome               cd back to the main checkout
#   wtdiff <name> [...]  diff the worktree (incl. uncommitted) against where it forked
#   wtmerge <name> [...] merge worktree-<name> into the current branch

_wt_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir) || return
  dirname "$common"
}

_wt_dir() {
  local root name
  root=$(_wt_root) || return
  name=${1#worktree-}
  if [ -z "$name" ] || [ ! -d "$root/.claude/worktrees/$name" ]; then
    echo "No worktree '$name'. Existing:" >&2
    ls "$root/.claude/worktrees" >&2 2>/dev/null
    return 1
  fi
  echo "$root/.claude/worktrees/$name"
}

wtcd() {
  local dir
  dir=$(_wt_dir "$1") && cd "$dir"
}

wthome() {
  local root
  root=$(_wt_root) && cd "$root"
}

wtdiff() {
  local dir branch="worktree-${1#worktree-}"
  dir=$(_wt_dir "$1") || return
  shift
  git -C "$dir" diff "$(git merge-base HEAD "$branch")" "$@"
}

wtmerge() {
  local dir branch="worktree-${1#worktree-}"
  dir=$(_wt_dir "$1") || return
  shift
  if [ -n "$(git -C "$dir" status --porcelain)" ]; then
    echo "Warning: $branch has uncommitted changes that won't be merged." >&2
  fi
  git merge "$branch" "$@"
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

# Completion. git completion comes built in, and covers the g alias.
autoload -Uz compinit
compinit

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
