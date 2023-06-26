---@class lang_utils
---@field get_all_supported_filetypes_to_servers function
---@field select_language_server function
local M = {}
local Log = require("qvim.integrations.log")
local fmt = string.format

---Get a proxy table that maps filetypes to there specific ft file.
---@return table
function M.get_ft_bridge_proxy()
	local bridge = {
		["c"] = "c_cpp",
		["cpp"] = "c_cpp"
	}

	local bridge_proxy_mt = {
		__index = function(_, k)
			if bridge[k] then
				return bridge[k]
			end
			return k
		end
	}

	return setmetatable({}, bridge_proxy_mt)
end

---Get a map of all supported filetypes mapped to supported languages servers
---@return table<string, table<string>> supported filestypes as a list of strings
function M.get_all_supported_filetypes_to_servers()
	local status_ok, filetype_server_map = pcall(require, "mason-lspconfig.mappings.filetype")
	if not status_ok then
		return {}
	end
	return filetype_server_map
end

---Takes filetype and its supported language servers to select one language server for the given filetype
---that shall be used.
---@param ft string
---@param servers table<string>
---@return string
function M.select_language_server(ft, servers)
	local ok, server = pcall(require, "qvim.lang.lsp.selection." .. ft)
	if ok then
		return server
	end
	return servers[1]
end

---Checks whether a given `source` is a mason package.
---@param source table|string
function M.is_package(source)
	if type(source) == "table" and source.name then
		return tostring(source) == fmt("Package(name=%s)", source.name)
	end
	return false
end

---Attempts to install a mason package for a given `package`. After installation a given `setup` function will be invoked
---@param package Package the valid mason package object
---@param scope string for descriptive log messages
---@param setup function the function to be called after install success or when the package is already installed
---@param args table a table that will be unpacked as arguments for the `setup` callback
function M.try_install_and_setup_mason_package(package, scope, setup, args)
	---@class Package
	---@field is_installed function
	---@field install function
	---@field name string

	if not package:is_installed() then
		Log:debug(fmt("Automatically installing '%s' by the mason package '%s'.", scope, package.name))
		package:install():once("closed", function()
			vim.schedule(function()
				if package:is_installed() then
					Log:info(fmt("Installed '%s' by the mason package '%s'.", scope, package.name))
					setup(unpack(args))
				else
					Log:warn(
						fmt(
							"Installation of '%s' by the mason package '%s' failed. Consult mason logs.",
							scope,
							package.name
						)
					)
				end
			end)
		end)
	else
		setup(unpack(args))
	end
end

---Register a custom mason package with a spec provided by the user. `require_path` and `require_name`
---will be appended with a dot.
---@param require_name string name of the file to be required
---@param require_path string location of the file to be required
---@return boolean
---@return Package|nil
function M.register_custom_mason_package(require_name, require_path)
	---@class Package
	---@field new function
	local Package = require("mason-core.package")
	local _ok, source_package_spec = pcall(require, require_path .. "." .. require_name)
	if _ok then
		Log:debug(
			fmt(
				"A custom mason package '%s' was instanciated from the source '%s' that will be used for installation. Module was: '%s'.",
				source_package_spec.name,
				require_name,
				require_path
			)
		)
		local pkg_ok, pkg = pcall(Package.new, source_package_spec)
		if pkg_ok then
			return pkg_ok, pkg
		end
	end
	return false, nil
end

return M
