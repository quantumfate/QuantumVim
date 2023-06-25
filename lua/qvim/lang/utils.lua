---@class lang_utils
---@field get_all_supported_filetypes_to_servers function
---@field select_language_server function
local M = {}

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
