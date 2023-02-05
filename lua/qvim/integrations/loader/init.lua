local plugin_loader = {}

local utils = require "qvim.utils"
local Log = require "qvim.utils.log"
local join_paths = utils.join_paths

local plugins_dir = join_paths(get_runtime_dir(), "site", "pack", "lazy", "opt")

---Initzialize lazy vim as the plugin loader. This function will
---make sure to only bootstrap lazy vim when it has not been
---installed yet. On subsequent runs this function will only
---setup the cache for plugins and it will additionally prevent
---lazy vims setup function to be called twice.
---@param opts table optionally parse supported options by lazy vim
function plugin_loader:init(opts)
  opts = opts or {}

  local lazy_install_dir = opts.install_path
      or join_paths(vim.fn.stdpath "data", "site", "pack", "lazy", "opt", "lazy.nvim")

  if not utils.is_directory(lazy_install_dir) then
    print "Initializing first time setup"
    local integrations_dir = join_paths(get_qvim_base_dir(), "plugins")
    if utils.is_directory(integrations_dir) then
      vim.fn.mkdir(plugins_dir, "p")
      vim.loop.fs_rmdir(plugins_dir)
      require("qvim.utils").fs_copy(integrations_dir, plugins_dir)
    else
      vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazy_install_dir,
      }

      local default_snapshot_path = join_paths(get_qvim_base_dir(), "snapshots", "default.json")
      local snapshot = assert(vim.fn.json_decode(vim.fn.readfile(default_snapshot_path)))
      vim.fn.system {
        "git",
        "-C",
        lazy_install_dir,
        "checkout",
        snapshot["lazy.nvim"].commit,
      }
    end
  end

  vim.opt.runtimepath:append(lazy_install_dir)
  vim.opt.runtimepath:append(join_paths(plugins_dir, "*"))

  local lazy_cache = require "lazy.core.cache"
  ---@diagnostic disable-next-line: redundant-parameter
  lazy_cache.setup {
    performance = {
      cache = {
        enabled = true,
        path = join_paths(get_cache_dir(), "lazy", "cache"),
      },
    },
  }
  -- HACK: Don't allow lazy to call setup second time
  lazy_cache.setup = function() end
end

function plugin_loader:reset_cache()
  os.remove(require("lazy.core.cache").config.path)
end

---Reloads all the plugins configured in spec,
---resets the cache for installed plugins and unloads
---old plugins to ensure everything will be clean loaded.
---Plugins will be unloaded at the beginning of the function
---call and when something goes wrong in the critical
---section, the unloaded plugins will be loaded again
---with their preserved state before they were unloaded.
---
---The plugin_loader.load(spec) function will be called
---at the end when everything went right.
---
---@param spec table the spec table https://github.com/folke/lazy.nvim#-plugin-spec
function plugin_loader:reload(spec)
  local modules = require "qvim.utils.modules"
  local old_modules = {}
  for m, _ in pairs(package.loaded) do
    local old = modules.unload(m)
    old_modules[#old_modules + 1] = old
  end

  ---Critical section when reloading plugins.
  local function relaod()
    local Config = require "lazy.config"
    local lazy = require "lazy"
    local hooks = require "qvim.utils.hooks"

    hooks.reset_cache()
    Config.spec = spec

    require("lazy.core.plugin").load(true)
    require("lazy.core.plugin").update_state()

    local not_installed_plugins = vim.tbl_filter(function(plugin)
      return not plugin._.installed
    end, Config.plugins)

    require("lazy.manage").clear()

    if #not_installed_plugins > 0 then
      lazy.install { wait = true }
    end

    if #Config.to_clean > 0 then
      -- TODO: set show to true when lazy shows something useful on clean
      lazy.clean { wait = true, show = false }
    end
  end

  local success, _ = pcall(relaod)
  if not success then
    local trace = debug.getinfo(2, "SL")
    local shorter_src = trace.short_src
    local lineinfo = shorter_src .. ":" .. (trace.currentline or trace.linedefined)
    local msg = string.format("%s : something went wrong when trying to reload the lazy plugin config spec [%s]",
      lineinfo)
    Log:error(msg)
    for m, _ in pairs(old_modules) do
      modules.require_safe(m)
    end
    return
  else
    plugin_loader:load(spec)
  end
end

---Loads all plugins and calls their setup function
---@param spec table|nil the plugin configuration table
function plugin_loader:load(spec)
  spec = spec or require("qvim.integrations.loader.spec")
  Log:debug "loading plugins configuration"
  local lazy_available, lazy = pcall(require, "lazy")
  if not lazy_available then
    Log:warn "skipping loading plugins until lazy.nvim is installed"
    return
  end

  -- remove plugins from rtp before loading lazy, so that all plugins won't be loaded on startup
  vim.opt.runtimepath:remove(join_paths(plugins_dir, "*"))

  local status_ok = xpcall(function()
    local opts = {
      install = {
        missing = true,
        colorscheme = { qvim.colorscheme, "lunar", "habamax" },
      },
      ui = {
        border = "rounded",
      },
      root = plugins_dir,
      git = {
        timeout = 120,
      },
      lockfile = join_paths(get_config_dir(), "lazy-lock.json"),
      performance = {
        rtp = {
          reset = false,
        },
      },
      readme = {
        root = join_paths(get_runtime_dir(), "lazy", "readme"),
      },
    }

    lazy.setup(spec, opts)
  end, debug.traceback)

  if not status_ok then
    Log:warn "problems detected while loading plugins' configurations"
    Log:trace(debug.traceback())
  end
end

---Requires the plugin spec and filter
---@return table
function plugin_loader:get_core_plugins()
  local names = {}
  local plugins = require "qvim.integrations.loader.plugins_spec"
  local get_name = require("lazy.core.plugin").Spec.get_name
  for _, spec in pairs(plugins) do
    if spec.enabled == true or spec.enabled == nil then
      table.insert(names, get_name(spec[1]))
    end
  end
  return names
end

function plugin_loader:sync_core_plugins()
  local core_plugins = plugin_loader:get_core_plugins()
  Log:trace(string.format("Syncing core plugins: [%q]", table.concat(core_plugins, ", ")))
  require("lazy").update { wait = true, plugins = core_plugins }
end

function plugin_loader.ensure_plugins()
  Log:debug "calling lazy.install()"
  require("lazy").install { wait = true }
end

return plugin_loader
