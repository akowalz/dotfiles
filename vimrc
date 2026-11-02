" Plugins ------------------- {{{
call plug#begin('~/.vim/plugged')

" Navigation
Plug 'scrooloose/nerdtree'
" Tools
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-endwise'
Plug 'alvan/vim-closetag'
Plug 'tomtom/tcomment_vim'
" fzf's own vim plugin comes with Homebrew's fzf (Brewfile)
if isdirectory($HOMEBREW_PREFIX . '/opt/fzf')
  Plug $HOMEBREW_PREFIX . '/opt/fzf'
endif
Plug 'junegunn/fzf.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-projectionist'
Plug 'dkarter/bullets.vim'
Plug 'yegappan/lsp'
Plug 'airblade/vim-gitgutter'

" Syntax highlighers (Vim's own TypeScript and Python syntax beat the old plugins)
Plug 'pangloss/vim-javascript'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'mustache/vim-mustache-handlebars'
Plug 'posva/vim-vue'

" Colors and appearance
Plug 'joshdick/onedark.vim'
Plug 'itchyny/lightline.vim'
call plug#end()

" Packages that come with Vim: flash yanked text, follow a project's .editorconfig
packadd! hlyank
packadd! editorconfig
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
let &listchars = 'tab:» ,trail:·,nbsp:␣'
set list
" solid lines between splits, and no ~ on the lines past the end of the buffer
let &fillchars = 'vert:│,fold: ,eob: '
" don't wait a second after <Esc> to see if it starts a key code
set ttimeout ttimeoutlen=10
" refresh git signs soon after typing stops
set updatetime=100
" wrapped lines keep their indent and break between words
set breakindent linebreak
set smoothscroll
" command-line and insert completion in a popup menu, matched fuzzily
set wildoptions=pum,fuzzy
set completeopt=menuone,popup,fuzzy
set pumheight=12
" diffs line up the most similar lines in a change, and highlight the changed words
set diffopt-=inline:simple diffopt-=inline:char diffopt+=linematch:60,inline:word
" histogram diffs need vim's internal diff, which macOS's /usr/bin/vim lacks (Brewfile has vim)
if &diffopt =~# 'internal'
  set diffopt+=algorithm:histogram,indent-heuristic
endif
set shortmess+=c
" persistent undo, kept out of ~/.vim since that's this repo
set undofile undodir=~/.local/state/vim/undo//
call mkdir(expand('~/.local/state/vim/undo'), 'p', 0700)
" }}}

" Appearance ---------------- {{{
set termguicolors
" tmux's $TERM (screen-256color) doesn't tell vim how to send true color
if &term =~# '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
" curly, colored underlines (for LSP errors)
let &t_Cs = "\<Esc>[4:3m"
let &t_Ce = "\<Esc>[4:0m"
let &t_8u = "\<Esc>[58;2;%lu;%lu;%lum"
" bar cursor in insert mode, underline in replace mode, block otherwise
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

set background=dark

" One Dark on the terminal's own background, so it matches cmux's theme,
" with its text a little brighter than #abb2bf
let g:onedark_color_overrides = {
      \ 'background': { 'gui': 'NONE', 'cterm': 'NONE', 'cterm16': 'NONE' },
      \ 'black': { 'gui': '#0a0a0a', 'cterm': '232', 'cterm16': '0' },
      \ 'foreground': { 'gui': '#c5cad3', 'cterm': '251', 'cterm16': 'NONE' },
      \ 'white': { 'gui': '#c5cad3', 'cterm': '251', 'cterm16': '15' },
      \ }
let g:onedark_terminal_italics = 1

augroup onedark_extras
  autocmd!
  autocmd ColorScheme onedark call s:OnedarkExtras()
augroup END

" LSP errors and warnings get a curly underline, and their message the same color
function! s:OnedarkExtras()
  let l:colors = onedark#GetColors()
  call onedark#set_highlight('LspDiagInlineError', { 'sp': l:colors.red, 'gui': 'undercurl', 'cterm': 'undercurl' })
  call onedark#set_highlight('LspDiagInlineWarning', { 'sp': l:colors.yellow, 'gui': 'undercurl', 'cterm': 'undercurl' })
  call onedark#set_highlight('LspDiagVirtualTextError', { 'fg': l:colors.red })
  call onedark#set_highlight('LspDiagVirtualTextWarning', { 'fg': l:colors.yellow })
  " lines the branch changed (vim/plugin/branchsigns.vim)
  call onedark#set_highlight('BranchSign', { 'fg': l:colors.blue })
endfunction

" silent!: on a fresh install, onedark isn't there until PlugInstall runs
silent! colorscheme onedark

set laststatus=2
set noshowmode " don't show -- INSERT -- because lightline does it for you

" brighten the current line's number
set cursorline cursorlineopt=number

" always show the sign column so the buffer doesn't shift around
set signcolumn=yes
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
augroup filetype_for_gitconfig
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
" FZF: a floating window, in the colorscheme's colors
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.7 } }
let g:fzf_colors = {
      \ 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Statement'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'VertSplit'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'],
      \ }
" fd (Brewfile) skips whatever .gitignore lists
let $FZF_DEFAULT_COMMAND = executable('fd')
      \ ? 'fd --type f --hidden --exclude .git'
      \ : 'find * -type f 2>/dev/null | grep -v -E "deps/|_build/|node_modules/|vendor/"'

" NERDTree
let g:NERDCreateDefaultMappings = 0
let g:NERDTreeMinimalUI = 1

" Lightline
let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFullPath',
      \   'gitbranch': 'FugitiveHead',
      \ },
      \ }

function! LightlineFullPath()
  return expand('%')
endfunction

" Bullets: <Leader>x toggles a checkbox, or adds one to a line without it
let g:bullets_custom_mappings = [
      \ ['nmap', '<Leader>x', '<Plug>(todo-toggle)'],
      \ ]
nnoremap <silent> <Plug>(todo-toggle) :call TodoToggle()<CR>

function! TodoToggle()
  let l:bullet = '^\s*\%([-*+]\|\d\+[.)]\)'
  let l:line = getline('.')
  if l:line =~# l:bullet . '\s\+\[.\]'
    ToggleCheckbox
  elseif l:line =~# l:bullet . '\s'
    call setline('.', substitute(l:line, l:bullet . '\zs\s\+', ' [ ] ', ''))
  else
    call setline('.', substitute(l:line, '^\s*\zs', '- [ ] ', ''))
  endif
endfunction

" Gitgutter: thin bars in the sign column, and hunk previews in a popup
let g:gitgutter_sign_added = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_removed = '▁'
let g:gitgutter_sign_removed_first_line = '▔'
let g:gitgutter_sign_modified_removed = '▎'
let g:gitgutter_preview_win_floating = 1
" Its bars are uncommitted edits; thinner blue bars mark the rest of what the branch
" changed since it left master (vim/plugin/branchsigns.vim)

" LSP: diagnostics show as a curly underline plus the message after the line,
" leaving the sign column to git. Completion stays manual (<C-x><C-o>).
let s:lsp_options = {
      \ 'autoComplete': v:false,
      \ 'omniComplete': v:true,
      \ 'showDiagWithSign': v:false,
      \ 'showDiagWithVirtualText': v:true,
      \ 'diagVirtualTextAlign': 'after',
      \ 'diagVirtualTextWrap': 'truncate',
      \ 'echoSignature': v:true,
      \ 'popupBorder': v:true,
      \ 'ignoreMissingServer': v:true,
      \ }

" The servers come from the Brewfile (sourcekit-lsp comes with Xcode); a
" missing one is skipped.
"
" JavaScript and TypeScript: in a project whose own TypeScript has tsserver
" (TypeScript 6 and older), typescript-language-server runs it, and Vue's
" <script> blocks go through it too, using the TypeScript plugin that comes
" with vue-language-server. Anywhere else, Homebrew's TypeScript 7 runs its
" own language server.
let s:tsserver = 'node_modules/typescript/lib/tsserver.js'
let s:vue_language_server = $HOMEBREW_PREFIX . '/opt/vue-language-server/libexec/lib/node_modules/@vue/language-server'
let s:lsp_servers = [
      \ { 'name': 'typescript-language-server',
      \   'path': 'typescript-language-server', 'args': ['--stdio'],
      \   'filetype': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue'],
      \   'runIfSearch': [s:tsserver],
      \   'rootSearch': ['tsconfig.json', 'jsconfig.json', 'package.json', '.git/'],
      \   'initializationOptions': { 'plugins': isdirectory(s:vue_language_server)
      \     ? [{ 'name': '@vue/typescript-plugin', 'location': s:vue_language_server, 'languages': ['vue'] }]
      \     : [] } },
      \ { 'name': 'tsc',
      \   'path': $HOMEBREW_PREFIX . '/opt/typescript/bin/tsc', 'args': ['--lsp', '--stdio'],
      \   'filetype': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
      \   'runUnlessSearch': [s:tsserver],
      \   'rootSearch': ['tsconfig.json', 'jsconfig.json', 'package.json', '.git/'] },
      \ { 'name': 'ruby-lsp',
      \   'path': 'ruby-lsp',
      \   'filetype': ['ruby'],
      \   'rootSearch': ['Gemfile', '.git/'] },
      \ { 'name': 'pyright',
      \   'path': 'pyright-langserver', 'args': ['--stdio'],
      \   'filetype': ['python'],
      \   'rootSearch': ['pyproject.toml', 'setup.py', 'requirements.txt', '.git/'] },
      \ { 'name': 'sourcekit',
      \   'path': 'sourcekit-lsp',
      \   'filetype': ['swift'],
      \   'rootSearch': ['Package.swift', '.git/'] },
      \ ]

augroup lsp_setup
  autocmd!
  autocmd User LspSetup call LspOptionsSet(s:lsp_options)
  autocmd User LspSetup call LspAddServer(s:lsp_servers)
augroup END
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

" Toggle commenting with Ctrl-\
map <C-\> :TComment<CR>

" FZF - search for files with Ctrl P
nnoremap <C-p> :Files<CR>

"Fugitive
" <Leader>gg to search for the word under the cursor with Ggrep
nnoremap <Leader>gg :Ggrep <cword><CR>
" "the branch" means everything since it left master (BranchBase), uncommitted edits included
" <Leader>gs status, <Leader>gb blame, <Leader>gl this file's history in quickfix
nnoremap <Leader>gs <Cmd>Git<CR>
nnoremap <Leader>gb <Cmd>Git blame<CR>
nnoremap <Leader>gl <Cmd>0Gclog<CR>
" <Leader>gd this file's uncommitted changes, <Leader>gD this file's changes on the branch
nnoremap <Leader>gd <Cmd>Gvdiffsplit<CR>
nnoremap <Leader>gD <Cmd>execute 'Gvdiffsplit' BranchBase()<CR>
" <Leader>gr review the branch: a tab per changed file, each a side-by-side diff
" <Leader>gq the branch's changed files in quickfix (]q and [q to step through)
nnoremap <Leader>gr <Cmd>execute 'Git difftool -y' BranchBase()<CR>
nnoremap <Leader>gq <Cmd>execute 'Git difftool --name-only' BranchBase()<CR>
" ]q and [q next/previous entry in quickfix (changed files, history, grep results)
nnoremap ]q <Cmd>cnext<CR>
nnoremap [q <Cmd>cprevious<CR>
" <Leader>gm turn the branch's signs in the gutter off and on
nnoremap <Leader>gm <Cmd>call BranchSignsToggle()<CR>

" LSP, in buffers a language server is attached to:
" gd definition, gr references, K docs, [d and ]d previous/next problem,
" <Leader>d the problem on this line, <Leader>rn rename, <Leader>ca code action
augroup lsp_mappings
  autocmd!
  autocmd User LspAttached call s:LspMappings()
augroup END

function! s:LspMappings()
  nnoremap <buffer> gd <Cmd>LspGotoDefinition<CR>
  nnoremap <buffer> gr <Cmd>LspShowReferences<CR>
  nnoremap <buffer> K <Cmd>LspHover<CR>
  nnoremap <buffer> [d <Cmd>LspDiag prev<CR>
  nnoremap <buffer> ]d <Cmd>LspDiag next<CR>
  nnoremap <buffer> <Leader>d <Cmd>LspDiag current<CR>
  nnoremap <buffer> <Leader>rn <Cmd>LspRename<CR>
  nnoremap <buffer> <Leader>ca <Cmd>LspCodeAction<CR>
endfunction
" }}}

" Markdown and deskset mappings
" New slide
nnoremap <Leader>ns o<CR>---<CR><CR><ESC>

" New code fence
nnoremap <Leader>cf o<CR>```<CR>```<ESC>O
