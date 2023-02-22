local M = {}
local Log = require "qvim.integrations.log"

M.supported_options = {
  noremap = true,
  buffer = true,
  nowait = true,
  silent = true,
  script = true,
  expr = true,
  unique = true,
  desc = true,
}

---Returns options for kaymaps. The options will cover the default
---unless a table with options will be parsed as an argument.
---@param mappings table|nil
---@return table
function M:mapping_options(mappings)
  local default_options = {
    noremap = true,
    buffer = nil,
    nowait = true,
    silent = true,
    script = false,
    expr = false,
    unique = false,
    desc = "",
  }
  if not mappings then
    return default_options
  end

  local new_options = {}
  for key, value in pairs(mappings) do
    if self.supported_options[key] then
      new_options[key] = value
    else
      Log:warn("Unsupported option '" .. key .. "' ignored")
    end
  end
  setmetatable(new_options, { __index = default_options })
  return new_options
end

M.generic_opts = {
  insert_mode = M:mapping_options(),
  normal_mode = M:mapping_options(),
  visual_mode = M:mapping_options(),
  visual_block_mode = M:mapping_options(),
  command_mode = M:mapping_options(),
  operator_pending_mode = M:mapping_options(),
  term_mode = M:mapping_options({ silent = true }),
}

M.mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
  operator_pending_mode = "o",
  term_mode = "t",
}

---Register keymaps for qvim. If whichkey is available all keymaps
---will be registered using whichkey.
function M:init()
  local defaults = self:get_defaults()
  qvim.keymaps = qvim.keymaps or {}
  for mode_adapters, _ in pairs(self.mode_adapters) do
    if not qvim.keymaps[mode_adapters] then
      -- init empty table for mode_adapters that are not set by default
      qvim.keymaps[mode_adapters] = {}
    end
  end

  local whichkey_exists, whichkey = pcall(require, "which-key")
  if whichkey_exists then
    -- whichkey setup
  else
    -- normal setup
    self:load(defaults)
  end

  Log:info("The default keymappings were loaded.")
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
    ["<A-j>"] = { "<Esc>:m .+1<CR>==gi", 'Move current line down' },
    -- Move current line / block with Alt-j/k ala vscode.
    ["<A-k>"] = { "<Esc>:m .-2<CR>==gi", 'Move current line down' },
    -- navigation
    ["<A-Up>"] = { "<C-\\><C-N><C-w>k", 'Move up' },
    ["<A-Down>"] = { "<C-\\><C-N><C-w>j", 'Move down' },
    ["<A-Left>"] = { "<C-\\><C-N><C-w>h", 'Move left' },
    ["<A-Right>"] = { "<C-\\><C-N><C-w>l", 'Move right' },

    -- TODO: whichkey menu in insert mode
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

    -- Navigate buffers
    ["<S-l>"] = { ":bnext<CR>", "Navigate to right buffer" },
    ["<S-h>"] = { ":bnext<CR>", "Navigate to left buffer" },
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
  defaults.normal_mode["<A-Up>"][1] = defaults.normal_mode["<C-Up>"][1]
  defaults.normal_mode["<A-Down>"][1] = defaults.normal_mode["<C-Down>"][1]
  defaults.normal_mode["<A-Left>"][1] = defaults.normal_mode["<C-Left>"][1]
  defaults.normal_mode["<A-Right>"][1] = defaults.normal_mode["<C-Right>"][1]
  Log:debug "Activated mac keymappings"
end

--- Unsets all keybindings that are parsed to this function as
--- an argument.
--- @param keymaps table The table of key mappings where the mode(key) maps to a list of mappings(values) (normal_mode, insert_mode, ..)
function M.clear(keymaps)
  local default = M:get_defaults()
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

---Returns a table with all the supported options defined
---in a keymap. Options explicitly set in a keymap will override
---default options.
---@param options table? optional table with existing options
---@param keymap table the standard keymap table
---@return table
function M:get_declared_options(options, keymap)
  options = options or {}
  for key, _ in pairs(self.supported_options) do
    if keymap[key] then
      options[key] = keymap[key]
    end
    if key == "desc" then
      options[key] = keymap[2]
    end
  end
  return options
end

--- Set key mappings individually
--- @param mode string keymap mode, can be one of the keys of mode_adapters
--- @param key string key of keymap
--- @param val table The keymap table
--- @return boolean success whether the keymap was set or not
function M:set_keymaps(mode, key, val)
  if type(val) ~= "table" and type(val[1]) ~= "string" then
    Log:warn("The keymapping for '" .. key .. "' is not a valid keymap. The value must be a table.")
    return false
  end
  local opt = M.generic_opts[M.mode_adapters[mode]]
  opt = self:get_declared_options(opt, val)
  if val[1] then
    vim.keymap.set(mode, key, val[1], opt)
  else
    pcall(vim.api.nvim_del_keymap, mode, key)
  end
  Log:debug(string.format("Key [%s] for mode [%s] with the value [%s] was set.", mode, key, val))
  return true
end

--- Load a selection of keymappings based on the modes that
--- where provided. Adds a keymap to the global keymap table
--- when the keymap was set.
--- @param mode string keymap mode, can be one of the keys of mode_adapters
--- @param keymaps table list of key mappings
function M:load_mode(mode, keymaps)
  if not self.mode_adapters[mode] then
    Log:warn("The mode '" .. mode .. "' is not a supp' mode.")
    return
  end
  local adapted_mode = self.mode_adapters[mode]
  for k, v in pairs(keymaps) do
    if self:set_keymaps(adapted_mode, k, v) then
      qvim.keymaps[mode][k] = v
    end
  end
  Log:info(string.format("The mappings for the mode %s where loaded", mode), keymaps)
end

--- Load key mappings for all provided modes
--- @param keymaps table list of key mappings for each mode
function M:load(keymaps)
  keymaps = keymaps or {}
  for mode, mapping in pairs(keymaps) do
    self:load_mode(mode, mapping)
  end
end

-- Get the default keymappings
function M:get_defaults()
  return defaults
end

return M
