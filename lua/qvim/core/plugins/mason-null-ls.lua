---@class mason-null-ls : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: mason-null-ls, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: mason-null-ls)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: mason-null-ls, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local mason_null_ls = {
  enabled = true,
  name = nil,
  options = {
    ensure_installed = nil,
    automatic_installation = false,
    handlers = nil,
  },
  keymaps = {},
  main = "mason-null-ls",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/jay-babu/mason-null-ls.nvim",
}

mason_null_ls.__index = mason_null_ls

return mason_null_ls
