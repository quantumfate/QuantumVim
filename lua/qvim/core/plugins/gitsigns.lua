---The gitsigns configuration file
local M = {}

local Log = require("qvim.log")

---Registers the global configuration scope for gitsigns
function M:init()
	if in_headless_mode() then
		return
	end
	local gitsigns = {
		active = true,
		on_config_done = nil,
		whichkey = {},
		keymaps = {},
		options = {
			on_attach = function(bufnr)
				require("qvim.keymaps"):register({
					{
						binding_group = "g",
						name = "+Git",
						bindings = {
							["g"] = { rhs = "<cmd>lua _LAZYGIT_TOGGLE()<CR>", desc = "Lazygit" },
							["j"] = { rhs = "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = "Next Hunk" },
							["k"] = {
								rhs = "<cmd>lua require 'gitsigns'.prev_hunk()<cr>",
								desc = "Prev Hunk",
								buffer = 0,
							},
							["l"] = { rhs = "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = "Blame" },
							["p"] = {
								rhs = "<cmd>lua require 'gitsigns'.preview_hunk()<cr>",
								desc = "Preview Hunk",
							},
							["r"] = { rhs = "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
							["R"] = {
								rhs = "<cmd>lua require 'gitsigns'.reset_buffer()<cr>",
								desc = "Reset Buffer",
							},
							["s"] = { rhs = "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
							["u"] = {
								rhs = "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
								desc = "Undo Stage Hunk",
							},
							["o"] = { rhs = "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
							["b"] = { rhs = "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
							["c"] = { rhs = "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
							["d"] = {
								rhs = "<cmd>Gitsigns diffthis HEAD<cr>",
								desc = "Diff",
							},
						},
						options = {
							prefix = "<leader>",
						},
					},
					bufnr,
				})
			end,
			-- gitsigns option configuration
			signs = {
				add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
				change = {
					hl = "GitSignsChange",
					text = "▎",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
				delete = {
					hl = "GitSignsDelete",
					text = "契",
					numhl = "GitSignsDeleteNr",
					linehl = "GitSignsDeleteLn",
				},
				topdelete = {
					hl = "GitSignsDelete",
					text = "契",
					numhl = "GitSignsDeleteNr",
					linehl = "GitSignsDeleteLn",
				},
				changedelete = {
					hl = "GitSignsChange",
					text = "▎",
					numhl = "GitSignsChangeNr",
					linehl = "GitSignsChangeLn",
				},
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 1000,
				ignore_whitespace = false,
			},
			current_line_blame_formatter_opts = {
				relative_time = false,
			},
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil, -- Use default
			max_file_length = 40000,
			preview_config = {
				-- Options passed to nvim_open_win
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
			yadm = {
				enable = false,
			},
		},
	}
	return gitsigns
end

---The gitsigns setup function. The module will be required by
---this function and it will call the respective setup function.
---A on_config_done function will be called if the plugin implements it.
function M:setup()
	if in_headless_mode() then
		return
	end
	local status_ok, gitsigns = pcall(reload, "gitsigns")
	if not status_ok then
		Log:warn(string.format("The plugin '%s' could not be loaded.", gitsigns))
		return
	end

	local _gitsigns = qvim.integrations.gitsigns
	gitsigns.setup(_gitsigns.options)

	if _gitsigns.on_config_done then
		_gitsigns.on_config_done()
	end
end

return M
