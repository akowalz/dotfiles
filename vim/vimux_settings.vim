function! TestRunner()
  let runners = {
        \ 'ruby' : RubyTestRunner(),
        \ 'php'  : PhpTestRunner(),
        \ 'javascript' : 'unimplemented',
        \ }

  return get(runners, &filetype, "VIMUX_RUNNER_NOT_FOUND")
endfunction

function! CurrentBufferSpecifier()
  let specifiers = {
        \ 'ruby' : expand('%'),
        \ 'php'  : expand('%'),
        \ }

  return get(specifiers, &filetype, "VIMUX_RUNNER_NOT_FOUND")
endfunction

function! FocusedTestSpecifier()
  let specifiers = {
        \ 'ruby' : ":" . line("."),
        \ 'php'  : PhpFocusedTestSpecifier(),
        \ }

  return get(specifiers, &filetype, "VIMUX_RUNNER_NOT_FOUND")
endfunction

function! RubyTestRunner()
  if !empty(glob(".zeus.sock"))
    return "zeus rspec"
  endif

  return "bundle exec rspec"
endfunction

function! PhpTestRunner()
  if expand("%") =~ "spec"
    return "vendor/bin/phpspec run"
  endif

  return "vendor/bin/phpunit"
endfunction

function! PhpFocusedTestSpecifier()
  if (TestRunner() == "vendor/bin/phpspec run")
    return ":" . line(".")
  endif

  if (TestRunner() == "vendor/bin/phpunit")
    return " --filter " . CurrentPhpFunctionName()
  endif
endfunction

function! CurrentPhpFunctionName()
  execute "normal! m'?function\<CR>\"vyy`':nohlsearch\<CR>"
  return matchlist(@v, 'function \(\w\+\)')[1]
endfunction

function! RunBuffer()
  return TestRunner() . " " . CurrentBufferSpecifier()
endfunction

function! RunFocused()
  return TestRunner() . " " . CurrentBufferSpecifier() . FocusedTestSpecifier()
endfunction

function! ClearAndEcho(cmd)
  return "clear && echo " . a:cmd . " && " . a:cmd
endfunction

nnoremap <silent> <Leader>rb :call VimuxRunCommand(ClearAndEcho(RunBuffer()))<CR>
nnoremap <silent> <Leader>rf :call VimuxRunCommand(ClearAndEcho(RunFocused()))<CR>
nnoremap <silent> <Leader>rl :VimuxRunLastCommand<CR>
nnoremap <silent> <Leader>rr :VimuxPromptCommand<CR>
