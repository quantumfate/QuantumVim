local log = require("qvim.log")

---@class hover : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field setup fun(self: hover)|nil overwrite the setup function in core_base
---@field url string neovim plugin url
local hover = {
  enabled = true,
  name = nil,
  options = {
    init = function()
      -- Require providers
      require "hover.providers.lsp"
      require "hover.providers.gh"
      -- require('hover.providers.gh_user')
      -- require('hover.providers.jira')
      require('hover.providers.man')
      -- require('hover.providers.dictionary')
    end,
    preview_opts = {
      border = "single",
    },
    -- Whether the contents of a currently open hover window should be moved
    -- to a :h preview-window when pressing the hover keymap.
    preview_window = false,
    title = true,
  },
  keymaps = {
    -- TODO:
    -- vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
    -- vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})
  },
  main = "hover",
  setup = nil, -- getmetatable(self).__index.setup(self) to call generic setup with additional logic
  url = "https://github.com/lewis6991/hover.nvim",
}

hover.__index = hover

return hover
