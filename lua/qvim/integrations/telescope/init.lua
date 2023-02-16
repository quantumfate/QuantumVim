---The telescope configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for telescope
M.config = function()
  qvim.integrations.telescope = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    options = {
      -- telescope option configuration

    },
    -- TODO: https://github.com/nvim-telescope/telescope.nvim/wiki/Extensions
    extensions = {
      "fzf-native",
      "lazy",
      "dap",
    }
  }
end

---The telescope setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, telescope = pcall(reload, "telescope")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", telescope)
    return
  end

  telescope.setup(qvim.integrations.telescope.options)
  for _, value in ipairs(qvim.integrations.telescope.extensions) do
    telescope.load_extension(value)
  end

  if qvim.integrations.telescope.on_config_done then
    qvim.integrations.telescope.on_config_done()
  end
end

return M
