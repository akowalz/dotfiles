-- Neovim's side of vimrc, loaded from it only in Neovim. Vim gets the same things
-- from its own packages and yegappan/lsp, so both editors look and work alike.

-- flash yanked text (Vim: the hlyank package). EditorConfig is built into Neovim.
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('hlyank', {}),
  callback = function() vim.hl.on_yank() end,
})

-- Markdown and Lua in Vim's classic syntax colors. Neovim colors them with tree-sitter,
-- whose highlight groups One Dark doesn't define, so they'd look different from Vim.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('classic_syntax', {}),
  pattern = { 'markdown', 'lua' },
  callback = function(event) vim.treesitter.stop(event.buf) end,
})

-- LSP: Neovim's built-in client, running the servers vimrc lists for Vim in g:lsp_servers.
-- Like Vim's: problems get a curly underline, with their messages out of the way (<Leader>d
-- shows the one on this line), the sign column stays for git, completion is manual
-- (<C-x><C-o>), and popups have a border.
vim.diagnostic.config({ signs = false, underline = true, virtual_text = false, severity_sort = true })
vim.o.winborder = 'rounded'
-- don't let servers ask Neovim to watch files: on macOS that opens a handle per file and
-- runs out (EMFILE) with pyright. Vim's LSP doesn't watch files either.
vim.lsp.config('*', {
  capabilities = { workspace = { didChangeWatchedFiles = { dynamicRegistration = false } } },
})

-- whether path is in the file's directory or any above it
local function found_upward(file, path)
  for dir in vim.fs.parents(file) do
    if vim.uv.fs_stat(dir .. '/' .. path) then return true end
  end
  return false
end

for _, server in ipairs(vim.g.lsp_servers) do
  local cmd = vim.list_extend({ server.path }, server.args or {})
  -- a missing server is skipped, as in Vim
  if vim.fn.executable(cmd[1]) == 1 then
    local markers = vim.tbl_map(function(m) return (m:gsub('/$', '')) end, server.rootSearch or {})
    vim.lsp.config(server.name, {
      cmd = cmd,
      filetypes = server.filetype,
      init_options = server.initializationOptions,
      root_dir = function(bufnr, on_dir)
        local file = vim.api.nvim_buf_get_name(bufnr)
        -- runIfSearch / runUnlessSearch: start only if a file is (or isn't) found upward
        for _, path in ipairs(server.runIfSearch or {}) do
          if not found_upward(file, path) then return end
        end
        for _, path in ipairs(server.runUnlessSearch or {}) do
          if found_upward(file, path) then return end
        end
        on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(file))
      end,
    })
    vim.lsp.enable(server.name)
  end
end

-- the same keys as Vim's LSP mappings in vimrc
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('nvim_lsp_mappings', {}),
  callback = function(event)
    local function map(lhs, rhs)
      vim.keymap.set('n', lhs, rhs, { buffer = event.buf, nowait = true })
    end
    map('gd', vim.lsp.buf.definition)
    map('gr', vim.lsp.buf.references)
    map('K', vim.lsp.buf.hover)
    map('[d', function() vim.diagnostic.jump({ count = -1 }) end)
    map(']d', function() vim.diagnostic.jump({ count = 1 }) end)
    map('<Leader>d', vim.diagnostic.open_float)
    map('<Leader>rn', vim.lsp.buf.rename)
    map('<Leader>ca', vim.lsp.buf.code_action)
  end,
})

-- diffview (gdv in zshrc): q closes it, R refreshes it. Not there on a fresh install until
-- PlugInstall runs.
local ok, diffview = pcall(require, 'diffview')
if ok then
  local close = { 'n', 'q', '<Cmd>DiffviewClose<CR>', { desc = 'Close diffview' } }
  local refresh = { 'n', 'R', '<Cmd>DiffviewRefresh<CR>', { desc = 'Refresh the file list and diffs' } }
  -- ]] and [[ jump a whole hunk at a time, only in diffview: elsewhere they're section jumps
  -- that filetypes use (Ruby classes, Markdown headings). ]c and [c stop at every block, and
  -- linematch splits a hunk into back-to-back blocks (changed lines, then added ones), so keep
  -- jumping while the line above is changed too, meaning we're still in the same hunk.
  local function jump_hunk(motion)
    local function changed(lnum) return lnum >= 1 and vim.fn.diff_hlID(lnum, 1) ~= 0 end
    repeat
      local before = vim.fn.line('.')
      vim.cmd('normal! ' .. motion)
      local now = vim.fn.line('.')
    until now == before or not changed(now - 1)
  end
  local next_change = { 'n', ']]', function() jump_hunk(']c') end, { desc = 'Jump to the next hunk' } }
  local prev_change = { 'n', '[[', function() jump_hunk('[c') end, { desc = 'Jump to the previous hunk' } }
  diffview.setup({
    use_icons = false, -- icons need nvim-web-devicons and a Nerd Font
    enhanced_diff_hl = true, -- color the changed words within a line
    keymaps = {
      view = { close, refresh, next_change, prev_change },
      file_panel = { close },
      file_history_panel = { close },
    },
    hooks = {
      -- changed lines GitHub-style: red on the old side, green on the new (colors in vimrc).
      -- This replaces diffview's own per-side highlights, so it repeats the ones it keeps.
      diff_buf_win_enter = function(_, _, ctx)
        if not ctx.layout_name:match('^diff2') then return end
        if ctx.symbol == 'a' then
          vim.opt_local.winhighlight = 'DiffAdd:DiffviewDiffAddAsDelete,DiffDelete:DiffviewDiffDeleteDim,'
            .. 'DiffChange:DiffChangeOld,DiffText:DiffTextOld'
        elseif ctx.symbol == 'b' then
          vim.opt_local.winhighlight = 'DiffAdd:DiffviewDiffAdd,DiffDelete:DiffviewDiffDeleteDim,'
            .. 'DiffChange:DiffChangeNew,DiffText:DiffTextNew'
        end
      end,
    },
  })

  -- diffview only notices changes made from Neovim or to the git index, so files edited
  -- elsewhere (say, by Claude Code) would go stale. Refresh the diffview being looked at
  -- every 2 seconds instead.
  -- A refresh runs git and waits on it, so never start one while the last is still going
  -- (git can be slow, or busy with a commit), and stop for good when Neovim quits.
  local diffview_lib = require('diffview.lib')
  local refresh_started -- when the refresh in progress started, if one is
  local refresh_timer = vim.fn.timer_start(2000, function()
    local view = diffview_lib.get_current_view()
    -- a refresh that never reported back after 30 seconds is given up on
    local busy = refresh_started and vim.uv.now() - refresh_started < 30000
    if not view or busy or vim.fn.mode() ~= 'n' or not view.update_files then return end
    refresh_started = vim.uv.now()
    view:update_files(function() refresh_started = nil end)
  end, { ['repeat'] = -1 })
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = vim.api.nvim_create_augroup('diffview_refresh', {}),
    callback = function() vim.fn.timer_stop(refresh_timer) end,
  })
end
