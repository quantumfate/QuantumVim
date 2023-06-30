---@class lsp.FileType An interface for filetype lsp extensions.
---@field java java
---@field python python
---@field c_cpp c_cpp
local M = {}

local shared_util = require("qvim.lang.utils")

local Log = require("qvim.log")
local fmt = string.format

local req_path = "qvim.lang.lsp.filetypes."

---Setup manually defined logic for a given `filetype`.
---@param filetype string
---@return boolean server_launched whether the called filetype extension already launched a language server
function M.setup(filetype)
	local server_launched = false
	local status_ok, filetype_ext = pcall(require, req_path .. shared_util.get_ft_bridge_proxy()[filetype])
	if status_ok and filetype_ext.setup then
		server_launched = filetype_ext.setup()
		Log:debug(fmt("Filetype extension launched for '%s'.", filetype))
	end
	return server_launched
end

---Call custom lsp settings on a given filetype.
---@param filetype string
---@return table|nil
function M.custom_lsp_settings(filetype)
	local custom_lsp_settings
	local status_ok, filetype_ext = pcall(require, req_path .. shared_util.get_ft_bridge_proxy()[filetype])
	if status_ok and filetype_ext.custom_lsp_settings then
		custom_lsp_settings = filetype_ext.custom_lsp_settings()
		Log:debug(fmt("Custom lsp settings for '%s' were pulled.", filetype))
	end
	return custom_lsp_settings
end

return M
