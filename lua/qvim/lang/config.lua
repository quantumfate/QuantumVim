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
			-- TODO fix this shit
			["<c-k>"] = {
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
			["<c-j>"] = {
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-j>"
					end
				end,
				"Hover scroll up",
				silent = true,
				expr = true,
				mode = { "n", "s", "i" },
			},
			["gd"] = {
				"<cmd>Telescope lsp_definitions<cr>",
				"Goto Definition",
			},
			["gD"] = {
				"<cmd>lua vim.lsp.buf.declaration()<cr>",
				"Goto Declaration",
			},
			["gt"] = {
				"<cmd>Telescope lsp_type_definitions<cr>",
				"Goto Type Definition",
			},
			["gr"] = {
				"<cmd>Telescope lsp_references<cr>",
				"Goto References",
			},
			["gI"] = {
				"<cmd>Telescope lsp_implementations<cr>",
				"Goto Implementation",
			},
			["gs"] = {
				"<cmd>lua vim.lsp.buf.signature_help()<cr>",
				"Show Signature Help",
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
				"Show Line Diagnostics",
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
				i = {
					name = "Info",
					s = { "<cmd>LspInfo<cr>", "Info" },
					m = { "<cmd>Mason<cr>", "Mason Info" },
				},
				n = {
					"<cmd>lua vim.diagnostic.goto_next()<cr>",
					"Next Diagnostic",
				},
				t = {
					"<cmd>lua vim.diagnostic.goto_prev()<cr>",
					"Prev Diagnostic",
				},
				L = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
				q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
				R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
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
