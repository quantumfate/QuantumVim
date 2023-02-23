---The treesitter configuration file
local M = {}

local Log = require "qvim.integrations.log"
local utils = require "qvim.utils"

-- TODO: fix treesitter updating everytime qvim starts
---Registers the global configuration scope for treesitter
function M:init()
  local treesitter = {
    active = true,
    on_config_done = nil,
    whichkey_group = {
      group = nil,
      name = nil,
      bindings = {

      },
    },
    whichkey = {},
    keymaps = {},
    options = {
      -- treesitter option configuration
      ensure_installed = qvim_languages(),
      sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
      ignore_install = { "" }, -- List of parsers to ignore installing
      autopairs = {
        enable = true,
      },
      highlight = {
        enable = true, -- false will disable the whole extension
        disable = { "" }, -- list of language that will be disabled
        additional_vim_regex_highlighting = true,
      },
      indent = { enable = true, disable = { "yaml" } },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
    },
  }
  return treesitter
end

---The treesitter setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
  local status_ok, treesitter = pcall(reload, "nvim-treesitter.configs")
  if not status_ok then
    Log:warn(string.format("The plugin '%s' could not be loaded.", treesitter))
    return
  end
  local path = utils.join_paths(get_qvim_dir(), "site", "pack", "lazy", "opt", "nvim-treesitter")
  vim.opt.rtp:prepend(path)
  local _treesitter = qvim.integrations.treesitter
  treesitter.setup(_treesitter.options)

  if _treesitter.on_config_done then
    _treesitter.on_config_done()
  end
end

return M
