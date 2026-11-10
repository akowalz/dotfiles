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

# Diff viewers: gd + where it opens. gdv vim, gdt terminal, gdw terminal and watching,
# gdc VS Code (code), gdgh GitHub (bin/gdgh). They take the same arguments:
#   (none)   uncommitted changes, new files included
#   b        the whole branch: everything since it left main, uncommitted changes included
#   other    passed to git, e.g. gdt HEAD~3 or gdt --staged
# gdgh always shows the branch, as pushed, since GitHub can't see anything else. gdc takes
# nothing, b or one commit, and not other git arguments.

# The commit where this branch left the main branch (origin/HEAD, else main or master), the
# same base as BranchBase in vim/plugin/branchsigns.vim.
_branch_base() {
  local main
  for main in origin/HEAD main master; do
    git merge-base HEAD $main 2>/dev/null && return
  done
  echo "No main or master branch to compare with." >&2
  return 1
}

# Sets reply to a diff viewer's arguments: b becomes the branch's base, and no arguments
# become HEAD (not in a brand-new repo, which has none). With "keep-empty" first, no arguments
# stay none, for diffview, whose default already covers uncommitted changes.
_diff_args() {
  local keep_empty
  [[ $1 == keep-empty ]] && { keep_empty=1; shift; }
  reply=("$@")
  if [[ $1 == b ]]; then
    local base
    base=$(_branch_base) || return
    reply=($base "${@:2}")
  elif (( ! $# )) && [[ -z $keep_empty ]] && git rev-parse -q --verify HEAD >/dev/null; then
    reply=(HEAD)
  fi
}

# gdv: side by side in Neovim's diffview.nvim (vim/lua/nvim.lua). q quits.
gdv() {
  local reply
  _diff_args keep-empty "$@" || return
  # diffview opens in a tab of its own; tabonly drops the empty one nvim started with
  nvim -c 'autocmd User DiffviewViewClosed quitall' -c "DiffviewOpen ${reply[*]}" -c tabonly
}

# gdt: in diffnav, one file at a time from a file tree.
gdt() {
  local reply diff
  _diff_args "$@" || return
  diff=$(git diff-all "${reply[@]}") || return
  if [[ -z $diff ]]; then
    echo "No changes."
    return
  fi
  print -r -- "$diff" | diffnav
}

# gdw: gdt that stays open and refreshes every 2 seconds, e.g. in a split next to Claude Code.
gdw() {
  local reply
  _diff_args "$@" || return
  diffnav --watch --watch-cmd "git diff-all ${(j: :)${(q)reply}}"
}

# gdc: in VS Code, every changed file in one multi-file diff tab, new files included, with
# Source Control in the sidebar. The code command can't open that view, so the vscode/gdc
# extension (installed by setup.sh) does: gdc drops a list of the files into
# ~/.cache/gdc/pending, and opens the repo's window, whose copy of the extension picks it up.
# The old side of each diff is a read-only copy of the file, in a temporary folder.
gdc() {
  local reply
  _diff_args "$@" || return
  if (( $#reply > 1 )) || [[ $reply[1] == -* ]]; then
    echo "gdc: takes nothing, b, or one commit" >&2
    return 1
  fi
  if (( ! $+commands[code] )); then
    echo "gdc: VS Code's code command isn't on PATH" >&2
    return 1
  fi
  local root rev=${reply[1]:-HEAD} title tmp list file old new i
  root=$(git rev-parse --show-toplevel) || return
  if ! git -C $root rev-parse -q --verify "$rev^{commit}" >/dev/null; then
    echo "gdc: no commit $rev" >&2
    return 1
  fi
  case $1 in
    '') title='Uncommitted changes' ;;
    b) title="Branch $(git -C $root branch --show-current)" ;;
    *) title="Changes since $1" ;;
  esac

  # each changed path, as A (added), D (deleted) or M (anything else); renames as a D and an A
  local -A kind
  local -a changed=(${(0)"$(git -C $root diff --name-status -z --no-renames $rev)"})
  for (( i = 1; i < $#changed; i += 2 )); do
    kind[$changed[i+1]]=${changed[i]/[^AD]*/M}
  done
  for file in ${(0)"$(git -C $root ls-files -z --others --exclude-standard)"}; do
    kind[$file]=A
  done
  if (( ! $#kind )); then
    echo "No changes."
    return
  fi

  # the list for the extension: NUL-separated, the title, the repo, then per file its path,
  # old side and new side. Written here, then moved into pending in one step, so the extension
  # never reads half a list.
  tmp=$(mktemp -d -t gdc) || return
  list=$tmp/list
  print -rN -- $title $root >$list
  for file in ${(ko)kind}; do
    old= new=$root/$file
    if [[ $kind[$file] != A ]]; then
      old=$tmp/old/$file
      mkdir -p ${old:h}
      git -C $root show "$rev:$file" >$old
      chmod a-w $old
    fi
    [[ $kind[$file] == D ]] && new=
    print -rN -- $root/$file "$old" "$new" >>$list
  done

  mkdir -p ~/.cache/gdc/pending
  mv $list ~/.cache/gdc/pending/${tmp:t}.list
  code $root
  echo "Opened $#kind changed files in VS Code."
}

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
# (source only adds). A login shell stays one, so zprofile runs again too. Refuses while jobs
# are running, since exec would kill them.
# In cmux, it first reloads Ghostty config and cmux.json for every terminal.
reload() {
  if [[ -n $(jobs) ]]; then
    echo "reload: background jobs are running; finish or disown them first" >&2
    return 1
  fi
  [[ -n $CMUX_SOCKET_PATH ]] && cmux reload-config >/dev/null
  if [[ -o login ]]; then exec zsh -l; else exec zsh; fi
}
alias rl=reload

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

# [↻ reload] at the right edge when a file this shell loaded has changed since it started, so
# its aliases and functions are out of date. Only these files are loaded into the shell; bin/
# scripts and other programs' configs are read fresh each time. (Files sourced from elsewhere,
# like fzf's, change only with a brew upgrade.) A changed timestamp alone, from git checkout or
# touch, doesn't count: then the checksum decides. Undoing the edit clears it again.
zmodload -F zsh/stat b:zstat
_rc_files=(~/.zshrc ~/.zshrc.local)
[[ -o login ]] && _rc_files+=(~/.zprofile)
typeset -gA _rc_mtimes _rc_sums
# the linked file's modification time, through the symlink, into $REPLY; empty if it's missing
_rc_mtime() { REPLY=; zstat -A REPLY +mtime -- $1 2>/dev/null }
_rc_sum() { [[ -f $1 ]] && cksum < $1 }
_rc_stale=
for _rc_file in $_rc_files; do
  _rc_mtime $_rc_file; _rc_mtimes[$_rc_file]=$REPLY
  _rc_sums[$_rc_file]=$(_rc_sum $_rc_file)
done
unset _rc_file
_rc_changed_precmd() {
  local file REPLY
  _rc_stale=
  for file in $_rc_files; do
    _rc_mtime $file
    [[ $REPLY == $_rc_mtimes[$file] ]] && continue
    if [[ $(_rc_sum $file) == $_rc_sums[$file] ]]; then
      _rc_mtimes[$file]=$REPLY # same contents: don't checksum again until it changes
    else
      _rc_stale=1
    fi
  done
}
add-zsh-hook precmd _rc_changed_precmd

setopt prompt_subst
# The reload marker goes at the right end of the prompt's first line. RPROMPT can only go on the
# last line, so instead the cursor jumps to the far right (999C stops at the edge), then back 9
# columns, leaving room for the marker's 10. %{ %} tells zsh those escapes take up no space.
# \uf021 is the Nerd Font refresh icon, which Ghostty has built in. Color 11 is bright yellow.
_rc_marker=$'%{\e[999C\e[9D%}'"%F{11}["$'\uf021'" reload]%f"
PROMPT='%B%F{blue}%~%f%b${vcs_info_msg_0_}${_git_mess:+ $_git_mess}%(?.. %F{red}✘ %?${_exit_meaning:+ $_exit_meaning}%f)${_rc_stale:+$_rc_marker}
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
# Commands from gems installed with Homebrew's Ruby (e.g. trmnlp). The directory
# is named after Ruby's version (gems/4.0.0/bin), so take the newest one.
path=($HOMEBREW_PREFIX/lib/ruby/gems/*/bin(Nn[-1]) $path)
# ~/.local/bin holds Claude Code's native install
path=(/usr/local/bin $HOME/bin $HOME/.local/bin $path)

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Machine-specific settings that don't belong in this public repo,
# including language runtimes and version managers (mise, uv, bun, ...)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Plugins (Brewfile)
[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] &&
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Tab takes the grey suggestion when one is showing (like → and Ctrl+E), and completes as usual
# when not, through whatever Tab was bound to before (fzf's completion, so **<Tab> still works).
# autosuggestions must not wrap this widget: its wrapper clears the suggestion before the widget
# runs, so the widget would never see one.
if (( $+functions[_zsh_autosuggest_start] )); then
  # not this widget itself, if this file is sourced again with Tab already bound to it
  _tab_bound=${${(z)$(bindkey '^I')}[2]}
  [[ $_tab_bound == _tab_suggestion_or_complete ]] || _tab_complete_widget=$_tab_bound
  unset _tab_bound
  _tab_suggestion_or_complete() {
    if [[ -n $POSTDISPLAY ]]; then
      zle autosuggest-accept
    else
      zle ${_tab_complete_widget:-expand-or-complete}
    fi
  }
  zle -N _tab_suggestion_or_complete
  ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(_tab_suggestion_or_complete)
  bindkey '^I' _tab_suggestion_or_complete
fi
