function! CucumberTestRunner()
  if filereadable("vendor/bin/behat")
    return "vendor/bin/behat"
  else
    return "cucumber"
  endif
endfunction

function! CurrentBufferSpecifier()
  return expand("%")
endfunction

function! FocusedTestSpecifier()
  return ":" . line(".")
endfunction

let b:vimux_test_runner = CucumberTestRunner()
