---@class FileType An interface for filetype lsp extensions.
---@field java java
local M = {}

local Log = require("qvim.integrations.log")
local fmt = string.format

local req_path = "qvim.lang.lsp.filetypes."

---Setup manually defined logic for a given `filetype`.
---@return boolean server_launched whether the called filetype extension already launched a language server
function M.setup(filetype)
	local server_launched = false
	local status_ok, filetype_ext = pcall(require, req_path .. filetype)
	if status_ok then
		server_launched = filetype_ext.setup()
		Log:debug(fmt("Filetype extension launched for '%s'.", filetype))
	end
	return server_launched
end

return M
