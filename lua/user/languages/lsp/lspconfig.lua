--[[
  Requiring the necessary modules ]]

local utils = require("user.utils.util")
utils:set_use_xpcall(true)
utils:show_variables_in_trace(true)

local debugger = utils:require_module("user.utils.debugger")
local mason_lspconfig = utils:require_module("mason-lspconfig")
local handlers = utils:require_module("user.languages.lsp.handlers")
local conf_languages = utils:require_module("user.languages.config")

local conf_languages = require("user.languages.config")
local configured_languages = conf_languages:new()
local configured_language_servers = configured_languages:get_unique_lsp_server_list()

mason_lspconfig.setup({
	ensure_installed = configured_language_servers,
	automatic_installation = true,
}) -- automatically install specified servers

local server_opts = {
	on_attach = handlers.on_attach,
	capabilities = handlers.capabilities(),
}

--[[
-- Create the tracking table to ensure any lsp server
-- will only be required once
--]]
track_lsp = {}
for language_key, language_table in pairs(configured_languages) do
	current_lsp_server = language_table:get_lsp_server()
	track_lsp[current_lsp_server] = true
end

vim.notify("hallo")
for language_key, language_table in pairs(configured_languages) do
	local lsp_server = language_table:get_lsp_server()
	local lsp_server_settings = language_table:get_lsp_server_settings()
	--local has_server_extension = language_table:has_server_extension()
	--local hook_function = language_table:hook_server_extension_config_with_function
	print(lsp_server)
	if track_lsp[lsp_server] then
		-- Plug on_attach and capabilities to current server
		opts = vim.tbl_deep_extend("force", lsp_server_settings, server_opts)

		require("lspconfig")[lsp_server].setup({ opts })
	end

	track_lsp[lsp_server] = false
end

handlers.setup()
