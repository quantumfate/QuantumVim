---@class loader
local loader = {}
loader.__index = loader

local log = require("qvim.log")
local fmt = string.format
local core_util = require("qvim.core.util")

local plugin_spec_path = "qvim.core.loader.specs."

---Populates a lazy spec for a plugin by a given `plugin_name` and `url`. Lazy
---specs for dependencies of the plugin will be populated recursively.
---@param plugin_name string
---@param url string
---@return table? plugin_spec
function loader.new(plugin_name, url)
	vim.validate({
		plugin_name = { plugin_name, "s", false },
		url = { url, "s", false },
	})

	-- TODO in headless mode/ first time setup: only populate the spec with url and enabled set to true and the plugin_name

	local spec_require_path = plugin_spec_path .. plugin_name
	local default_spec = {
		url,
		name = plugin_name,
		lazy = false,
		enabled = true and qvim.plugins[plugin_name].enabled,
		main = qvim.plugins[plugin_name].require_name,
		config = function()
			qvim.plugins[plugin_name]:setup()
		end,
		pin = false,
		init = function()
			log:debug(fmt("[core.loader] Loaded the plugin '%s'", url))
		end,
	}

	local plugin_spec = loader.load_lazy_config_spec_for_plugin(spec_require_path, { __index = default_spec })

	if plugin_spec then
		vim.validate({
			url = { plugin_spec[1], "s", false },
			name = { plugin_spec.name, "s", true },
			module = { plugin_spec.module, { "b" }, true },
			lazy = { plugin_spec.lazy, { "b" }, true },
			enabled = { plugin_spec.enabled, { "b", "f" }, true },
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

		if plugin_spec.dependencies then
			local dep_spec = {}
			for _, dep in pairs(plugin_spec.dependencies) do
				if type(dep) == "string" then
					local dep_ok, dep_name = core_util.is_valid_plugin_name(dep)
					if dep_ok and dep_name then
						dep_spec[#dep_spec + 1] = loader.new(dep_name, dep)
					else
						log:debug(
							fmt(
								"[core.loader] Failed to load spec for dependency '%s', of the plugin '%s'.",
								dep,
								plugin_name
							)
						)
					end
				elseif type(dep) == "table" then
					dep_spec[#dep_spec + 1] = dep
				else
					log:debug(
						fmt(
							"[core.loader] Unknown dependency listed in '%s'. Should be type string or table but was '%s'.",
							plugin_name,
							type(dep)
						)
					)
				end
			end
			plugin_spec.dependencies = dep_spec
		end
		return plugin_spec
	end
end

---Requires a lazy spec from the config directory and if the file exists it will return
---the table that it would return as if it was directly required. If the
---module doesn't exist this function will just return an empty table so that
---this function can be used without any extra run time checks.
---@param path string
---@return table|nil options the options that should override the individual default plugin spec
function loader.load_lazy_config_spec_for_plugin(path, spec_mt)
	local plugin_spec = {}
	local success, spec = pcall(require, path)
	if not success then
		log:debug(fmt("[core.loader] No spec available for '%s'.", path))
	end

	plugin_spec = setmetatable(spec, spec_mt)
	log:debug(fmt("[core.loader] lazy config spec for '%s' was obtained.", path))
	return plugin_spec
end

return loader
