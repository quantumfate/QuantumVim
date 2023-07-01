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
	"glint",
	"golangci_lint_ls",
	"gradle_ls",
	"neocmake",
	"ocamlls",
	"phpactor",
	"psalm",
	"pylsp",
	"pylyzer",
	"pyre",
	"quick_lint_js",
	"reason_ls",
	"rnix",
	"rome",
	"ruby_ls",
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
	templates_dir = join_paths(get_qvim_rtp_dir(), "site", "after", "ftplugin"),
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
		["K"] = { callback = require("hover").hover, desc = "Show hover" },
		["gK"] = { callback = require("hover").hover_select, desc = "Select hover and show" },
		{
			binding_group = "l",
			name = "+LSP",
			bindings = {
				["d"] = { rhs = "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "Goto definition" },
				["D"] = { rhs = "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "Goto Declaration" },
				["r"] = { rhs = "<cmd>lua vim.lsp.buf.references()<cr>", desc = "Goto references" },
				["I"] = { rhs = "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Goto Implementation" },
				["s"] = { rhs = "<cmd>lua vim.lsp.buf.signature_help()<cr>", desc = "show signature help" },
				["l"] = {
					callback = function()
						local float = vim.diagnostic.config().float

						if float then
							local config = type(float) == "table" and float or {}
							config.scope = "line"

							vim.diagnostic.open_float(config)
						end
					end,
					desc = "Show line diagnostics",
				},
			},
			options = {
				prefix = "<leader>",
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
