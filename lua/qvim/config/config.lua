return {
	config = {
		colorscheme = "catppuccin",
		reload_config_on_save = true,
		leader = " ",
		use_icons = true,
		transparent_window = false,
		integrations = {
			"alpha",
			"autopairs",
			"breadcrumbs",
			"bufferline",
			"barbecue",
			"cmp",
			"comment",
			"dap",
			"gitsigns",
			"hop",
			"illuminate",
			"indentline",
			"lspconfig",
			"lualine",
			"mason",
			"mason-lspconfig",
			"mason-null-ls",
			"neodev",
			"notify",
			"tree",
			"null-ls",
			"project",
			"telescope",
			"toggleterm",
			"treesitter",
			"vimtex",
			"dressing",
			"whichkey",
			"catppuccin",
			"hover",
			"copilot",
			"refactoring",
		},
		languages = {
			-- https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
			"arduino",
			"bash",
			"comment",
			"c",
			"cpp",
			"cmake",
			"make",
			"lua",
			"vim",
			"dockerfile",
			"diff",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"graphql",
			"html",
			"css",
			"http",
			"java",
			"kotlin",
			"javascript",
			"tsx",
			"json",
			"json5",
			"latex",
			"markdown",
			"markdown_inline",
			"python",
			"r",
			"rasi",
			"regex",
			"ruby",
			"rust",
			"sql",
			"toml",
			"yaml",
		},
	},
	format_on_save = {
		---@usage boolean: format on save (Default: false)
		enabled = true,
		---@usage pattern string pattern used for the autocommand (Default: '*')
		pattern = "*",
		---@usage timeout number timeout in ms for the format request (Default: 1000)
		timeout = 1000,
		---@usage filter func to select client
		--filter = require("qvim.lang.lsp.utils").format_filter,
		-- TODO add mason-lspconfig
	},
	luasnip = {
		sources = {
			friendly_snippets = true,
		},
	},
	icons = require("qvim.icons"),
	autocommands = {},
	log = {
		---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
		level = "error",
		viewer = {
			---@usage this will fallback on "less +F" if not found
			cmd = "qnav",
			layout_config = {
				---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
				direction = "horizontal",
				open_mapping = "",
				size = 40,
				float_opts = {},
			},
		},
		-- currently disabled due to instabilities
		override_notify = false,
	},
}
