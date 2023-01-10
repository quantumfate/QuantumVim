local vim = require "user.utils.nvim-api"
-- VSCode specific options
vim.cmd [[
  " split the workspace
  function! s:split(...) abort
  let direction = a:1
  let file = a:2
  call VSCodeCall(direction == 'h' ? 'workbench.action.splitEditorDown' : 'workbench.action.splitEditorRight')
  if file != ''
      call VSCodeExtensionNotify('open-file', expand(file), 'all')
  endif

  " create a new split
  function! s:splitNew(...)
      let file = a:2
      call s:split(a:1, file == '' ? '__vscode_new__' : file)
  endfunction

  " closes all other editors
  function! s:closeOtherEditors()
      call VSCodeNotify('workbench.action.closeEditorsInOtherGroups')
      call VSCodeNotify('workbench.action.closeOtherEditors')
  endfunction

  " increase or decrease editor size
  function! s:manageEditorSize(...)
      let count = a:1
      let to = a:2
      for i in range(1, count ? count : 1)
          call VSCodeNotify(to == 'increase' ? 'workbench.action.increaseViewSize' : 'workbench.action.decreaseViewSize')
      endfor
  endfunction

  " call the methods onmaps
  command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
  command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
  command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
  command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
  command! -bang Only if <q-bang> == '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif
]]

-- remap default vim bindings
local opts = { noremap = true, silent = true }

local keymap = vim.keymap

-- split horizontally
keymap("n", "<C-w>s", ":call <SID>split('h')<CR>", opts)
keymap("x", "<C-w>s", ":call <SID>split('h')<CR>", opts)
-- split vertically
keymap("n", "<C-w>v", ":call <SID>split('v')<CR>", opts)
keymap("x", "<C-w>v", ":call <SID>split('v')<CR>", opts)
-- split horizontally with new window
keymap("n", "<C-w>n", ":call <SID>splitNew('h', '__vscode_new__')<CR>", opts)
keymap("x", "<C-w>n", ":call <SID>splitNew('h', '__vscode_new__')<CR>", opts)
-- span editor widths
keymap("n", "<C-w>=", ":<C-u>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>", opts)
keymap("x", "<C-w>=", ":<C-u>call VSCodeNotify('workbench.action.evenEditorWidths')<CR>", opts)
-- resize windows
keymap("n", "<C-w>>", ":<C-u>call <SID>manageEditorSize(v:count, 'increase')<CR>", opts)
keymap("x", "<C-w>>", ":<C-u>call <SID>manageEditorSize(v:count, 'increase')<CR>", opts)
keymap("n", "<C-w>+", ":<C-u>call <SID>manageEditorSize(v:count, 'increase')<CR>", opts)
keymap("x", "<C-w>+", ":<C-u>call <SID>manageEditorSize(v:count, 'increase')<CR>", opts)
keymap("n", "<C-w><", ":<C-u>call <SID>manageEditorSize(v:count, 'decrease')<CR>", opts)
keymap("x", "<C-w><", ":<C-u>call <SID>manageEditorSize(v:count, 'decrease')<CR>", opts)
keymap("n", "<C-w>-", ":<C-u>call <SID>manageEditorSize(v:count, 'decrease')<CR>", opts)
keymap("x", "<C-w>-", ":<C-u>call <SID>manageEditorSize(v:count, 'decrease')<CR>", opts)

-- Better Navigation
keymap("n", "<C-j>", ":call VSCodeNotify('workbench.action.navigateDown')<CR>", opts)
keymap("x", "<C-j>", ":call VSCodeNotify('workbench.action.navigateDown')<CR>", opts)
keymap("n", "<C-k>", ":call VSCodeNotify('workbench.action.navigateUp')<CR>", opts)
keymap("x", "<C-k>", ":call VSCodeNotify('workbench.action.navigateUp')<CR>", opts)
keymap("n", "<C-h>", ":call VSCodeNotify('workbench.action.navigateLeft')<CR>", opts)
keymap("x", "<C-h>", ":call VSCodeNotify('workbench.action.navigateLeft')<CR>", opts)
keymap("n", "<C-l>", ":call VSCodeNotify('workbench.action.navigateRight')<CR>", opts)
keymap("x", "<C-l>", ":call VSCodeNotify('workbench.action.navigateRight')<CR>", opts)

-- open links
keymap("n", "<S-d>", ":call VSCodeNotify('workbench.action.openLink')<CR>", opts)
keymap("x", "<S-d>", ":call VSCodeNotify('workbench.action.openLink')<CR>", opts)


-- Bind C-/ to vscode commentary since calling from vscode produces double comments due to multiple cursors
keymap("n", "<C-/>", ":call Commend()<CR>", opts)
keymap("x", "<S-/>", ":call Comment()<CR>", opts)

-- Toggle editor widths back and forth
keymap("n", "<C-w>", ":<C-u>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>", opts)
keymap("x", "<C-w>", "::<C-u>call VSCodeNotify('workbench.action.toggleEditorWidths')<CR>", opts)

-- Call the which key menu
keymap("n", "<Space>", ":call VSCodeNotify('whichkey.show')<CR>", opts)
keymap("x", "<Space>", ":call VSCodeNotify('whichkey.show')<CR>", opts)
