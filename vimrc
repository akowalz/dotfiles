" Plugins ------------------- {{{
call plug#begin('~/.vim/plugged')

" Navigation
Plug 'scrooloose/nerdtree'
" Tools
Plug 'w0rp/ale'
Plug 'benmills/vimux'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'alvan/vim-closetag'
Plug 'tomtom/tcomment_vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-projectionist'

" Syntax highlighers
Plug 'pangloss/vim-javascript'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'mustache/vim-mustache-handlebars'
Plug 'hdima/python-syntax'
Plug 'posva/vim-vue'
Plug 'leafgarland/typescript-vim'

" Colors and appearance
Plug 'NLKNguyen/papercolor-theme'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
call plug#end()
" }}}

" General settings ---------- {{{
set hlsearch
set number
set showmatch
set incsearch
set hidden
set backspace=indent,eol,start
set textwidth=0 nosmartindent tabstop=2 shiftwidth=2 softtabstop=2 expandtab
set wrap
set dir=/tmp//
set scrolloff=5
set ignorecase
set smartcase
set wildignore+=*.pyc,*.o,*.class,*.lo,.git,vendor/*,node_modules/**,bower_components/**,*/build_gradle/*,*/build_intellij/*,*/build/*,*/cassandra_data/*
set mouse=
set ttymouse=
set tags=./tags,tags,ctags
set foldlevelstart=99
set splitright
set listchars=trail:_
set list
" }}}

" Appearance ---------------- {{{
set background=dark

let g:PaperColor_Theme_Options = {
      \   'theme': {
      \     'default.dark': {
      \       'transparent_background': 1
      \     }
      \   }
      \ }

colorscheme PaperColor

set laststatus=2
set noshowmode " don't show -- INSERT -- because lightline does it for you

" always show the sign column so ALE doesn't bump the buffer around
set signcolumn=yes

" sign column (left bar) should display in same color as rest of vim
highlight SignColumn ctermbg=NONE
highlight Folded ctermbg=Black
" }}}

" Autocommands -------------- {{{
"
" Write file when leaving insert mode, unless buffer is not saved
augroup write_on_leave_insert
  autocmd!
  autocmd InsertLeave * if !(@% == '') | update | endif
augroup END

" Set filetype to javascript for js.snap files
augroup filetype_for_js_snap_file
  autocmd!
  autocmd BufNewFile,BufRead *.js.snap set filetype=javascript.jsx
augroup END

" Set filetype to dosini for gitconfig file
augroup filetype_for_js_snap_file
  autocmd!
  autocmd BufNewFile,BufRead *gitconfig set filetype=dosini
augroup END

augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END


" Automatically open quickfix window after grepping
augroup grep_window
  autocmd!
  autocmd QuickFixCmdPost *grep* copen
augroup END

" }}}

" Plugin Settings ----------- {{{
"
" FZF
let g:fzf_layout = { 'down': '~25%' }
let $FZF_DEFAULT_COMMAND = 'find * -type f 2>/dev/null | grep -v -E "deps/|_build/|node_modules/|vendor/"'

" NERDTree
let g:NERDCreateDefaultMappings = 0

" ale
highlight ALEErrorSign ctermbg=NONE ctermfg=DarkRed
highlight ALEWarningSign ctermbg=NONE ctermfg=Yellow

let g:ale_fixers = {'javascript': ['eslint'], 'ruby': ['rubocop'], 'php' : 'phpcbf'}
let g:ale_sign_error = "•"
let g:ale_sign_warning = "-"
let g:ale_set_highlights = 0
let g:ale_echo_msg_format = '[%linter%]: %s'

" Lightline
let g:lightline = {}
let g:lightline#ale#indicator_ok = '✔'

let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified', 'linter_checking', 'linter_ok'] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFullPath',
      \ },
      \ 'component_expand': {
      \     'linter_checking': 'lightline#ale#checking',
      \     'linter_ok': 'lightline#ale#ok',
      \   },
      \ }

function! LightlineFullPath()
  return expand('%')
endfunction
" }}}

" Mappings ------------------ {{{
"
" Set leader to space
let mapleader ="\<Space>"
nnoremap \\ <NOP>

" Insert mode mappings
" Exit insert mode with jk.
inoremap jk <ESC>

" Allow moving between wrapped lines.
nnoremap j gj
nnoremap k gk

" Ctrl-l in insert mode to insert a hash rocket
inoremap <C-L> <SPACE>=><SPACE>

" Ctrl-f in insert mode to insert an empty arrow function
inoremap <C-F> ()<SPACE>=><SPACE>{

" Write with <Leader>w
nnoremap <Leader>w :write<CR>

" Disable ex mode
nnoremap Q <NOP>

" Toggle paste mode and enter insert mode with <Leader>pp
nnoremap <Leader>pp :set paste!<CR>

" Go back to the previous file with C-e
nnoremap <C-e> :e#<CR>

" Indent whole file while preserving cursor location with <Leader>i or <Leader>=
nnoremap <Leader>i m'gg=G`'
nnoremap <Leader>= m'gg=G`'

" Clear search highlighting with or Ctrl-l
nnoremap <C-l> :let @/ = ""<CR>

" Clear trailing whitespace with <Leader>cw
nnoremap <Leader>cw :%s/\s\+$//g<CR>:nohlsearch<CR>

" Change the current `test` to `test.only` with <Leader>on
nnoremap <Leader>on ?test(<CR>ea.only<ESC>:noh<CR>

" Add a semicolon to the current line without moving the cursor with <Leader>;
nnoremap <Leader>; m'A;<ESC>`'

" Change single quotes to double quotes with <Leader>''
nnoremap <Leader>"" m'F'r"f'r"`'

" Change double quotes to single quotes with <Leader>''
nnoremap <Leader>'' m'F"r'f"r'`'

" Fold/Unfold with <Leader>ff
nnoremap <Leader>ff za

" Source vimrc with <Leader>vc
nnoremap <Leader>vc :source ~/.vimrc<CR>:echo "Reloaded .vimrc"<CR>

" Rebuild ctags with <Leader>ct
nnoremap <Leader>ct :!ctags -R .<CR>:echo 'Rebuilt ctags'<CR>

" Jump to ctag with <C-enter>
nnoremap <C-CR> <C-]>

" Plugin Command Mappings

" Nerdtree mappings
nnoremap <Leader>nt :NERDTreeToggle<CR>
nnoremap <Leader>nr :NERDTree<CR>
nnoremap <Leader>nf :NERDTreeFind<CR>

" ALE
nnoremap <Leader>af :ALEFix<CR>

" Toggle commenting with Ctrl-\
map <C-\> :TComment<CR>

" FZF - search for files with Ctrl P
nnoremap <C-p> :Files<CR>

"Fugitive
" <Leader>gg to search for the word under the cursor with Ggrep
nnoremap <Leader>gg :Ggrep <cword><CR>
" }}}

nnoremap <Leader>ft :call FindCorrespondingTestFile()<CR>

" Markdown and deskset mappings
" New slide
nnoremap <Leader>ns o<CR>---<CR><CR><ESC>

" New code fence
nnoremap <Leader>cf o<CR>```<CR>```<ESC>O

" Vimux --------------------- {{{
source ~/.vim/vimux_settings.vim
"}}}
