# Environment ------------------------------------------------------------ {{{
eval "$(/opt/homebrew/bin/brew shellenv)"

export EDITOR=vim

# Hide annoying warning to use zsh on Catalina
export BASH_SILENCE_DEPRECATION_WARNING=1

# PATH adjustments (some of these may not be very cross-platform)
export PATH=$HOME/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"
# }}}

# Aliases ---------------------------------------------------------------- {{{
# Git
alias g='git'
alias gd='git diff'
alias gs='git status'
alias gl='git log'
alias gp='git pull --prune'

# Ruby
alias bi='bundle install'
alias be='bundle exec'

# Docker
alias dc='docker-compose'
alias dc-exec='docker-compose exec'
# Default docker ps output is too wide
alias dps='docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"'

# Misc
alias tf='terraform'
alias vi='vim'
alias ll='ls -al'
alias l='fc -s' # run last command

# Pipe into here to format json nicely, e.g:
# curl http://api.com/endpoint.json | j
alias j='python -m json.tool'

alias weather='curl wttr.in/chicago'
# }}}

# Functions -------------------------------------------------------------- {{{
reload() {
  source ~/.bashrc;
  echo 'Done.';
}
# }}}

# Completion ------------------------------------------------------------- {{{
# git bash completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash

  # Alias g='git' for autocompletion
  __git_complete g __git_main
else
  echo 'Git bash completion not installed, run install.sh'
fi
# }}}

# Prompt and colors ------------------------------------------------------ {{{
export END_COLOR='\[\033[0m\]'
color256() { echo "\[\033[38;5;$1m\]"; }

export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# git-bash-prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

export GIT_PROMPT_START="\[$(tput bold)\]$(color256 35)(\w)$END_COLOR"
export GIT_PROMPT_END=" _LAST_COMMAND_INDICATOR_ $END_COLOR\n$ "
# }}}

# Tools ------------------------------------------------------------------ {{{
# uv
. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion bash)"

# direnv
eval "$(direnv hook bash)"

# bun (installed per-user in ~/.bun)
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
# }}}

# vim: foldmethod=marker
