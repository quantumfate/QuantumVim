local util = {}

local core_utils = require("qvim.core.util")
local log = require("qvim.log").qvim
local fmt = string.format

---Requires a lazy spec of a plugin by a given path. The spec will extend a given `spec_mt`.
---@param path string
---@return table? options the options defined in the spec or an empty table.
function util.load_lazy_config_spec_for_plugin(path, default_spec)
	local plugin_spec
	local success, spec = pcall(require, path)
	if not success then
		path = core_utils.get_plugin_basename(path)
		log.debug(fmt("[core.loader] No spec available for '%s'.", path))
		spec = {}
	end

	plugin_spec = vim.tbl_deep_extend("keep", spec, default_spec)

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
	log.debug(
		fmt("[core.loader] lazy config spec for '%s' was obtained.", path)
	)
	return plugin_spec
end

---@param resolved_plugin_table AbstractPlugin|AbstractParent|AbstractExtension
---@return boolean
local function is_enabled(resolved_plugin_table)
	local enabled
	if type(resolved_plugin_table.enabled == "string") then
		---@type boolean
		enabled = resolved_plugin_table.enabled
	else
		---@type boolean
		enabled = resolved_plugin_table.enabled()
	end
	return enabled
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
		log.debug(fmt("[core] Loaded the plugin '%s'", url))
	end

	if qvim.plugins[plugin_name] then
		return {
			url,
			name = hr_name,
			lazy = true,
			enabled = is_enabled(qvim.plugins[plugin_name]),
			main = qvim.plugins[plugin_name].main,
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
			lazy = true,
			pin = false,
			init = init,
		}
	end
end

---Resolves a spec for a dependency.
---@param parent_plugin_name string
---@param dep_plugin_name string
---@param dep_hr_name string
---@param url string
---@return table
function util.extension_or_standalone_dependency_spec(
	parent_plugin_name,
	dep_plugin_name,
	dep_hr_name,
	url
)
	local function init()
		log.debug(
			fmt("[core.loader] Loaded the dependency plugin spec '%s'", url)
		)
	end

	local qvim_parent = qvim.plugins[parent_plugin_name]
	local qvim_ext
	if qvim_parent then
		if qvim_parent.conf_extensions then
			qvim_ext = qvim_parent.conf_extensions[dep_plugin_name]
		end
	end
	if qvim_parent and qvim_ext then
		return {
			url,
			name = dep_hr_name,
			main = qvim_ext.main and qvim_ext.main or nil,
			enabled = is_enabled(qvim_ext),
			config = function()
				qvim_ext:setup_ext()
			end,
			pin = false,
			init = init,
		}
	else
		return {
			url,
			name = dep_hr_name,
			enabled = true,
			pin = false,
			init = init,
		}
	end
end

---Provides a minimal spec for a plugin.
---- url
---- name
---- lazy
---- pin
---- init
---@param url string
---@param hr_name string
---@return table
function util.minimal_plugin_spec(url, hr_name, path)
	local function init()
		log.debug(
			fmt("[core.loader] First time setup! Loaded the plugin '%s'", url)
		)
	end

	local success, spec = pcall(require, path)
	if not success then
		path = core_utils.get_plugin_basename(path)
		log.debug(fmt("[core.loader] No spec available for '%s'.", path))
		spec = {}
	end

	local dependencies
	local build
	if spec then
		if spec.dependencies then
			dependencies = spec.dependencies
		end
		if spec.build then
			build = spec.build
		end
	end
	return {
		url,
		name = hr_name,
		dependencies = dependencies,
		build = build,
		lazy = false,
		pin = false,
		init = init,
	}
end

return util
