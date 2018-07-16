" Plugins
" ====================
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

" Syntax highlighers
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'

" Colors and appearance
Plug 'NLKNguyen/papercolor-theme'
Plug 'itchyny/lightline.vim'
call plug#end()

" General settings
" ================
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

" Appearance
" ==========
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

" sign column (left bar) should display in same color as rest of vim
highlight SignColumn ctermbg=NONE

" ale - make signs prettier
highlight ALEErrorSign ctermbg=NONE ctermfg=DarkRed
highlight ALEWarningSign ctermbg=NONE ctermfg=Yellow

" Autocommands
" ============

" Highlight cursorline in insert mode
augroup cursorline_in_insert_mode
  autocmd!
  autocmd InsertEnter,InsertLeave * set cul!
augroup END

" Write file when leaving insert mode
augroup write_on_leave_insert
  autocmd!
  autocmd InsertLeave * if !(@% == '') | update | endif
augroup END

" Highlight trailling whitespace, except when in insert mode
augroup highlight_extra_whitespace
  autocmd!
  autocmd InsertEnter * highlight clear ExtraWhitespace
  autocmd InsertLeave * highlight ExtraWhitespace ctermbg=Red | match ExtraWhitespace /\s\+$/
augroup END

" Set filetype to javascript for js.snap files
augroup filetype_for_js_snap_file
  autocmd!
  autocmd BufNewFile,BufRead *.js.snap set filetype=javascript.jsx
augroup END

" Plugin Settings
" ===============
"
" FZF
let g:fzf_layout = { 'down': '~25%' }
let $FZF_DEFAULT_COMMAND = 'find * -type f 2>/dev/null | grep -v -E "deps/|_build/|node_modules/|vendor/"'

" NERDTree
let g:NERDCreateDefaultMappings = 0

" vim-closetag, close tags with t instead of >
let g:closetag_filetypes = 'html,javascript.jsx'
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.jsx,*.js,*.erb'
" let g:closetag_shortcut = 't'

" ale
let g:ale_fixers = {'javascript': ['eslint']}
let g:ale_sign_error = "•"
let g:ale_sign_warning = "-"


" Mappings
" ========

" Set leader to space
let mapleader ="\<Space>"
nnoremap \\ <NOP>

" Insert mode mappings
" Exit insert mode with jk, no more escape for you.
inoremap jk <ESC>
inoremap <ESC> <NOP>

" Ctrl-l in insert mode to insert a hash rocket
inoremap <C-L> <SPACE>=><SPACE>

" Write with leader w
nnoremap <Leader>w :write<CR>

" Disable ex mode
nnoremap Q <NOP>

" Go back to the previous file with C-e
nnoremap <C-e> :e#<CR>

" Join lines without extra space with K
nnoremap K Jx<ESC>

" Indent whole file while preserving cursor location
nnoremap <Leader>i m'gg=G`'

" Clear search highlighting
nnoremap <Leader>nh :nohlsearch<CR>
nnoremap <C-l> :nohlsearch<CR>

" Clear trailing whitespace
nnoremap <Leader>cw :%s/\s\+$//g<CR>

" Change the current `test` to `test.only`
nnoremap <Leader>on ?test(<CR>ea.only<ESC>:noh<CR>

" Add a semicolon to the current line without moving the cursor with <leader>;
nnoremap <Leader>; m'A;<ESC>`'

" Change single quotes to double quotes with <Leader>''
nnoremap <Leader>"" m'F'r"f'r"`'

" Change double quotes to single quotes with <Leader>''
nnoremap <Leader>'' m'F"r'f"r'`'

" Source vimrc with <Leader>vc
nnoremap <Leader>vc :source ~/.vimrc<CR>:echo "Reloaded .vimrc"<CR>

" Plugin Command Mappings
"
" Nerdtree mappings
nnoremap <Leader>nt :NERDTreeToggle<CR>
nnoremap <Leader>nr :NERDTree<CR>
nnoremap <Leader>nf :NERDTreeFind<CR>

" TComment leader cc to toggle comments
map <Leader>cc :TComment<CR>

" FZF - search for files with Ctrl P
nnoremap <C-p> :Files<CR>

" Command Aliases
" ===============
command! W w

" Vimux
" =====
function! BaseCommand()
  if (&filetype=='javascript.jsx')
    return "npm test "
  elseif filereadable(".zeus.sock")
    return "zeus rspec "
  else
    return "bundle exec rspec "
  endif
endfunction

function! RunBuffer()
  return BaseCommand() . bufname("%")
endfunction

function! RunFocused()
  return BaseCommand() . bufname("%") . ":" . line(".")
endfunction

function! ClearAndEcho(cmd)
  return "clear && echo " . a:cmd . " && " . a:cmd
endfunction

nnoremap <Leader>rb :call VimuxRunCommand(ClearAndEcho(RunBuffer()))<CR>
nnoremap <Leader>rf :call VimuxRunCommand(ClearAndEcho(RunFocused()))<CR>
nnoremap <Leader>rl :VimuxRunLastCommand<CR>
nnoremap <Leader>rr :VimuxPromptCommand<CR>
