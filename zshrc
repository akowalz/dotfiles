# Keep PATH entries unique, since nested and login shells re-add them.
# -g keeps them global if this is ever sourced from inside a function (typeset would make them local).
typeset -gU path fpath

# Aliases
alias g='git'
alias gs='git status'
alias gl='git log'
alias gp='git pull --prune'

# git diff, including untracked files as new (bin/git-diff-all). Takes git diff's arguments.
alias gd='git diff-all'

# gv: browse everything changed since the last commit (staged, unstaged and new files) in diffnav,
# one file at a time from a file tree. Arguments replace HEAD, e.g. gv --staged or gv main.
gv() {
  local diff args=("$@")
  # no HEAD yet in a brand-new repo
  (( $# )) || ! git rev-parse -q --verify HEAD >/dev/null || args=(HEAD)
  diff=$(git diff-all "${args[@]}") || return
  if [[ -z $diff ]]; then
    echo "No changes."
    return
  fi
  print -r -- "$diff" | diffnav
}

# dv: review changes side by side in Neovim's diffview.nvim (vim/lua/nvim.lua).
# Arguments go to :DiffviewOpen, e.g. dv master... for the branch or dv HEAD~3. q quits.
dv() {
  # diffview opens in a tab of its own; tabonly drops the empty one nvim started with
  nvim -c 'autocmd User DiffviewViewClosed quitall' -c "DiffviewOpen $*" -c tabonly
}

# gdw: gv that stays open and refreshes every 2 seconds, e.g. in a split next to Claude Code.
alias gdw='diffnav --watch --watch-cmd "git diff-all HEAD"'

alias bi='bundle install'
alias be='bundle exec'

alias dc-exec='docker compose exec'
alias dc='docker compose'

alias tf='terraform'

# Neovim is the editor; plain Vim is still there as `command vim`, on the same config
alias vi='nvim'
alias vim='nvim'

alias ll='ls -al'
alias l='fc -e -' # run last command

mkcd() { mkdir -p -- "$1" && cd -- "$1"; } # make a directory and cd into it
alias cpwd='print -rn -- $PWD | pbcopy'    # copy the current directory's path

# Pipe into here to format json nicely, e.g:
# curl http://api.com/endpoint.json | j
alias j='python -m json.tool'

alias md='glow -p -w 85' # read a markdown file rendered, in a pager

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

# Key bindings. Emacs mode, like bash; zsh would pick vi mode because EDITOR=nvim.
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
# The function tells t about your aliases and functions, then runs the command it gets
# back here, so they work (and so do cd and export). It also adds the command to history,
# so up-arrow brings it back.
# (Written "function t", not "t()", so the alias below can't expand in its name when this
# file is sourced again.)
function t {
  local cmd_file=$(mktemp) cmd ret
  T_CMD_FILE=$cmd_file T_ALIASES=$(alias) T_FUNCTIONS=${(kj: :)functions:#[_.+-]*} \
    command t "$@"
  ret=$?
  cmd=$(<$cmd_file)
  rm -f $cmd_file
  (( ret )) && return ret
  print -rs -- "$cmd"
  eval "$cmd"
}
alias t='noglob t'

# Completion. git completion comes built in, and covers the g alias.
autoload -Uz compinit
compinit

# fzf (Brewfile): Ctrl+R fuzzy history, Ctrl+T paste a file path, Option+C cd into a subdirectory.
# After bindkey -e and compinit, which would otherwise undo its bindings and completion.
(( $+commands[fzf] )) && source <(fzf --zsh)
# List with fd, so pickers skip whatever .gitignore ignores (build output, vendor, ...).
if (( $+commands[fd] )); then
  export FZF_CTRL_T_COMMAND='fd --hidden --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

# Appearance
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# Prompt: path on branch ●2 ✚3 −1 ?4 ↑1 ✘ exit-code meaning
#         ❯
# Counts of staged, changed, deleted, (✖ conflicted,) untracked files and commits ahead/behind,
# from bin/git-mess.
# ❯ turns red when the last command failed.
# Every color here is one of the 16 the terminal theme defines (named ones, and 8 = bright black),
# so the prompt follows the theme. Colors 16-255 would be fixed regardless of theme.
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{8}on%f %F{cyan}%b%f'
zstyle ':vcs_info:git:*' actionformats ' %F{8}on%f %F{cyan}%b %F{yellow}(%a)%f'

_git_mess_precmd() {
  _git_mess=$(git-mess --prompt)
}
add-zsh-hook precmd _git_mess_precmd

# What a failed command's exit code means, when it means the same for every command: 126
# and 127 come from the shell, and 128+n is a command stopped by signal n. Other codes
# (1, 2, 5...) are each program's own, so they get no label.
_exit_meaning_precmd() {
  local code=$?
  case $code in
    126) _exit_meaning='not executable' ;;
    127) _exit_meaning='not found' ;;
    130) _exit_meaning='interrupted' ;; # Ctrl-C
    137) _exit_meaning='killed' ;;
    141) _exit_meaning='broken pipe' ;;
    143) _exit_meaning='terminated' ;;
    148) _exit_meaning='suspended' ;; # Ctrl-Z
    *) # any other signal by name, e.g. SIGSEGV; $signals[1] is EXIT, so signal n is n+1
      if (( code > 128 && code - 127 <= ${#signals} )); then
        _exit_meaning="SIG${signals[code - 127]}"
      else
        _exit_meaning=
      fi ;;
  esac
}
# first, so $? is still the command's and not another hook's
precmd_functions=(_exit_meaning_precmd $precmd_functions)

setopt prompt_subst
PROMPT='%B%F{blue}%~%f%b${vcs_info_msg_0_}${_git_mess:+ $_git_mess}%(?.. %F{red}✘ %?${_exit_meaning:+ $_exit_meaning}%f)
%(?.%F{magenta}.%F{red})❯%f '

# boop: append to a long command to hear and see when it's done, e.g. make build ; boop
# Glass on success, Basso on failure, plus a notification (inside cmux, on this pane).
# Keeps the command's exit status, so make build ; boop && deploy still works.
_boop_preexec() {
  _boop_cmd=$1
  _boop_start=$SECONDS
}
add-zsh-hook preexec _boop_preexec

boop() {
  local code=$? title sound cmd elapsed
  setopt local_options extended_glob
  cmd=${${_boop_cmd%;*}%%[[:space:]]#} # drop the "; boop"
  elapsed=$(( SECONDS - _boop_start ))
  (( elapsed >= 60 )) && elapsed="$(( elapsed / 60 ))m $(( elapsed % 60 ))s" || elapsed+=s
  if (( code == 0 )); then
    title='✓ Done' sound=Glass
  else
    title="✘ Failed (exit $code)" sound=Basso
  fi
  afplay /System/Library/Sounds/$sound.aiff &!
  if [[ -n $CMUX_WORKSPACE_ID ]] && (( $+commands[cmux] )); then
    cmux notify --title $title --body "$cmd · $elapsed" >/dev/null
  else
    osascript -e 'on run argv' -e 'display notification (item 2 of argv) with title (item 1 of argv)' \
      -e 'end run' $title "$cmd · $elapsed"
  fi
  return code
}

export EDITOR=nvim

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
