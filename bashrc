eval "$(/opt/homebrew/bin/brew shellenv)"

# Aliases
alias g='git'
alias gd='git diff'
alias gs='git status'
alias gl='git log'
alias gp='git pull --prune'

alias bi='bundle install'
alias be='bundle exec'

alias dc-exec='docker-compose exec'
alias dc='docker-compose'

alias tf='terraform'

alias vi='vim'

alias ll='ls -al'
alias l='fc -s' # run last command

# Default docker ps output is too wide
alias dps='docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"'

# Pipe into here to format json nicely, e.g:
# curl http://api.com/endpoint.json | j
alias j='python -m json.tool'

alias weather='curl wttr.in/chicago'

reload() {
  source ~/.bashrc;
  echo 'Done.';
}

# git bash completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash

  # Alias g='git' for autocompletion
  __git_complete g __git_main
else 
  echo 'Git bash completion not installed, run install.sh'
fi

# Appearance
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

export EDITOR=vim

# Hide annoying warning to use zsh on Catalina
export BASH_SILENCE_DEPRECATION_WARNING=1

# Tool configs and path adjustments (some of these may not be very cross-platform)
export PATH=$HOME/bin:$PATH
export PATH=/usr/local/bin:$PATH

export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

. "$HOME/.local/bin/env"
eval "$(uv generate-shell-completion bash)"

# direnv
eval "$(direnv hook bash)"

# bun (installed per-user in ~/.bun)
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"
