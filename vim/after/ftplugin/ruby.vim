function! RubyTestRunner()
  if !empty(glob(".zeus.sock"))
    return "zeus rspec"
  endif

  return "bundle exec rspec"
endfunction

function! CurrentBufferSpecifier()
  return expand("%")
endfunction

function! FocusedTestSpecifier()
  return ":" . line(".")
endfunction

let b:vimux_test_runner = RubyTestRunner()
