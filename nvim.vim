" Neovim's config, linked to ~/.config/nvim/init.vim: it uses Vim's own setup, so
" there's one config for both. vimrc keeps the differences behind has('nvim').
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
