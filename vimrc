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
Plug 'tpope/vim-sleuth'
Plug 'alvan/vim-closetag'
Plug 'tomtom/tcomment_vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'jlanzarotta/bufexplorer'

" Syntax highlighers
Plug 'pangloss/vim-javascript'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'mustache/vim-mustache-handlebars'

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
set foldlevelstart=99

set splitright
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

augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
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

if filereadable('php-coding-standards/ActiveCampaign/ruleset.xml')
  let g:ale_phpcs_standard='php-coding-standards/ActiveCampaign/ruleset.xml'
  let g:ale_php_phpcbf_standard='php-coding-standards/ActiveCampaign/ruleset.xml'
else
  let g:ale_php_phpcs_standard = 'PSR2'
  let g:ale_php_phpcbf_standard = 'PSR2'
endif


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

" search for documentation in Dash for word under cursor with <Leader>da
nnoremap <Leader>da :!open 'dash://<cword>'<CR>

" Ctrl-l in insert mode to insert a hash rocket
inoremap <C-L> <SPACE>=><SPACE>

" Write with <Leader>w
nnoremap <Leader>w :write<CR>

" Disable ex mode
nnoremap Q <NOP>

" Toggle paste mode and enter insert mode with <Leader>pp
nnoremap <Leader>pp :set paste!<CR>

" Go back to the previous file with C-e
nnoremap <C-e> :e#<CR>

" Join lines without extra space with K
nnoremap K Jx<ESC>

" Indent whole file while preserving cursor location with <Leader>i or <Leader>=
nnoremap <Leader>i m'gg=G`'
nnoremap <Leader>= m'gg=G`'

" Clear search highlighting with <Leader>nh or Ctrl-l
nnoremap <Leader>nh :nohlsearch<CR>
nnoremap <C-l> :nohlsearch<CR>

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

" Plugin Command Mappings

" Nerdtree mappings
nnoremap <Leader>nt :NERDTreeToggle<CR>
nnoremap <Leader>nr :NERDTree<CR>
nnoremap <Leader>nf :NERDTreeFind<CR>

" ALE
nnoremap <Leader>af :ALEFix<CR>

" TComment leader cc to toggle comments
map <Leader>cc :TComment<CR>

" FZF - search for files with Ctrl P
nnoremap <C-p> :Files<CR>
" }}}

function! FindCorrespondingTestFile()
  let l:filename = expand('%:t')

  let l:path_and_ext = split(l:filename, '\.')

  let l:path = path_and_ext[0]
  let l:ext = path_and_ext[1]

  let l:cmd = "find " . getcwd() . " -iname " . l:path . "test" . "." . l:ext
  let l:testfile = systemlist(l:cmd)[0]

  execute  "normal! :vsplit" . l:testfile . " \<CR>"
endfunction

nnoremap <Leader>ft :call FindCorrespondingTestFile()<CR>

" Command Aliases ----------- {{{

" Allow writing files with capital :W
command! W w
" }}}

" Vimux --------------------- {{{
"
source ~/.vim/vimux_settings.vim
"}}}
