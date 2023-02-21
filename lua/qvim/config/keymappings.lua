local M = {}
local Log = require "qvim.integrations.log"

local generic_opts_any = { noremap = true, silent = true }
M.generic_opts = {
  insert_mode = generic_opts_any,
  normal_mode = generic_opts_any,
  visual_mode = generic_opts_any,
  visual_block_mode = generic_opts_any,
  command_mode = generic_opts_any,
  operator_pending_mode = generic_opts_any,
  term_mode = { silent = true },
}

M.mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
  operator_pending_mode = "o",
}

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
    ["<A-j>"] = { "<Esc>:m .+1<CR>==gi", 'Move current line down' },
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-k>"] = { "<Esc>:m .-2<CR>==gi", 'Move current line down' },
    -- navigation
    ["<A-Up>"] = { "<C-\\><C-N><C-w>k", 'Move up' },
    ["<A-Down>"] = { "<C-\\><C-N><C-w>j", 'Move down' },
    ["<A-Left>"] = { "<C-\\><C-N><C-w>h", 'Move left' },
    ["<A-Right>"] = { "<C-\\><C-N><C-w>l", 'Move right' },
  },
  normal_mode = {
    -- Better window movement
    ["<C-h>"] = { "<C-w>h", 'Go to left window' },
    ["<C-j>"] = { "<C-w>j", 'Go to lower window' },
    ["<C-k>"] = { "<C-w>k", 'Go to upper window' },
    ["<C-l>"] = { "<C-w>l", 'Go to right window' },

    -- Resize with arrows
    ["<C-Up>"] = { ":resize -2<CR>", 'Decrease window size horizontally' },
    ["<C-Down>"] = { ":resize +2<CR>", 'Increase window size horizontally' },
    ["<C-Left>"] = { ":vertical resize -2<CR>", 'Decrease window size vertically' },
    ["<C-Right>"] = { ":vertical resize +2<CR>", 'Increase window size vertically' },

    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = { ":m .+1<CR>==", 'Move current line up' },
    ["<A-k>"] = { ":m .-2<CR>==", 'Move current line down' },

    ["]q"] = { ":cnext<CR>", 'Fix next error' },
    ["[q"] = { ":cprev<CR>", 'Fix previous error' },
    ["<C-q>"] = { ":call QuickFixToggle()<CR>", 'Toggle quick fix on/off' },
  },
  term_mode = {
    -- Terminal window navigation
    ["<C-h>"] = { "<C-\\><C-N><C-w>h", 'Go to left terminal' },
    ["<C-j>"] = { "<C-\\><C-N><C-w>j", 'Go to lower terminal' },
    ["<C-k>"] = { "<C-\\><C-N><C-w>k", 'Go to upper terminal' },
    ["<C-l>"] = { "<C-\\><C-N><C-w>l", 'Go to right terminal' },
  },
  visual_mode = {
    -- Better indenting
    ["<"] = { "<gv", 'Indent right' },
    [">"] = { ">gv", 'Indent left' },

    -- ["p"] = '"0p',
    -- ["P"] = '"0P',
  },
  visual_block_mode = {
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-j>"] = { ":m '>+1<CR>gv-gv", 'Move current line down' },
    ["<A-k>"] = { ":m '<-2<CR>gv-gv", 'Move current line up' },
  },
  command_mode = {
    -- navigate tab completion with <c-j> and <c-k>
    -- runs conditionally
    ["<C-j>"] = { 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', 'Navigate tab completion down', expr = true, noremap = true },
    ["<C-k>"] = { 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', 'Navigate tab completion up', expr = true, noremap = true },
  },
}

if vim.fn.has "mac" == 1 then
  -- good that I am not using mac but I will leave it here just in case ...
  defaults.normal_mode["<A-Up>"] = defaults.normal_mode["<C-Up>"]
  defaults.normal_mode["<A-Down>"] = defaults.normal_mode["<C-Down>"]
  defaults.normal_mode["<A-Left>"] = defaults.normal_mode["<C-Left>"]
  defaults.normal_mode["<A-Right>"] = defaults.normal_mode["<C-Right>"]
  Log:debug "Activated mac keymappings"
end

--- Unsets all keybindings that are parsed to this function as
--- an argument.
--- @param keymaps table The table of key mappings where the mode(key) maps to a list of mappings(values) (normal_mode, insert_mode, ..)
function M.clear(keymaps)
  local default = M.get_defaults()
  for mode, mappings in pairs(keymaps) do
    local translated_mode = M.mode_adapters[mode] and M.mode_adapters[mode] or mode
    for key, _ in pairs(mappings) do
      -- some plugins may override default bindings that the user hasn't manually overriden
      if default[mode][key] ~= nil or (default[translated_mode] ~= nil and default[translated_mode][key] ~= nil) then
        pcall(vim.api.nvim_del_keymap, translated_mode, key)
      end
    end
  end
  Log:warn("All keymappings where deleted.")
end

--- Set key mappings individually
--- @param mode string keymap mode, can be one of the keys of mode_adapters
--- @param key string key of keymap
--- @param val table|string Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = M.generic_opts[mode] or generic_opts_any
  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end
  if val then
    vim.keymap.set(mode, key, val, opt)
  else
    pcall(vim.api.nvim_del_keymap, mode, key)
  end
  Log:debug(string.format("Key [%s] for mode [%s] with the value [%s] was set.", mode, key, val))
end

--- Load a selection of keymappings based on the modes that
--- where provided.
--- @param mode string keymap mode, can be one of the keys of mode_adapters
--- @param keymaps table list of key mappings
function M.load_mode(mode, keymaps)
  mode = M.mode_adapters[mode] or mode
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
  Log:info(string.format("The mappings for the mode %s where loaded", mode), keymaps)
end

--- Load key mappings for all provided modes
--- @param keymaps table list of key mappings for each mode
function M.load(keymaps)
  keymaps = keymaps or {}
  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

-- Load the default keymappings
function M.load_defaults()
  M.load(M.get_defaults())
  qvim.keys = qvim.keys or {}
  for idx, _ in pairs(defaults) do
    if not qvim.keys[idx] then
      -- init empty table for mode_adapters that are not set by default
      qvim.keys[idx] = {}
    end
  end
  Log:info("The default keymappings were loaded.")
end

-- Get the default keymappings
function M.get_defaults()
  return defaults
end

return M
