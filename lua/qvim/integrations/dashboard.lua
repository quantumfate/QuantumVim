---The dashboard configuration file
local M = {}

local Log = require "qvim.integrations.log"
local header = {
  [[                                                              ]],
  [[   ____                    __                _    ___         ]],
  [[  / __ \__  ______ _____  / /___  ______ ___| |  / (_)___ ___ ]],
  [[ / / / / / / / __ `/ __ \/ __/ / / / __ `__ \ | / / / __ `__ \]],
  [[/ /_/ / /_/ / /_/ / / / / /_/ /_/ / / / / / / |/ / / / / / / /]],
  [[\___\_\__,_/\__,_/_/ /_/\__/\__,_/_/ /_/ /_/|___/_/_/ /_/ /_/ ]],
  [[                                                              ]],
}

---comment
---@param icon string
---@param icon_hl string
---@param desc string
---@param desc_hl string
---@param key string
---@param keymap string
---@param key_hl string
---@param action string
---@return table
local function button_detailed(icon, icon_hl, desc, desc_hl, key, keymap, key_hl, action)
  local button = {}

  button.icon = icon
  button.icon_hl = icon_hl
  button.desc = desc
  button.desc_hl = desc_hl
  button.key = key
  button.keymap = keymap
  button.key_hl = key_hl
  button.action = action

  return button
end
local function button_detailec(icon, icon_hl, desc, desc_hl, key, keymap, key_hl, action)
  local button = {}

  button.icon = icon
  button.icon_hl = icon_hl
  button.desc = desc
  button.desc_hl = desc_hl
  button.key = key
  button.keymap = keymap
  button.key_hl = key_hl
  button.action = action

  return button
end

---Registers the global configuration scope for dashboard
M.config = function()
  qvim.integrations.dashboard = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- dashboard option configuration
      theme = 'hyper', --  theme is doom and hyper default is hyper
      header = { header },
      config = {
        week_header = {
          enable = false,
        },
        shortcut = {
          { desc = ' Update', group = '@property', action = 'Lazy update', key = 'u' },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Files',
            group = 'Label',
            action = 'Telescope find_files',
            key = 'f',
          },
          {
            desc = ' Apps',
            group = 'DiagnosticHint',
            action = 'Telescope app',
            key = 'a',
          },
          {
            desc = ' dotfiles',
            group = 'Number',
            action = 'Telescope dotfiles',
            key = 'd',
          },
        },
      }, --  config used for theme
      hide = {
        statusline = true, -- hide statusline default is true
        tabline = true, -- hide the tabline
        winbar = true, -- hide winbar
      },
      --preview = {
      --  command = "Telescope oldfiles", -- preview command
      --  file_path = get_qvim_dir(), -- preview file path
      --  file_height = 100, -- preview file height
      --  file_width = 100, -- preview file width
      --},
    },
  }
end

---The dashboard setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, dashboard = pcall(reload, "dashboard")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", dashboard)
    return
  end

  local _dashboard = qvim.integrations.dashboard
  dashboard.setup(_dashboard.options)

  if _dashboard.on_config_done then
    _dashboard.on_config_done()
  end
end

return M
