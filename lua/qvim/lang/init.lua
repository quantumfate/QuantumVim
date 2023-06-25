---@class lang
local M = {}

local autocmds = require("qvim.integrations.autocmds")

function M.setup()
	require("qvim.lang.lsp").setup()
	require("qvim.lang.null-ls").setup()
	require("qvim.lang.templates").generate_templates()
	--TODO: do dap stuff

	autocmds.configure_format_on_save()
end

return M
