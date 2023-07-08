---@class dap.FileType An interface for filetype lsp extensions.
---@field java java
---@field python python
---@field c_cpp c_cpp
local M = {}

local shared_util = require("qvim.lang.utils")

local Log = require("qvim.log")
local fmt = string.format

local req_path = "qvim.lang.dap.filetypes."

---Setup manually defined logic for a given `filetype`.
---@param filetype string
function M.setup(filetype)
	local status_ok, filetype_ext = pcall(require, req_path .. shared_util.get_ft_bridge_proxy()[filetype])
	if status_ok and filetype_ext.setup then
		filetype_ext.setup()
		Log:debug(fmt("Filetype extension launched for '%s'.", filetype))
	end
end

return M
