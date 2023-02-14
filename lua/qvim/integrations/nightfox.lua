---The nightfox configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for nightfox
M.config = function()
  qvim.integrations.nightfox = {
    active = true,
    on_config_done = nil,
    keymaps = {},
    supported_modules = {
      "aerial",
      "barbar",
      "cmp",
      "coc",
      "dap_ui",
      "dashboard",
      "diagnostic",
      "fern",
      "fidget",
      "gitgutter",
      "gitsigns",
      "glyph_palette",
      "hop",
      "illuminate",
      "lightspeed",
      "lsp_saga",
      "lsp_trouble",
      "mini",
      "modes",
      "native_lsp",
      "navic",
      "neogit",
      "neotest",
      "neotree",
      "notify",
      "nvimtree",
      "pounce",
      "signify",
      "sneak",
      "symbol_outline",
      "telescope",
      "treesitter",
      "tsrainbow",
      "tsrainbow2",
      "whichkey"
    },
    options = {
      -- nightfox option configuration
      options = {
        transparent = true, -- Disable setting background
      },
    }
  }
end

---The nightfox setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
M.setup = function()
  local status_ok, nightfox = pcall(reload, "nightfox")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", nightfox)
    return
  end

  local supported_modules = qvim.integrations.nightfox.supported_modules
  local modules = qvim.integrations.nightfox.options.options.modules
  for module, _ in pairs(supported_modules) do
    if qvim.integrations[module] and qvim.integrations[module].active then
      modules[modules + 1] = module
    end
  end
  nightfox.setup(qvim.integrations.nightfox.options)

  vim.cmd("colorscheme nightfox")
  qvim.colorscheme = "nightfox"

  local lualine = qvim.integrations.lualine
  lualine.options.theme = qvim.colorscheme

  if qvim.integrations.nightfox.on_config_done then
    qvim.integrations.nightfox.on_config_done()
  end
end

return M
