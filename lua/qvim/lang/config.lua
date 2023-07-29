local skipped_servers = {
	"angularls",
	"antlersls",
	"azure_pipelines_ls",
	"ccls",
	"custom_elements_ls",
	"omnisharp",
	"cssmodules_ls",
	"denols",
	"ember",
	"emmet_ls",
	"eslint",
	"eslintls",
	"neocmake",
	"ocamlls",
	"psalm",
	"pylsp",
	"pylyzer",
	"pyre",
	"quick_lint_js",
	"reason_ls",
	"rnix",
	"rome",
	"ruff_lsp",
	"scry",
	"solang",
	"solc",
	"solidity_ls",
	"solidity_ls_nomicfoundation",
	"sorbet",
	"sourcekit",
	"sourcery",
	"spectral",
	"standardrb",
	"stylelint_lsp",
	"svlangserver",
	"tflint",
	"unocss",
	"verible",
	"vtsls",
	"vuels",
}

local skipped_filetypes = { "plaintext", "toml", "proto" }

local join_paths = require("qvim.utils").join_paths

return {
	templates_dir = join_paths(get_qvim_config_dir(), "after", "ftplugin"),
	---@deprecated use vim.diagnostic.config({ ... }) instead
	diagnostics = {},
	document_highlight = false,
	code_lens_refresh = true,
	on_attach_callback = nil,
	on_init_callback = nil,
	automatic_configuration = {
		"lua_ls",
		---@usage list of servers that the automatic installer will skip
		skipped_servers = skipped_servers,
		---@usage list of filetypes that the automatic installer will skip
		skipped_filetypes = skipped_filetypes,
	},
	buffer_mappings = {

		mappings = {
			["K"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show hover" },
			["<c-t>"] = {
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-k>"
					end
				end,
				"Hover scroll down",
				silent = true,
				expr = true,
				mode = { "n", "s", "i" },
			},
			["<c-n>"] = {
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-n>"
					end
				end,
				"Hover scroll up",
				silent = true,
				expr = true,
				mode = { "n", "s", "i" },
			},
			["gd"] = {
				"<cmd>lua vim.lsp.buf.definition()<cr>",
				"Goto definition",
			},
			["gD"] = {
				"<cmd>lua vim.lsp.buf.declaration()<cr>",
				"Goto Declaration",
			},
			["gr"] = {
				"<cmd>lua vim.lsp.buf.references()<cr>",
				"Goto references",
			},
			["gI"] = {
				"<cmd>lua vim.lsp.buf.implementation()<cr>",
				"Goto Implementation",
			},
			["gs"] = {
				"<cmd>lua vim.lsp.buf.signature_help()<cr>",
				"show signature help",
			},
			["gl"] = {
				function()
					local float = vim.diagnostic.config().float

					if float then
						local config = type(float) == "table" and float or {}
						config.scope = "line"

						vim.diagnostic.open_float(config)
					end
				end,
				"Show line diagnostics",
			},
		},
		groups = {
			l = {
				name = "+LSP",
				a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
				d = {
					function()
						local buf_arg = "bufnr="
							.. tostring(vim.api.nvim_get_current_buf())
						vim.cmd({
							cmd = "Telescope",
							args = { "diagnostics", buf_arg },
						})
					end,
					"Buffer Diagnostics",
				},
				w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
				f = {
					"<cmd>lua require('lvim.lsp.utils').format()<cr>",
					"Format",
				},
				i = { "<cmd>LspInfo<cr>", "Info" },
				I = { "<cmd>Mason<cr>", "Mason Info" },
				j = {
					"<cmd>lua vim.diagnostic.goto_next()<cr>",
					"Next Diagnostic",
				},
				k = {
					"<cmd>lua vim.diagnostic.goto_prev()<cr>",
					"Prev Diagnostic",
				},
				L = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
				q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
				r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
				s = {
					"<cmd>Telescope lsp_document_symbols<cr>",
					"Document Symbols",
				},
				S = {
					"<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
					"Workspace Symbols",
				},
				e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
			},
		},
	},
	buffer_options = {
		--- enable completion triggered by <c-x><c-o>
		omnifunc = "v:lua.vim.lsp.omnifunc",
		--- use gq for formatting
		formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
	},
	---@usage list of settings of nvim-lsp-installer
	installer = {
		setup = {
			ensure_installed = { "lua_ls" },
			automatic_installation = {
				"lua_ls",
				exclude = {},
			},
		},
	},
	null_ls = {
		setup = {
			debug = false,
			update_in_insert = true,
			debounce = 300,
		},
	},
	mason_null_ls = {
		ensure_installed = {},
		automatic_installation = false,
		handlers = {},
	},
	---@deprecated use qvim.lsp.automatic_configuration.skipped_servers instead
	override = {},
	---@deprecated use qvim.lsp.installer.setup.automatic_installation instead
	automatic_servers_installation = nil,
}
