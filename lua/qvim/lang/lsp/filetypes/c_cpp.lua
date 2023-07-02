---@class c_cpp
---@field custom_on_attach function
local M = {}

function M.setup() end

---Setup custom lsp settings for c and cpp
---@return table
function M.custom_lsp_settings()
	-- some settings can only passed as commandline flags, see `clangd --help`
	local clangd_flags = {
		"--background-index",
		"--fallback-style=Google",
		"--all-scopes-completion",
		"--clang-tidy",
		"--log=error",
		"--suggest-missing-includes",
		"--cross-file-rename",
		"--completion-style=detailed",
		"--pch-storage=memory", -- could also be disk
		"--folding-ranges",
		"--enable-config", -- clangd 11+ supports reading from .clangd configuration file
		"--offset-encoding=utf-16", --temporary fix for null-ls
		-- "--limit-references=1000",
		-- "--limit-resutls=1000",
		-- "--malloc-trim",
		-- "--clang-tidy-checks=-*,llvm-*,clang-analyzer-*,modernize-*,-modernize-use-trailing-return-type",
		-- "--header-insertion=never",
		-- "--query-driver=<list-of-white-listed-complers>"
	}

	local provider = "clangd"

	local custom_on_attach = function(client, bufnr)
		require("qvim.lang.lsp").common_on_attach(client, bufnr)

		require("clangd_extensions.inlay_hints").setup_autocmd()
		require("clangd_extensions.inlay_hints").set_inlay_hints()
		local keymaps = require("qvim.keymaps")

		keymaps:register({
			{
				binding_group = "C",
				name = "+c/cpp",
				bindings = {
					h = { rhs = "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch source header" },
					A = { rhs = "<cmd>ClangdAST<cr>", desc = "Show abstract syntax tree", mode = "x" },
					H = { rhs = "<cmd>ClangdTypeHierarchy<cr>", desc = "Show type hierarchy" },
					t = { rhs = "<cmd>ClangdSymbolInfo<cr>", desc = "Show symbol info" },
					m = { rhs = "<cmd>ClangdMemoryUsage<cr>", desc = "Show memory usage" },
				},
				options = {
					prefix = "<leader>",
				},
			},
		})
	end

	local status_ok, project_config = pcall(require, "rhel.clangd_wrl")
	if status_ok then
		clangd_flags = vim.tbl_deep_extend("keep", project_config, clangd_flags)
	end

	local custom_on_init = function(client, bufnr)
		require("qvim.lang.lsp").common_on_init(client, bufnr)
		require("clangd_extensions.config").setup({})
		require("clangd_extensions.ast").init()
		vim.cmd([[
  command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
  command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
  command ClangdTypeHierarchy lua require('clangd_extensions.type_hierarchy').show_hierarchy()
  command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
  command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')
  ]])
	end

	return {
		cmd = { provider, unpack(clangd_flags) },
		on_attach = custom_on_attach,
		on_init = custom_on_init,
	}
end

return M
