local core_meta_plugin = require("qvim.core.meta.plugin")

local function create_buttons(buttons, button_area)
  local dashboard = require "alpha.themes.dashboard"

  for _, button in ipairs(buttons) do
    button_area.val[#button_area.val + 1] =
        dashboard.button(button.key, button.desc, button.cmd)
  end
  return button_area
end

---@class alpha-nvim : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps table|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field setup fun(self: alpha-nvim)|nil overwrite the setup function in core_base
---@field url string neovim plugin url
local alpha_nvim = {
  enabled = true,
  name = nil,
  options = {
    header = {
      [[                                                              ]],
      [[   ____                    __                _    ___         ]],
      [[  / __ \__  ______ _____  / /___  ______ ___| |  / (_)___ ___ ]],
      [[ / / / / / / / __ `/ __ \/ __/ / / / __ `__ \ | / / / __ `__ \]],
      [[/ /_/ / /_/ / /_/ / / / / /_/ /_/ / / / / / / |/ / / / / / / /]],
      [[\___\_\__,_/\__,_/_/ /_/\__/\__,_/_/ /_/ /_/|___/_/_/ /_/ /_/ ]],
      [[                                                              ]],
    },
    theme = "theta",
    noautocmd = true,
    section_mru = {
      type = "group",
      val = {
        {
          type = "text",
          val = "Recent files",
          opts = {
            hl = "SpecialComment",
            shrink_margin = false,
            position = "center",
          },
        },
        { type = "padding", val = 1 },
        {
          type = "group",
          val = function()
            local theme = require("alpha.themes.theta")
            local cdir = vim.fn.getcwd()
            return { theme.mru(0, cdir) }
          end,
          opts = { shrink_margin = false },
        },
      }
    },
    header_hl = "Include",
    -- alpha option configuration
    buttons = {
      {
        key = "f",
        desc = "  Find file",
        cmd = ":Telescope find_files <CR>",
      },
      {
        key = "e",
        desc = "  New file",
        cmd = ":ene <BAR> startinsert <CR>",
      },
      {
        key = "p",
        desc = "  Find project",
        cmd = ":Telescope projects <CR>",
      },
      {
        key = "r",
        desc = "  Recently used files",
        cmd = ":lua require'telescope'.extensions.project.project{}<CR>",
      },
      {
        key = "t",
        desc = "  Find text",
        cmd = ":Telescope live_grep <CR>",
      },
      {
        key = "c",
        desc = "  Configuration",
        cmd = ":e ~/.config/qvim/ <CR>",
      },
      { key = "q", desc = "  Quit Neovim", cmd = ":qa<CR>" },
    },
    button_area = {
      type = "group",
      val = {
        {
          type = "text",
          val = "Quick links",
          opts = { hl = "SpecialComment", position = "center" },
        },
        { type = "padding", val = 1 },
      },
      position = "center",
    },
  },
  keymaps = {},
  main = "alpha",
  ---@param self alpha-nvim
  setup = function(self)
    local theme = require("alpha.themes." .. self.options.theme)

    local buttons = create_buttons(self.options.buttons, self.options.button_area)
    theme.buttons = buttons
    theme.header.val = self.options.header
    theme.header.opts.hl = self.options.header_hl

    local layout = {
      { type = "padding", val = 2 },
      theme.header,
      { type = "padding", val = 2 },
      self.options.section_mru,
      { type = "padding", val = 2 },
      buttons,
    }
    theme.config.layout = layout

    require("qvim.core.util").call_super_setup(
      setmetatable({
        url = self.url,
        main = self.main,
        name = self.name,
        options = theme.config
      }, {
        __index = core_meta_plugin
      }))
  end,
  url = "https://github.com/goolord/alpha-nvim",
}

alpha_nvim.__index = alpha_nvim

return alpha_nvim
