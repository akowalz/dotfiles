[[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[[ -s "$HOME/.bashrc" ]] && source "$HOME/.bashrc" # Load .bashrc

export PATH="$HOME/.poetry/bin:$PATH"
