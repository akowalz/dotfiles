# Aliases
alias g='git'
alias gd='git diff'
alias gst='git status'
alias gl='git log'

alias bi='bundle install'
alias be='bundle exec'

alias vi='vim'

alias cds='cd ~/snapsheet'

export EDITOR=vim

# git-bash-prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

# Added by FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export GIT_PROMPT_START="\[\e[0;93m\](\w)\[\e[0m\]"
export GIT_PROMPT_END=" _LAST_COMMAND_INDICATOR_ $ "

# PATH adjustments
export PATH=${PATH}:/usr/local/mysql/bin
export PATH=${PATH}:/Users/alexkowalczuk/snapsheet/git-scripts

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change. (added by RVM)
export PATH="$PATH:$HOME/.rvm/bin"
source ~/.rvm/scripts/rvm
