---@class nvim-window-picker : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-window-picker, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-window-picker)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: nvim-window-picker, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_window_picker = {
	enabled = true,
	name = nil,
	options = {
		-- type of hints you want to get
		-- following types are supported
		-- 'statusline-winbar' | 'floating-big-letter'
		-- 'statusline-winbar' draw on 'statusline' if possible, if not 'winbar' will be
		-- 'floating-big-letter' draw big letter on a floating window
		-- used
		hint = "statusline-winbar",

		-- when you go to window selection mode, status bar will show one of
		-- following letters on them so you can use that letter to select the window
		selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",

		-- This section contains picker specific configurations
		picker_config = {
			statusline_winbar_picker = {
				-- You can change the display string in status bar.
				-- It supports '%' printf style. Such as `return char .. ': %f'` to display
				-- buffer file path. See :h 'stl' for details.
				selection_display = function(char, _)
					return "%=" .. char .. "%="
				end,

				-- whether you want to use winbar instead of the statusline
				-- "always" means to always use winbar,
				-- "never" means to never use winbar
				-- "smart" means to use winbar if cmdheight=0 and statusline if cmdheight > 0
				use_winbar = "never", -- "always" | "never" | "smart"
			},

			floating_big_letter = {
				-- window picker plugin provides bunch of big letter fonts
				-- fonts will be lazy loaded as they are being requested
				-- additionally, user can pass in a table of fonts in to font
				-- property to use instead

				font = "ansi-shadow", -- ansi-shadow |
			},
		},

		-- whether to show 'Pick window:' prompt
		show_prompt = true,

		-- prompt message to show to get the user input
		prompt_message = "Pick window: ",

		-- if you want to manually filter out the windows, pass in a function that
		-- takes two parameters. You should return window ids that should be
		-- included in the selection
		-- EX:-
		-- function(window_ids, filters)
		--    -- folder the window_ids
		--    -- return only the ones you want to include
		--    return {1000, 1001}
		-- end
		filter_func = function()
			-- List of filetypes to exclude
			local excluded_filetypes = {
				"NvimTree",
				"neo-tree",
				"notify",
				"lazy",
				"qf",
				"diff",
				"fugitive",
				"fugitiveblame",
				"dapui_scopes",
				"dapui_breakpoints",
				"dapui_stacks",
				"dapui_watches",
				"dapui-repl",
				"dapui_console",
			}

			-- List of buftypes to exclude
			local excluded_buftypes = { "terminal" }

			-- Get the list of windows
			local windows = vim.api.nvim_list_wins()

			-- The table that will hold the IDs of the windows to include
			local include_windows = {}

			-- Iterate over each window
			for _, win in ipairs(windows) do
				-- Check if the window is valid and visible
				if
					vim.api.nvim_win_is_valid(win)
					and vim.fn.win_info(win).winbot ~= 0
				then
					-- Get the buffer ID of the window
					local buf = vim.api.nvim_win_get_buf(win)

					-- Get the filetype and buftype of the buffer
					local filetype = vim.api.nvim_get_option_value(
						"filetype",
						{ buf = buf, scope = "local" }
					)
					local buftype = vim.api.nvim_get_option_value(
						"buftype",
						{ buf = buf, scope = "local" }
					)

					-- Check if the filetype and buftype are not in the exclude lists
					if
						not vim.tbl_contains(excluded_filetypes, filetype)
						and not vim.tbl_contains(excluded_buftypes, buftype)
					then
						-- If they're not, add the window ID to the include list
						table.insert(include_windows, win)
					end
				end
			end

			-- If there is only one window in the include list, return an empty table
			if #include_windows == 1 then
				return {}
			else
				return include_windows
			end
		end,

		-- following filters are only applied when you are using the default filter
		-- defined by this plugin. If you pass in a function to "filter_func"
		-- property, you are on your own
		filter_rules = {
			-- when there is only one window available to pick from, use that window
			-- without prompting the user to select
			autoselect_one = true,

			-- whether you want to include the window you are currently on to window
			-- selection or not
			include_current_win = false,

			-- filter using buffer options
			bo = {
				-- if the file type is one of following, the window will be ignored
				filetype = {
					"NvimTree",
					"neo-tree",
					"notify",
					"lazy",
					"qf",
					"diff",
					"fugitive",
					"fugitiveblame",
					"dapui_scopes",
					"dapui_breakpoints",
					"dapui_stacks",
					"dapui_watches",
					"dapui-repl",
					"dapui_console",
				},

				-- if the file type is one of following, the window will be ignored
				buftype = { "terminal" },
			},

			-- filter using window options
			wo = {},

			-- if the file path contains one of following names, the window
			-- will be ignored
			file_path_contains = {},

			-- if the file name contains one of following names, the window will be
			-- ignored
			file_name_contains = {},
		},
	},
	keymaps = {
		mappings = {},
	},
	main = "window-picker",
	on_setup_start = nil,
	setup = nil,
	on_setup_done = nil,
	url = "https://github.com/s1n7ax/nvim-window-picker",
}

nvim_window_picker.__index = nvim_window_picker

return nvim_window_picker
