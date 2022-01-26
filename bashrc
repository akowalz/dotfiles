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
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}"'

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
export NO_COLOR='\[\033[0m\]'
color256() { echo "\[\033[38;5;$1m\]"; }

export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# git-bash-prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

export GIT_PROMPT_START="\[$(tput bold)\]$(color256 35)(\w)$NO_COLOR"
export GIT_PROMPT_END=" _LAST_COMMAND_INDICATOR_ $NO_COLOR\n$ "

export EDITOR=vim

# Hide annoying warning to use zsh on Catalina
export BASH_SILENCE_DEPRECATION_WARNING=1

# Tool configs and path adjustments (some of these may not be very cross-platform)
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:~/.composer/vendor/bin
export PATH=$HOME/bin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.poetry/bin:$PATH

# Post install steps of `brew install nvm`
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Load rbenv
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# Load pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

if [[ -f "$HOME/dotfiles/tegus_bashrc.sh" ]]; then
  source "$HOME/dotfiles/tegus_bashrc.sh"
fi
