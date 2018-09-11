# Aliases
alias g='git'
alias gd='git diff'
alias gst='git status'
alias gl='git log'

alias bi='bundle install'
alias be='bundle exec'

alias vi='vim'

alias cds='cd ~/snapsheet'

alias weather='curl wttr.in/chicago'

# Uncomment to use fzf on commandline
# Removed because it's a bit heavy handed for history search, for example.
# [ -f ~/.fzf.bash ] && source ~/.fzf.bash

# git bash completion
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash

  # Alias g='git' for autocompletion
  __git_complete g __git_main
fi

# Appearance
export NO_COLOR='\[\033[0m\]'
color256() { echo "\[\033[38;5;$1m\]"; }
nocolor() { echo $NO_COLOR; }

export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# git-bash-prompt
if [ -f "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR=$(brew --prefix)/opt/bash-git-prompt/share
  source "$(brew --prefix)/opt/bash-git-prompt/share/gitprompt.sh"
fi

export GIT_PROMPT_START="\[$(tput bold)\]$(color256 35)(\w)$(nocolor)"
export GIT_PROMPT_END=" _LAST_COMMAND_INDICATOR_ $(nocolor)$ "

export EDITOR=vim

# PATH adjustments
export PATH=${PATH}:/usr/local/mysql/bin
export PATH=${PATH}:$HOME/snapsheet/git-scripts
export PATH=${PATH}:$HOME/bin

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change. (added by RVM)
export PATH="$PATH:$HOME/.rvm/bin"
source ~/.rvm/scripts/rvm
