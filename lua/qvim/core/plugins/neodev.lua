---@class neodev : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field setup fun(self: neodev)|nil overwrite the setup function in core_base
---@field url string neovim plugin url
local neodev = {
  enabled = true,
  name = nil,
  options = {
    library = { plugins = { "nvim-dap-ui" }, types = true },
  },
  keymaps = {},
  main = "neodev",
  setup = nil, -- getmetatable(self).__index.setup(self) to call generic setup with additional logic
  url = "https://github.com/folke/neodev.nvim",
}

neodev.__index = neodev

return neodev
