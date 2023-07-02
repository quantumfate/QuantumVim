---@class lsp
local M = {}
local Log = require("qvim.log")
local utils = require("qvim.utils")
local autocmds = require("qvim.integrations.autocmds")

local function add_lsp_buffer_options(bufnr)
	for k, v in pairs(qvim.lsp.buffer_options) do
		vim.api.nvim_buf_set_option(bufnr, k, v)
	end
end

function M.common_capabilities()
	local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	if status_ok then
		return cmp_nvim_lsp.default_capabilities()
	end

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			"documentation",
			"detail",
			"additionalTextEdits",
		},
	}

	return capabilities
end

function M.common_on_exit(_, _)
	if qvim.lsp.document_highlight then
		autocmds.clear_augroup("lsp_document_highlight")
	end
	if qvim.lsp.code_lens_refresh then
		autocmds.clear_augroup("lsp_code_lens_refresh")
	end
end

function M.common_on_init(client, bufnr)
	if qvim.lsp.on_init_callback then
		qvim.lsp.on_init_callback(client, bufnr)
		Log:debug("Called lsp.on_init_callback")
		return
	end
end

function M.common_on_attach(client, bufnr)
	if qvim.lsp.on_attach_callback then
		qvim.lsp.on_attach_callback(client, bufnr)
		Log:debug("Called lsp.on_attach_callback")
	end
	local lu = require("qvim.lang.lsp.utils")
	if qvim.lsp.document_highlight then
		lu.setup_document_highlight(client, bufnr)
	end
	if qvim.lsp.code_lens_refresh then
		lu.setup_codelens_refresh(client, bufnr)
	end
	if client.server_capabilities["documentSymbolProvider"] then
		require("nvim-navic").attach(client, bufnr)
	end
	require("qvim.keymaps"):register(qvim.lsp.buffer_mappings, bufnr)
	add_lsp_buffer_options(bufnr)
	lu.setup_document_symbols(client, bufnr)
end

function M.get_common_opts()
	return {
		on_attach = M.common_on_attach,
		on_init = M.common_on_init,
		on_exit = M.common_on_exit,
		capabilities = M.common_capabilities(),
	}
end

function M.setup()
	Log:debug("Setting up LSP support")

	local lsp_status_ok, _ = pcall(require, "lspconfig")
	if not lsp_status_ok then
		return
	end

	if qvim.use_icons then
		for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
			vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
		end
	end

	local function set_handler_opts_if_not_set(name, handler, opts)
		if debug.getinfo(vim.lsp.handlers[name], "S").source:match(vim.env.VIMRUNTIME) then
			vim.lsp.handlers[name] = vim.lsp.with(handler, opts)
		end
	end

	set_handler_opts_if_not_set("textDocument/hover", vim.lsp.handlers.hover, { border = "rounded" })
	set_handler_opts_if_not_set("textDocument/signatureHelp", vim.lsp.handlers.signature_help, { border = "rounded" })

	-- Enable rounded borders in :LspInfo window.
	require("lspconfig.ui.windows").default_options.border = "rounded"
end

return M
