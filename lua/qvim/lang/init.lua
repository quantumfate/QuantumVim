---@class lang
local M = {}
local utils = require("qvim.utils")
local autocmds = require("qvim.integrations.autocmds")

function M.setup()
	if not utils.is_directory(qvim.lsp.templates_dir) then
		require("qvim.lang.templates").generate_templates()
	end
	require("qvim.lang.lsp").setup()
	require("qvim.lang.null-ls").setup()


	autocmds.configure_format_on_save()
end

return M
