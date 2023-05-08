---@class keymap_defaults
local keymap_defaults = {}
local Log = require "qvim.integrations.log"
---@class meta
local meta = nil

---Initialize the keymap defaults with the `meta` class
---@param _meta any
---@return keymap_defaults
function keymap_defaults.init(_meta)
  meta = _meta
  return keymap_defaults
end

---@class Keys
---@field insert_mode table
---@field normal_mode table
---@field terminal_mode table
---@field visual_mode table
---@field visual_block_mode table
---@field command_mode table
---@field operator_pending_mode table
local defaults = {
  insert_mode = {
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-j>"] = { rhs = "<Esc>:m .+1<CR>==gi", desc = 'Move current line down' },
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-k>"] = { rhs = "<Esc>:m .-2<CR>==gi", desc = 'Move current line down' },
    -- navigation
    ["<A-Up>"] = { rhs = "<C-\\><C-N><C-w>k", desc = 'Move up' },
    ["<A-Down>"] = { rhs = "<C-\\><C-N><C-w>j", desc = 'Move down' },
    ["<A-Left>"] = { rhs = "<C-\\><C-N><C-w>h", desc = 'Move left' },
    ["<A-Right>"] = { rhs = "<C-\\><C-N><C-w>l", desc = 'Move right' },
  },
  normal_mode = {
    -- Better window movement
    ["<C-h>"] = { rhs = "<C-w>h", desc = 'Go to left window' },
    ["<C-j>"] = { rhs = "<C-w>j", desc = 'Go to lower window' },
    ["<C-k>"] = { rhs = "<C-w>k", desc = 'Go to upper window' },
    ["<C-l>"] = { rhs = "<C-w>l", desc = 'Go to right window' },
    -- Resize with arrows
    ["<C-Up>"] = { rhs = ":resize -2<CR>", desc = 'Decrease window size horizontally' },
    ["<C-Down>"] = { rhs = ":resize +2<CR>", desc = 'Increase window size horizontally' },
    ["<C-Left>"] = { rhs = ":vertical resize -2<CR>", desc = 'Decrease window size vertically' },
    ["<C-Right>"] = { rhs = ":vertical resize +2<CR>", desc = 'Increase window size vertically' },
    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = { rhs = ":m .+1<CR>==", desc = 'Move current line up' },
    ["<A-k>"] = { rhs = ":m .-2<CR>==", desc = 'Move current line down' },
    ["]q"] = { rhs = ":cnext<CR>", desc = 'Fix next error' },
    ["[q"] = { rhs = ":cprev<CR>", desc = 'Fix previous error' },
    ["<C-q>"] = { rhs = ":call QuickFixToggle()<CR>", desc = 'Toggle quick fix on/off' },
    -- Navigate buffers
    ["<S-l>"] = { rhs = ":bnext<CR>", desc = "Navigate to right buffer" },
    ["<S-h>"] = { rhs = ":bnext<CR>", desc = "Navigate to left buffer" },
  },
  term_mode = {
    -- Terminal window navigation
    ["<C-h>"] = { rhs = "<C-\\><C-N><C-w>h", desc = 'Go to left terminal' },
    ["<C-j>"] = { rhs = "<C-\\><C-N><C-w>j", desc = 'Go to lower terminal' },
    ["<C-k>"] = { rhs = "<C-\\><C-N><C-w>k", desc = 'Go to upper terminal' },
    ["<C-l>"] = { rhs = "<C-\\><C-N><C-w>l", desc = 'Go to right terminal' },
  },
  visual_mode = {
    -- Better indenting
    ["<"] = { rhs = "<gv", desc = 'Indent right' },
    [">"] = { rhs = ">gv", desc = 'Indent left' },
    -- ["p"] = '"0p',
    -- ["P"] = '"0P',
  },
  visual_block_mode = {
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-j>"] = { rhs = ":m '>+1<CR>gv-gv", desc = 'Move current line down' },
    ["<A-k>"] = { rhs = ":m '<-2<CR>gv-gv", desc = 'Move current line up' },
  },
  command_mode = {
    -- navigate tab completion with <c-j> and <c-k>
    -- runs conditionally
    ["<C-j>"] = { rhs = 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', desc = 'Navigate tab completion down', expr = true, noremap = true },
    ["<C-k>"] = { rhs = 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', desc = 'Navigate tab completion up', expr = true, noremap = true },
  }
}

if vim.fn.has "mac" == 1 then
  -- good that I am not using mac but I will leave it here just in case ...
  defaults.normal_mode["<A-Up>"].rhs = defaults.normal_mode["<C-Up>"].rhs
  defaults.normal_mode["<A-Down>"].rhs = defaults.normal_mode["<C-Down>"].rhs
  defaults.normal_mode["<A-Left>"].rhs = defaults.normal_mode["<C-Left>"].rhs
  defaults.normal_mode["<A-Right>"].rhs = defaults.normal_mode["<C-Right>"].rhs
  Log:debug "Activated mac keymappings"
end

---Returns a table with default keymaps separated by modes.
---- key: mode adapter
---- value: `table` of keymaps
---@return Keys
function keymap_defaults.get_defaults()
  return defaults
end

return keymap_defaults
