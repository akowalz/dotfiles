function! CurrentEngine()
  return matchstr(expand("%"), "engines/[a-z_-]*/")
endfunction

function! RubyTestRunner()
  if !empty(glob(".zeus.sock"))
    return "zeus rspec"
  endif

  let l:engine = CurrentEngine()

  if strlen(l:engine) != 0
    return "cd " . l:engine . " && " . "bundle exec rspec"
  endif

  return "bundle exec rspec"
endfunction

function! CurrentBufferSpecifier()
  let l:engine = CurrentEngine()

  if strlen(l:engine) != 0
    return substitute(expand("%"), l:engine, "", "")
  endif

  return expand("%")
endfunction

function! PostRunCommand()
  if strlen(CurrentEngine()) != 0
    return ""
  endif

  return ""
endfunction

function! FocusedTestSpecifier()
  return ":" . line(".")
endfunction

let b:vimux_test_runner = RubyTestRunner()
