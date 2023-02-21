---The autopairs configuration file
local M = {}

local Log = require "qvim.integrations.log"

---Registers the global configuration scope for autopairs
function M:init()
  local autopairs = {
    active = true,
    on_config_done = nil,
    whichkey = {
      leader = nil,
      name = nil,
      bindings = {

      },
    },
    keymaps = {},
    options = {
      -- autopairs option configuration
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
  }

  return autopairs
end

---The autopairs setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, autopairs = pcall(reload, "nvim-autopairs")
  if not status_ok then
    Log:warn("The plugin '%s' could not be loaded.", autopairs)
    return
  end

  local _autopairs = qvim.integrations.autopairs

  autopairs.setup(_autopairs.options)
  if qvim.integrations.cmp then
    local cmp_autopairs = autopairs.completion.cmp
    local cmp_status_ok, cmp = pcall(require, "cmp")
    if not cmp_status_ok then
      return
    end
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })
  end

  if _autopairs.on_config_done then
    _autopairs.on_config_done()
  end
end

return M
