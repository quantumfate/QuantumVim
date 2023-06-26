---@class lang_utils
---@field get_all_supported_filetypes_to_servers function
---@field select_language_server function
local M = {}

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

return M
