return {
	---@class config
	---@field colorscheme string
	---@field reload_config_on_save boolean
	---@field leader string
	---@field use_icons boolean
	---@field transparent_window boolean
	---@field languages table<string>
	config = {
		colorscheme = "catppuccin",
		reload_config_on_save = true,
		leader = " ",
		use_icons = true,
		transparent_window = false,
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
	---@class format_on_save
	---@field enabled boolean
	---@field pattern string
	---@field timout number
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
	---@class luasnip
	---@field sources luasnip.sources
	luasnip = {
		---@class luasnip.sources
		---@field friendly_snippets boolean
		sources = {
			friendly_snippets = true,
		},
	},
	---@class icons
	icons = require("qvim.icons"),
	---@class autocommands
	autocommands = {},
	---@class log
	---@field level string
	---@field viewer table
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
	---@alias Plugins table<string, AbstractPlugin>|table<string, AbstractParent>
	---@type Plugins
	plugins = {},
}
