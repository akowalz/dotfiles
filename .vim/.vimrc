" Plugins via vim-plug
call plug#begin('~/.vim/plugged')
  " Navigation
  Plug 'scrooloose/nerdtree'

  " Tools
  Plug 'benmills/vimux'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-endwise'
  Plug 'tomtom/tcomment_vim'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'

  " Syntax highlighers
  Plug 'mxw/vim-jsx'
  Plug 'tpope/vim-rails'
  Plug 'vim-ruby/vim-ruby'

  " Colors and appearance
  Plug 'NLKNguyen/papercolor-theme'
  Plug 'itchyny/lightline.vim'
call plug#end()

" General settings
set hlsearch
set number
set showmatch
set incsearch
set hidden
set backspace=indent,eol,start
set textwidth=0 nosmartindent tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set ruler
set wrap
set dir=/tmp//
set scrolloff=5
set ignorecase
set smartcase
set wildignore+=*.pyc,*.o,*.class,*.lo,.git,vendor/*,node_modules/**,bower_components/**,*/build_gradle/*,*/build_intellij/*,*/build/*,*/cassandra_data/*
set mouse=
set ttymouse=

" Appearance
set background=dark
let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default.dark': {
  \       'transparent_background': 1
  \     }
  \   }
  \ }
colorscheme PaperColor

" Autocommands
augroup markdown
  autocmd!
  au BufNewFile,BufRead *.md,*.markdown setlocal filetype=ghmarkdown
augroup END

augroup cursorline_in_insert_mode
  autocmd!
  autocmd InsertEnter,InsertLeave * set cul!
augroup END

" Status line
set laststatus=2

" Plugging Settings
let g:fzf_layout = { 'up': '~25%' }

let g:NERDCreateDefaultMappings = 0

let $FZF_DEFAULT_COMMAND = 'find * -type f 2>/dev/null | grep -v -E "deps/|_build/|node_modules/|vendor/"'

" Mappings
nnoremap <silent> <Leader>nh :noh<CR>
nnoremap <silent> <Leader>vc :source ~/.vimrc<CR>
nnoremap <silent> Q <NOP>

nnoremap <silent> k gk
nnoremap <silent> j gj
nnoremap <silent> Y y$

imap <C-L> <SPACE>=><SPACE>
imap <C-J> <SPACE>-><SPACE>
imap <silent> jk <ESC>

" Plugin Mappings
" Nerdtree mappings
nnoremap <silent> <Leader>nt :NERDTreeToggle<CR>
nnoremap <silent> <Leader>nr :NERDTree<CR>
nnoremap <silent> <Leader>nf :NERDTreeFind<CR>

" TComment leader cc to toggle comments
map <silent> <LocalLeader>cc :TComment<CR>

" Map FZF to Ctrl P
nnoremap <silent> <C-p> :Files<CR>

" Command aliases
command! W w

" Vimux
function! SpecBaseCmd()
  if (&filetype=='javascript.jsx')
    return "npm test "
  elseif filereadable(".zeus.sock")
    return "zeus rspec "
  else
    return "bundle exec rspec "
  endif
endfunction

let run_buffer_cmd = SpecBaseCmd() . bufname("%")
let run_focused_cmd = SpecBaseCmd() . bufname("%") . ":" . line(".")

function! ClearAndEchoCmd(cmd)
  return "clear && echo " . a:cmd . " && " . a:cmd
endfunction

nnoremap <silent> <Leader>rb :call VimuxRunCommand(ClearAndEchoCmd(run_buffer_cmd))<CR>
nnoremap <silent> <Leader>rf :call VimuxRunCommand(ClearAndEchoCmd(run_focused_cmd))<CR>
nnoremap <silent> <Leader>rl :VimuxRunLastCommand<CR>
nnoremap <silent> <Leader>vp :VimuxPromptCommand<CR>
