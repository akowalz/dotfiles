function! TestRunner()
  " define in after/ftplugin file
  if exists("b:vimux_test_runner")
    return b:vimux_test_runner
  else
    return "VIMUX_TEST_RUNNER_NOT_SET"
  endif
endfunction

function! CurrentBufferSpecifier()
  " define in after/ftplugin file
  return "VIMUX_BUFFER_SPECIFIER_NOT_SET"
endfunction

function! FocusedTestSpecifier()
  " define in after/ftplugin file
  return "VIMUX_FOCUSED_TEST_SPECIFIER"
endfunction

function! PostRunCommand()
  return ""
endfunction

function! RunBuffer()
  return TestRunner() . " " . CurrentBufferSpecifier() . " " . PostRunCommand()
endfunction

function! RunFocused()
  return TestRunner() . " " . CurrentBufferSpecifier() . FocusedTestSpecifier() . " " . PostRunCommand()
endfunction

function! ClearAndEcho(cmd)
  return "clear && echo '" . a:cmd . "' && " . "(" . a:cmd . ")"
endfunction

nnoremap <silent> <Leader>rb :call VimuxRunCommand(ClearAndEcho(RunBuffer()))<CR>
nnoremap <silent> <Leader>rf :call VimuxRunCommand(ClearAndEcho(RunFocused()))<CR>
nnoremap <silent> <Leader>rl :VimuxRunLastCommand<CR>
nnoremap <silent> <Leader>rr :VimuxPromptCommand<CR>
nnoremap <silent> <Leader>vi :VimuxInspectRunner<CR>
nnoremap <silent> <Leader>vz :VimuxZoomRunner<CR>

" Run last run in that shell, regardless of if it was origianlly run by Vimux
nnoremap <silent> <Leader>ll :VimuxRunCommand("clear && fc -s")<CR>
