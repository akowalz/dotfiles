" Plugins ------------------- {{{
call plug#begin('~/.vim/plugged')

" Navigation
" file tree: fern, with git status marks, and opening a directory (vim .) shows it
Plug 'lambdalisue/fern.vim', { 'branch': 'main' }
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/fern-hijack.vim'
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
" Vim's LSP client; Neovim uses its own (vim/lua/nvim.lua). Each editor's plugins are
" registered in both, so PlugClean in either keeps them, but load only where they work.
Plug 'yegappan/lsp', has('nvim') ? { 'on': [] } : {}
" side-by-side diffs of a branch or commit, Neovim only (dv in zshrc)
Plug 'sindrets/diffview.nvim', has('nvim') ? {} : { 'on': [] }
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

" Packages that come with Vim: flash yanked text, follow a project's .editorconfig.
" Neovim has both built in (vim/lua/nvim.lua).
if !has('nvim')
  packadd! hlyank
  packadd! editorconfig
endif
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
if !has('nvim') " Neovim's swap files differ, and live in ~/.local/state/nvim
  set dir=/tmp//
endif
set scrolloff=5
set ignorecase
set smartcase
set wildignore+=*.pyc,*.o,*.class,*.lo,.git,vendor/*,node_modules/**,bower_components/**,*/build_gradle/*,*/build_intellij/*,*/build/*,*/cassandra_data/*
set mouse=
if !has('nvim')
  set ttymouse=
endif
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
" ignore modelines: text near a file's start or end that looks like one ("- vim: ...") gets
" applied as settings, which errors, and is a way in for a file you didn't write. Brewfile,
" the one file here with a modeline, is detected as Ruby without it.
set nomodeline
" persistent undo, kept out of ~/.vim since that's this repo. Neovim's undo files
" can't be read by Vim, so it keeps its own in ~/.local/state/nvim/undo.
set undofile
if !has('nvim')
  set undodir=~/.local/state/vim/undo//
  call mkdir(expand('~/.local/state/vim/undo'), 'p', 0700)
endif
" }}}

" Appearance ---------------- {{{
set termguicolors
" Terminal codes. Neovim works these out itself, and already has the same cursor shapes.
if !has('nvim')
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
endif

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
  " the same for Neovim's built-in LSP
  call onedark#set_highlight('DiagnosticUnderlineError', { 'sp': l:colors.red, 'gui': 'undercurl', 'cterm': 'undercurl' })
  call onedark#set_highlight('DiagnosticUnderlineWarn', { 'sp': l:colors.yellow, 'gui': 'undercurl', 'cterm': 'undercurl' })
  call onedark#set_highlight('DiagnosticVirtualTextError', { 'fg': l:colors.red })
  call onedark#set_highlight('DiagnosticVirtualTextWarn', { 'fg': l:colors.yellow })
  " lines the branch changed (vim/plugin/branchsigns.vim)
  call onedark#set_highlight('BranchSign', { 'fg': l:colors.blue })
  " diffs keep their syntax colors: a dim tint behind changed lines, where One Dark
  " paints them solid with black text. DiffText marks the changed words within a line.
  highlight DiffAdd    gui=NONE guifg=NONE    guibg=#1c3022 cterm=NONE ctermfg=NONE ctermbg=22
  highlight DiffChange gui=NONE guifg=NONE    guibg=#1a2535 cterm=NONE ctermfg=NONE ctermbg=17
  highlight DiffText   gui=NONE guifg=NONE    guibg=#2b4366 cterm=NONE ctermfg=NONE ctermbg=24
  highlight DiffDelete gui=NONE guifg=#5c3a3f guibg=#2c1a1d cterm=NONE ctermfg=52   ctermbg=NONE
  " diffview (vim/lua/nvim.lua) shows a changed line GitHub-style instead: red with the
  " old words brighter on the left, green with the new words brighter on the right
  highlight DiffChangeOld gui=NONE guifg=NONE guibg=#2c1a1d cterm=NONE ctermfg=NONE ctermbg=52
  highlight DiffTextOld   gui=NONE guifg=NONE guibg=#5a2a31 cterm=NONE ctermfg=NONE ctermbg=88
  highlight DiffChangeNew gui=NONE guifg=NONE guibg=#1c3022 cterm=NONE ctermfg=NONE ctermbg=22
  highlight DiffTextNew   gui=NONE guifg=NONE guibg=#2a5a36 cterm=NONE ctermfg=NONE ctermbg=28
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

" Reload files that changed on disk (say, edited by Claude Code) without asking, unless they
" have unsaved edits: when vim gets focus or enters a buffer, and every second in normal mode
set autoread
augroup reload_changed_files
  autocmd!
  autocmd FocusGained,BufEnter * silent! checktime
augroup END

function! s:CheckTime(timer) abort
  if mode() ==# 'n' && getcmdwintype() ==# ''
    silent! checktime
  endif
endfunction

" once, even when vimrc is sourced again (<Leader>vc)
if !exists('s:checktime_timer')
  let s:checktime_timer = timer_start(1000, function('s:CheckTime'), { 'repeat': -1 })
endif

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

" Markdown wraps at 100 characters as you type, with a list item's wrapped lines indented
" under its text, and reflows a paragraph as you edit it. Code blocks are never touched.
" Lines vim wraps end in a space, and only those join up when reflowing (formatoptions a,
" w), so lines you broke yourself stay as they are. Trailing spaces aren't shown (·) here,
" since every wrapped line has one. gq (say, gqap) reflows by hand.
augroup markdown_wrap
  autocmd!
  autocmd FileType markdown setlocal textwidth=100 formatexpr=MarkdownFormat() formatoptions+=aw
  autocmd FileType markdown setlocal listchars=tab:»\ ,nbsp:␣
augroup END

" Vim's own formatting, minus fenced code blocks
function! MarkdownFormat() abort
  let l:in_code = s:CodeFenceLines()
  " wrapping while typing (v:char is the typed character; it's empty for gq)
  if v:char !=# ''
    return l:in_code[v:lnum] ? 0 : 1
  endif
  " gq over lines: format each run outside code blocks, bottom up so line numbers hold
  let l:last = v:lnum + v:count - 1
  let l:runs = []
  for l:lnum in range(v:lnum, l:last)
    if l:in_code[l:lnum]
      continue
    elseif !empty(l:runs) && l:runs[-1][1] == l:lnum - 1
      let l:runs[-1][1] = l:lnum
    else
      call add(l:runs, [l:lnum, l:lnum])
    endif
  endfor
  setlocal formatexpr=
  for [l:from, l:to] in reverse(l:runs)
    execute 'keepjumps normal! ' . l:from . 'Ggq' . l:to . 'G'
  endfor
  setlocal formatexpr=MarkdownFormat()
  return 0
endfunction

" For each line number, whether it's in a fenced code block (``` or ~~~), fences included
function! s:CodeFenceLines() abort
  let l:in_code = [0]
  let l:inside = 0
  for l:line in getline(1, '$')
    let l:fence = l:line =~# '^\s*\%(```\|\~\~\~\)'
    call add(l:in_code, l:inside || l:fence)
    let l:inside = l:fence ? !l:inside : l:inside
  endfor
  return l:in_code
endfunction

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

" Fern: the tree opens as a sidebar on the left
let g:fern#drawer_width = 35
let g:fern#default_hidden = 1 " show dotfiles
let g:fern#default_exclude = '^\%(\.git\|\.DS_Store\)$' " but never these

" in the tree, → and ← work like l and h: open or expand, collapse
augroup fern_arrows
  autocmd!
  autocmd FileType fern nmap <buffer><nowait> <Right> <Plug>(fern-action-open-or-expand)
  autocmd FileType fern nmap <buffer><nowait> <Left> <Plug>(fern-action-collapse)
augroup END

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

" Markdown indents by 2 like everything else; Vim's markdown settings would make it 4
let g:markdown_recommended_style = 0

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

" LSP: diagnostics show as a curly underline, leaving the sign column to git. Their messages
" stay out of the way: <Leader>d shows the one on this line. Completion stays manual (<C-x><C-o>).
let s:lsp_options = {
      \ 'autoComplete': v:false,
      \ 'omniComplete': v:true,
      \ 'showDiagWithSign': v:false,
      \ 'showDiagWithVirtualText': v:false,
      \ 'diagVirtualTextAlign': 'after',
      \ 'diagVirtualTextWrap': 'truncate',
      \ 'echoSignature': v:true,
      \ 'popupBorder': v:true,
      \ 'ignoreMissingServer': v:true,
      \ }

" The servers come from the Brewfile (sourcekit-lsp comes with Xcode); a
" missing one is skipped. Neovim's built-in LSP reads this same list (vim/lua/nvim.lua).
"
" JavaScript and TypeScript: in a project whose own TypeScript has tsserver
" (TypeScript 6 and older), typescript-language-server runs it, and Vue's
" <script> blocks go through it too, using the TypeScript plugin that comes
" with vue-language-server. Anywhere else, Homebrew's TypeScript 7 runs its
" own language server.
let s:tsserver = 'node_modules/typescript/lib/tsserver.js'
let s:vue_language_server = $HOMEBREW_PREFIX . '/opt/vue-language-server/libexec/lib/node_modules/@vue/language-server'
let g:lsp_servers = [
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
  autocmd User LspSetup call LspAddServer(g:lsp_servers)
augroup END

" Neovim's side: its LSP, yank flash and diffview (vim/lua/nvim.lua)
if has('nvim')
  lua require('nvim')
endif
" }}}

" Mappings ------------------ {{{
"
" Set leader to space
let mapleader ="\<Space>"
nnoremap \\ <NOP>

" Insert mode mappings
" Exit insert mode with jk.
inoremap jk <ESC>

" Shift-Tab outdents: the line in insert mode (via <C-d>, which bullets.vim makes outdent a
" list item properly in markdown), the line in normal mode, the selection in visual mode
imap <S-Tab> <C-d>
nnoremap <S-Tab> <<
xnoremap <S-Tab> <gv

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
j
if has('nvim')
  silent! nunmap Y
endif

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

" File tree (fern): <Leader>nt toggle, <Leader>nr open fresh, <Leader>nf open on this file
nnoremap <Leader>nt <Cmd>Fern . -drawer -toggle<CR>
nnoremap <Leader>nr <Cmd>Fern . -drawer<CR>
nnoremap <Leader>nf <Cmd>Fern . -drawer -reveal=%<CR>

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

" LSP, in buffers a language server is attached to (Neovim maps the same keys in vim/lua/nvim.lua):
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
