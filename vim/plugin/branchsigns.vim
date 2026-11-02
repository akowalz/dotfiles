" Branch signs: mark the lines this branch has changed since it left the main
" branch, next to gitgutter's signs for uncommitted edits. A line with both
" shows gitgutter's. <Leader>gm (vimrc) turns them off and on.

if exists('g:loaded_branchsigns')
  finish
endif
let g:loaded_branchsigns = 1
let g:branchsigns_enabled = get(g:, 'branchsigns_enabled', 1)

" just under gitgutter, so its sign wins on a line that has both
let s:priority = get(g:, 'gitgutter_sign_priority', 10) - 1
" the buffer's current text, written out for diff
let s:current = tempname()

call sign_define('BranchChanged', { 'text': '▏', 'texthl': 'BranchSign' })
call sign_define('BranchRemoved', { 'text': '▁', 'texthl': 'BranchSign' })
call sign_define('BranchRemovedFirstLine', { 'text': '▔', 'texthl': 'BranchSign' })
highlight default link BranchSign Directory

" The commit where this branch left the main branch (origin/HEAD, else main or
" master), or '' outside a git repo. Takes a directory; the current file's by
" default.
function! BranchBase(...) abort
  let l:git = 'git -C ' . shellescape(a:0 ? a:1 : expand('%:p:h')) . ' '
  for l:main in ['origin/HEAD', 'main', 'master']
    let l:base = trim(system(l:git . 'merge-base HEAD ' . l:main . ' 2>/dev/null'))
    if !v:shell_error
      return l:base
    endif
  endfor
  return ''
endfunction

function! BranchSignsToggle() abort
  let g:branchsigns_enabled = !g:branchsigns_enabled
  for l:buf in getbufinfo({ 'bufloaded': 1 })
    call s:Update(l:buf.bufnr)
  endfor
  echo 'Branch signs ' . (g:branchsigns_enabled ? 'on' : 'off')
endfunction

" Fetches the file as it was at the branch's base, when the base has moved
function! s:Refresh(bufnr) abort
  let l:path = fnamemodify(bufname(a:bufnr), ':p')
  if getbufvar(a:bufnr, '&buftype') isnot# '' || !filereadable(l:path)
    return
  endif
  let l:dir = fnamemodify(l:path, ':h')
  let l:base = BranchBase(l:dir)
  if l:base is# getbufvar(a:bufnr, 'branchsigns_base', v:null)
    return
  endif
  call setbufvar(a:bufnr, 'branchsigns_base', l:base)

  let l:git = 'git -C ' . shellescape(l:dir) . ' '
  " untracked files get no signs, as with gitgutter
  call system(l:git . 'ls-files --error-unmatch -- ' . shellescape(l:path))
  if l:base is# '' || v:shell_error
    call setbufvar(a:bufnr, 'branchsigns_file', '')
  else
    let l:file = getbufvar(a:bufnr, 'branchsigns_file', '')
    let l:file = l:file is# '' ? tempname() : l:file
    call system(l:git . 'show ' . shellescape(l:base . ':./' . fnamemodify(l:path, ':t'))
          \ . ' > ' . shellescape(l:file) . ' 2>/dev/null')
    " a file the branch added wasn't there at the base
    if v:shell_error
      call writefile([], l:file)
    endif
    call setbufvar(a:bufnr, 'branchsigns_file', l:file)
  endif
  call s:Update(a:bufnr)
endfunction

" Diffs the buffer against its base and places the signs
function! s:Update(bufnr) abort
  call sign_unplace('branchsigns', { 'buffer': a:bufnr })
  let l:file = getbufvar(a:bufnr, 'branchsigns_file', '')
  if !g:branchsigns_enabled || l:file is# ''
    return
  endif
  call writefile(getbufline(a:bufnr, 1, '$'), s:current)
  let l:signs = []
  for l:line in systemlist('diff -U0 ' . shellescape(l:file) . ' ' . shellescape(s:current))
    " @@ -old,count +start,count @@, where a missing count means 1
    let l:m = matchlist(l:line, '^@@ -\S\+ +\(\d\+\)\%(,\(\d\+\)\)\? @@')
    if empty(l:m)
      continue
    endif
    let l:start = str2nr(l:m[1])
    let l:count = l:m[2] is# '' ? 1 : str2nr(l:m[2])
    if l:count == 0
      " removed lines: mark the line above them, or the top line
      call add(l:signs, { 'lnum': max([l:start, 1]),
            \ 'name': l:start ? 'BranchRemoved' : 'BranchRemovedFirstLine' })
    else
      for l:lnum in range(l:start, l:start + l:count - 1)
        call add(l:signs, { 'lnum': l:lnum, 'name': 'BranchChanged' })
      endfor
    endif
  endfor
  call sign_placelist(map(l:signs, { _, s -> extend(s,
        \ { 'buffer': a:bufnr, 'group': 'branchsigns', 'priority': s:priority }) }))
endfunction

augroup branchsigns
  autocmd!
  " the base can move after a commit, rebase or checkout
  autocmd BufEnter,FocusGained,ShellCmdPost * call s:Refresh(bufnr())
  autocmd User FugitiveChanged call s:Refresh(bufnr())
  " gitgutter rechecks a buffer as it's edited; follow along
  autocmd User GitGutter call s:Update(g:gitgutter_hook_context.bufnr)
augroup END
