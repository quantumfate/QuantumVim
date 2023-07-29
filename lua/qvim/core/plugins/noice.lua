---@class noice : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: noice, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: noice)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: noice, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local noice = {
	enabled = true,
	name = nil,
	options = {
		lsp = {
			message = {
				-- Messages shown by lsp servers
				enabled = false,
				view = "notify",
				opts = {},
			},
			-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			progress = { enabled = true },
		},
		-- you can enable a preset for easier configuration
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = true, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false, -- add a border to hover docs and signature help
		},
		views = {
			cmdline_popup = {
				position = {
					row = 5,
					col = "50%",
				},
				size = {
					width = 60,
					height = "auto",
				},
				border = {
					style = "none",
					padding = { 2, 3 },
				},
				filter_options = {},
				win_options = {
					winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
				},
			},
			popupmenu = {
				relative = "editor",
				position = {
					row = 8,
					col = "50%",
				},
				size = {
					width = 60,
					height = 10,
				},
				border = {
					style = "rounded",
					padding = { 0, 1 },
				},
				win_options = {
					winhighlight = {
						Normal = "Normal",
						FloatBorder = "DiagnosticInfo",
					},
				},
			},
			mini_err = {
				backend = "mini",
				relative = "editor",
				align = "message-right",
				timeout = 2000,
				reverse = false,
				focusable = false,
				position = {
					row = 1,
					col = "100%",
					-- col = 0,
				},
				size = "auto",
				border = {
					style = "none",
				},
				zindex = 60,
				win_options = {
					winbar = "",
					foldenable = false,
					winblend = 30,
					winhighlight = {
						Normal = "NoiceMini",
						IncSearch = "",
						CurSearch = "",
						Search = "",
					},
				},
			},
			mini = {},

			hover = {
				view = "popup",
				relative = "cursor",
				zindex = 45,
				enter = false,
				anchor = "auto",
				size = {
					width = "auto",
					height = "auto",
					max_height = 40,
					max_width = 180,
				},
				border = {
					style = "none",
					padding = { 1, 2 },
				},
				position = { row = 1, col = 0 },
				win_options = {
					wrap = true,
					linebreak = true,
				},
			},
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
			{
				filter = {
					find = "semgrep",
				},
				opts = { skip = true },
			},
			{
				filter = {
					find = "Publish Diagnostics",
				},
				opts = { skip = true },
			},
			{
				filter = {
					find = "Validate Diagnostics",
				},
				opts = { skip = true },
			},
			{
				filter = {
					find = "Validate documents",
				},
				opts = { skip = true },
			},
			{
				filter = {
					find = "Lines Yanked",
				},
				opts = { skip = true },
			},
			{
				filter = {
					find = "Pick window:",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "notify",
				},
				view = "mini",
			},
			{
				filter = {
					kind = "echo",
					find = "ServiceReady",
				},
				view = "mini",
			},
			{
				filter = {
					kind = "echo",
					find = "Ready",
				},
				view = "mini",
			},
			{
				filter = {
					kind = "echo",
					find = "OK",
				},
				view = "mini",
			},
			{
				filter = {
					kind = "echo",
					find = "Init...",
				},
				view = "mini",
			},
			{
				filter = {
					kind = "emsg",
					event = "msg_show",
				},
				view = "mini_err",
			},
			{
				filter = {
					kind = "echo",
					find = "Java Language Server",
				},
				view = "mini",
			},
			{
				filter = {
					find = "Hop",
				},
				view = "mini",
			},
			{
				filter = {
					find = "there’s no such thing we can see…",
				},
				view = "mini",
			},
			{
				filter = {
					find = "no remaining sequence starts with",
				},
				view = "mini",
			},
			{
				filter = {
					find = "-> empty pattern",
				},
				view = "mini",
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
				},
				opts = { skip = true },
			},
		},
	},
	keymaps = {},
	main = "noice",
	on_setup_start = nil,
	setup = nil,
	on_setup_done = nil,
	---@diagnostic disable-next-line: duplicate-set-field
	url = "https://github.com/folke/noice.nvim",
}

noice.__index = noice

return noice
