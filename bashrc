# Aliases
alias g='git'
alias gd='git diff'
alias gst='git status'
alias gl='git log'

alias bi='bundle install'
alias be='bundle exec'

alias dc-exec='docker-compose exec'

alias tf='terraform'

alias vi='vim'

alias ll='ls -al'
alias l='fc -s' # run last command

alias cdl='cd ~/dev/localdev'
alias cdh='cd ~/dev/Hosted'

# Pipe into here to format json nicely, e.g:
# curl http://api.com/endpoint.json | j
alias j='python -m json.tool'

alias weather='curl wttr.in/chicago'

ac-clone() { git clone git@github.com:ActiveCampaign/$1.git; }

dsh() { docker-compose exec $1 bash; }

# git bash completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash

  # Alias g='git' for autocompletion
  __git_complete g __git_main
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
export GIT_PROMPT_END=" _LAST_COMMAND_INDICATOR_ $NO_COLOR$ "

export EDITOR=vim

# PATH adjustments
export PATH=${PATH}:/usr/local/mysql/bin
export PATH=$HOME/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Set docker machine environment
eval `docker-machine env`
