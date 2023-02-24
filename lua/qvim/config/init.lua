local utils = require "qvim.utils"
local Log = require "qvim.integrations.log"

local M = {}

--- Initialize qvim default configuration and variables
--- This must be called at the beginning when qvim is
--- loaded since everything depends on this.
function M:init()
  qvim = setmetatable({}, { __index = vim.deepcopy(require("qvim.config.config")) })

  local settings = require "qvim.config.settings"
  settings.load_defaults()

  --local qvim_lsp_config = require "qvim.lsp.config"
  -- TODO: add lsp language configs to global qvim variable
  --qvim.lsp = vim.deepcopy(qvim_lsp_config)

  ---@return table integrations
  function _G.qvim_integrations()
    local integrations = qvim.config.integrations
    return integrations
  end

  ---@return table languages
  function _G.qvim_languages()
    local languages = qvim.config.languages
    return languages
  end
end

--[[
  For now I have absolutely no intentions to implement the functions
  below as my configuration is not meant to be scalable by desing.
  I don't have the need for an abstract configuration interface.
  I just need my own configuration.

  The concept was adapted from the following project which
  implements this.

  https://github.com/LunarVim/LunarVim
]]
--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
--function M:load(config_path)
--  local autocmds = reload "qvim.core.autocmds"
--  config_path = config_path or self:get_user_config_path()
--  local ok, err = pcall(dofile, config_path)
--  if not ok then
--    if utils.is_file(user_config_file) then
--      Log:warn("Invalid configuration: " .. err)
--    else
--      vim.notify_once(
--        string.format("User-configuration not found. Creating an example configuration in %s", config_path)
--      )
--      local config_name = vim.loop.os_uname().version:match "Windows" and "config_win" or "config"
--      local example_config = join_paths(get_qvim_dir(), "utils", "installer", config_name .. ".example.lua")
--      vim.fn.mkdir(user_config_dir, "p")
--      vim.loop.fs_copyfile(example_config, config_path)
--    end
--  end
--
--  Log:set_level(qvim.log.level)
--
--  autocmds.define_autocmds(qvim.autocommands)
--  vim.g.mapleader = (qvim.leader == "space" and " ") or qvim.leader
--
--  reload("qvim.keymappings").load(qvim.keys)
--
--  if qvim.transparent_window then
--    autocmds.enable_transparent_mode()
--  end
--
--  if qvim.reload_config_on_save then
--    autocmds.enable_reload_config_on_save()
--  end
--end

--- Override the configuration with a user provided one
-- @param config_path The path to the configuration overrides
--function M:reload()
--  vim.schedule(function()
--    reload("qvim.utils.hooks").run_pre_reload()
--
--    M:load()
--
--    reload("qvim.core.autocmds").configure_format_on_save()
--
--    local plugins = reload "qvim.integrations"
--    local plugin_loader = reload "qvim.plugin-loader"
--
--    plugin_loader.reload { plugins }
--    reload("qvim.core.theme").setup()
--    reload("qvim.utils.hooks").run_post_reload()
--  end)
--end

return M
