---@class hover : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: hover, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: hover)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: hover, instance: table)|nil hook setup logic at the end of the setup call
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
    mappings = {
      K = {
        "",
        "Hover",
        callback = function()
          require("hover").hover()
        end,
      },
      ["gK"] = {
        "",
        "Hover select",
        callback = function()
          require("hover").hover_select()
        end,
      }
    },
  },
  main = "hover",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = function(self)
    require("qvim.core.util").register_keymaps(self)
  end,
  url = "https://github.com/lewis6991/hover.nvim",
}

hover.__index = hover

return hover
