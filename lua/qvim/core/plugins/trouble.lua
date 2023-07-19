---@class trouble : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: trouble, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: trouble)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: trouble, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local trouble = {
  enabled = true,
  name = nil,
  options = {},
  keymaps = {},
  main = "trouble",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/folke/trouble.nvim",
}

trouble.__index = trouble

return trouble
