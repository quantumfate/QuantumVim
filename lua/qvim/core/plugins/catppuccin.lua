local log = require("qvim.log")
local call_super_setup = require("qvim.core.util").call_super_setup

---@class catppuccin : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field setup fun(self: catppuccin)|nil overwrite the setup function in core_base
---@field url string neovim plugin url
local catppuccin = {
  enabled = true,
  name = nil,
  options = {
    -- catpuccin option configuration
    flavour = "mocha", -- latte, frappe, macchiato, mocha
    background = {     -- :h background
      light = "latte",
      dark = "frappe",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false,     -- shows the '~' characters after the end of buffers
    term_colors = false,            -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
      enabled = false,              -- dims the background color of inactive window
      shade = "dark",
      percentage = 0.15,            -- percentage of the shade to apply to the inactive window
    },
    no_italic = false,              -- Force no italic
    no_bold = false,                -- Force no bold
    no_underline = false,           -- Force no underline
    styles = {                      -- Handles the styles of general hi groups (see `:h highlight-args`):
      comments = { "italic" },      -- Change the style of comments
      conditionals = { "italic" },
      loops = {},
      functions = {},
      keywords = {},
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
    },
    color_overrides = {},
    integrations = {
      nvimtree = true,
      telescope = true,
      notify = true,
      alpha = true,
      gitsigns = true,
      hop = true,
      mini = false,
      indent_blankline = {
        enabled = true,
        colored_indent_levels = false,
      },
      leap = true,
      markdown = true,
      mason = true,
      neotest = true,
      cmp = true,
      dap = {
        enabled = true,
        enable_ui = true,
      },
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = { "italic" },
          hints = { "italic" },
          warnings = { "italic" },
          information = { "italic" },
        },
        underlines = {
          errors = { "underline" },
          hints = { "underline" },
          warnings = { "underline" },
          information = { "underline" },
        },
        inlay_hints = {
          background = true,
        },
      },
      navic = {
        enabled = true,
        custom_bg = "NONE",
      },
      ts_rainbow2 = true,
      treesitter_context = true,
      treesitter = true,
      which_key = true,
      illuminate = true,
      barbecue = {
        dim_dirname = true, -- directory name is dimmed by default
        bold_basename = true,
        dim_context = false,
        alt_background = false,
      },
      -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
  },
  keymaps = {},
  main = "catppuccin",
  setup = nil, -- getmetatable(self).__index.setup(self) to call generic setup with additional logic
  url = "https://github.com/catppuccin/nvim",
}

catppuccin.__index = catppuccin

return catppuccin
