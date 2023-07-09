local util = {}

local log = require("qvim.log")
local fmt = string.format

---Requires a lazy spec of a plugin by a given path. The spec will extend a given `spec_mt`.
---@param path string
---@return table options the options defined in the spec or an empty table.
function util.load_lazy_config_spec_for_plugin(path, spec_mt)
  local plugin_spec
  local success, spec = pcall(require, path)
  if not success then
    log:debug(fmt("[core.loader] No spec available for '%s'.", path))
  end

  plugin_spec = setmetatable(spec, spec_mt)
  vim.validate({
    url = { plugin_spec[1], "s", false },
    name = { plugin_spec.name, "s", true },
    module = { plugin_spec.module, { "b" }, true },
    lazy = { plugin_spec.lazy, { "b" }, true },
    enabled = { plugin_spec.enabled, { "b", "f" }, true },
    main = { plugin_spec.main, "s", true },
    cond = { plugin_spec.cond, { "b", "f" }, true },
    dependencies = { plugin_spec.dependencies, "t", true },
    init = { plugin_spec.init, "f", true },
    opts = { plugin_spec.opts, { "t", "f" }, true },
    config = { plugin_spec.config, "f", true },
    build = { plugin_spec.build, { "f", "s" }, true },
    tag = { plugin_spec.tag, "s", true },
    version = { plugin_spec.version, { "s", "b" }, true },
    pin = { plugin_spec.pin, "b", true },
    event = { plugin_spec.event, { "s", "t", "f" }, true },
    cmd = { plugin_spec.cmd, { "s", "t", "f" }, true },
    ft = { plugin_spec.ft, { "s", "t", "f" }, true },
    keys = { plugin_spec.keys, { "s", "t", "f" }, true },
    priority = { plugin_spec.priority, "n", true },
  })
  log:debug(fmt("[core.loader] lazy config spec for '%s' was obtained.", path))
  return plugin_spec
end

---Provides a default spec for a plugin.
---
---Spec for plugins that are available in `qvim.plugins`:
---- url
---- name
---- lazy
---- main
---- config
---- pin
---- init
---
---Everything else:
---- url
---- name
---- lazy
---- pin
---- init
---@param plugin_name string
---@param url string
---@param hr_name string
---@return table
function util.core_plugin_spec_or_default(plugin_name, url, hr_name)
  local function init()
    log:debug(fmt("[core.loader] Loaded the plugin '%s'", url))
  end

  if qvim.plugins[plugin_name] then
    local enabled
    if type(qvim.plugins[plugin_name] == "string") then
      enabled = qvim.plugins[plugin_name].enabled
    else
      enabled = qvim.plugins[plugin_name].enabled()
    end
    return {
      url,
      name = hr_name,
      lazy = false,
      enabled = enabled,
      main = qvim.plugins[plugin_name].require_name,
      config = function()
        qvim.plugins[plugin_name]:setup()
      end,
      pin = false,
      init = init,
    }
  else
    return {
      url,
      name = hr_name,
      lazy = false,
      pin = false,
      init = init
    }
  end
end

---Provides a minimal spec for a plugin.
---- url
---- name
---- lazy
---- pin
---- init
---@param plugin_name string
---@param url string
---@param hr_name string
---@return table
function util.minimal_plugin_spec(plugin_name, url, hr_name)
  local function init()
    log:debug(fmt("[core.loader] First time setup! Loaded the plugin '%s'", url))
  end

  print(plugin_name)
  return {
    url,
    name = hr_name,
    lazy = false,
    pin = false,
    init = init
  }
end

return util
