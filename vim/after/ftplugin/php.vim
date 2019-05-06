function! PhpTestRunner()
  if expand("%") =~ "spec"
    return "vendor/bin/phpspec run"
  endif

  return "vendor/bin/phpunit"
endfunction

function! CurrentBufferSpecifier()
  return expand("%")
endfunction

function! FocusedTestSpecifier()
  if (TestRunner() == "vendor/bin/phpspec run")
    return ":" . line(".")
  endif

  if (TestRunner() == "vendor/bin/phpunit")
    return " --filter " . CurrentPhpFunctionName()
  endif
endfunction

function! CurrentPhpFunctionName()
  " Set a mark, search upwards for 'function', yank the link into the v register, jump back to our mark.
  execute "normal! m'?public function\<CR>\"vyy`':nohlsearch\<CR>"

  " Search the yanked line in our register for the function name
  return matchlist(@v, 'function \(\w\+\)')[1]
endfunction

let b:vimux_test_runner = PhpTestRunner()

setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal noexpandtab
setlocal listchars=tab:>-

" {{{ Doc block generation ---

function! GenerateEmptyDocBlock()
  execute "normal! O/**\<CR>_description_\<CR>/\<ESC>kA\<CR>"
endfunction

function! GenerateDocBlock()
  let s:doc_block_line = getline(".")

  call GenerateEmptyDocBlock()

  if s:doc_block_line =~ "function"
    call PopulateFunctionDoc()
  elseif s:doc_block_line =~ "public|private"
    call PopulatePropertyDoc()
  endif
endfunction

function! PopulatePropertyDoc()
  let s:propname = matchlist(s:doc_block_line, '\$\w\+')[0]

  execute "normal! A @var _typehint_ " . s:propname .  "\<ESC>bb"
endfunction

function! PopulateFunctionDoc()
  execute "normal! Afunction"
  startinsert!
endfunction

nnoremap <silent> <Leader>db :call GenerateDocBlock()<CR>

" }}}
