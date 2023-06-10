---The lualine configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for lualine
function M:init()
  local lualine = {
    active = true,
    on_config_done = nil,
    theme = "qvim",
    keymaps = {},
    options = {
      -- lualine option configuration
      icons_enabled = nil,
      component_separators = nil,
      section_separators = nil,
      theme = nil,
      disabled_filetypes = { statusline = { "alpha" }, "dashboard", "NvimTree", "Outline" },
      globalstatus = true,
    },
    sections = {
      lualine_a = nil,
      lualine_b = nil,
      lualine_c = nil,
      lualine_x = nil,
      lualine_y = nil,
      lualine_z = nil,
    },
    inactive_sections = {
      lualine_a = nil,
      lualine_b = nil,
      lualine_c = nil,
      lualine_x = nil,
      lualine_y = nil,
      lualine_z = nil,
    },
    tabline = nil,
    extensions = nil,
  }
  return lualine
end

function M:config()
  -- lualine config function to call additional configs
  require("qvim.integrations.lualine.theme").update()
end

---The lualine setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  if in_headless_mode() then
    Log:debug "Headless mode detected. Skipping lualine"
    return
  end

  local status_ok, lualine = pcall(reload, "lualine")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", lualine))
    return
  end

  local _lualine = qvim.integrations.lualine
  lualine.setup(_lualine)

  if _lualine.on_config_done then
    _lualine.on_config_done()
  end
end

return M
