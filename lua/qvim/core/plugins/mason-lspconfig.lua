---@class mason-lspconfig : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: mason-lspconfig, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: mason-lspconfig)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: mason-lspconfig, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local mason_lspconfig = {
  enabled = true,
  name = nil,
  options = {
    automatic_installation = false,
  },
  keymaps = {},
  main = "mason-lspconfig",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/williamboman/mason-lspconfig.nvim",
}

mason_lspconfig.__index = mason_lspconfig

return mason_lspconfig
