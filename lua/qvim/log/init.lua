local internal = require("qvim.log.log")

---@class AbstractLog
---@field channel string
---@field info fun(msg: string, event: table?)
---@field trace fun(msg: string, event: table?)
---@field debug fun(msg: string, event: table?)
---@field warn fun(msg: string, event: table?)
---@field error fun(msg: string, event: table?)
---@field log_file_path fun(kind: string):string

---@class QvimLog : AbstractLog
---@class UserconfLog : AbstractLog
---@class LspLog : AbstractLog
---@class DapLog : AbstractLog
---@class NoneLsLog : AbstractLog

---@class Log
---@field qvim QvimLog
---@field userconf UserconfLog
---@field lsp LspLog
---@field dap DapLog
---@field none_ls NoneLsLog
local M = {}

---@type table<string, table>
local channels = {
	qvim = {},
	userconf = {},
	lsp = {},
	dap = {},
	none_ls = {},
}

---Setup the logger with its channels
function M.setup()
	local logger = internal:setup(channels, M)
	if not logger then
		vim.notify("Structlog not available.", vim.log.levels.ERROR)
		return
	end
end

return M
