---@class copilot : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: copilot, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: copilot)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: copilot, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local copilot = {
  enabled = true,
  name = nil,
  options = {
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom", -- | top | left | right
        ratio = 0.4,
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<M-l>",
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },
    copilot_node_command = "node", -- Node.js version must be > 16.x
    server_opts_overrides = {},
  },
  keymaps = {},
  main = "copilot",
  on_setup_start = nil,
  setup = nil,
  on_setup_done = nil,
  url = "https://github.com/zbirenbaum/copilot.lua",
}

copilot.__index = copilot

return copilot
