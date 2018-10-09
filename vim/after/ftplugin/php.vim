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
  execute "normal! m'?function\<CR>\"vyy`':nohlsearch\<CR>"

  " Search the yanked line in our register for the function name
  return matchlist(@v, 'function \(\w\+\)')[1]
endfunction

let b:vimux_test_runner = PhpTestRunner()
