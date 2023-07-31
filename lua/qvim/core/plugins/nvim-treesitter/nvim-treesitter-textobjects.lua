---@class ts_util
local ts_util = require("qvim.core.plugins.nvim-treesitter.util")

---@class nvim-treesitter-textobjects : nvim-treesitter
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string|nil the string to use when the neovim plugin is required
---@field on_setup_start fun(self: nvim-treesitter-textobjects, instance: table|nil)|nil hook setup logic at the beginning of the setup call
---@field setup_ext fun(self: nvim-treesitter-textobjects)|nil overwrite the setup function in core_meta_ext
---@field on_setup_done fun(self: nvim-treesitter-textobjects, instance: table|nil)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local nvim_treesitter_textobjects = {
	enabled = true,
	name = nil,
	-- TODO: mappings
	options = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				-- You can optionally set descriptions to the mappings (used in the desc parameter of
				-- nvim_buf_set_keymap) which plugins like which-key display
				["ic"] = {
					query = "@class.inner",
					desc = "Select inner part of a class region",
				},
				-- You can also use captures from other query groups like `locals.scm`
				["as"] = {
					query = "@scope",
					query_group = "locals",
					desc = "Select language scope",
				},
			},
			-- You can choose the select mode (default is charwise 'v')
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * method: eg 'v' or 'o'
			-- and should return the mode ('v', 'V', or '<c-v>') or a table
			-- mapping query_strings to modes.
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
				["@class.outer"] = "<c-v>", -- blockwise
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding or succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * selection_mode: eg 'v'
			-- and should return true of false
			include_surrounding_whitespace = true,
		},
		swap = {
			-- TODO custom capture group for functions with doc coments
			enable = true,
			swap_next = {
				["<leader>spn"] = "@parameter.inner",
				["<leader>sfn"] = {
					query = { "@comment", "@function.outer" },
				},
			},
			swap_previous = {
				["<leader>spp"] = "@parameter.inner",
				["<leader>sfp"] = {
					query = { "@comment", "@function.outer" },
				},
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = { query = "@class.outer", desc = "Next class start" },
				--
				-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
				["]o"] = "@loop.*",
				-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
				--
				-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
				-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
				["]s"] = {
					query = "@scope",
					query_group = "locals",
					desc = "Next scope",
				},
				["]z"] = {
					query = "@fold",
					query_group = "folds",
					desc = "Next fold",
				},
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
			-- Below will go to either the start or the end, whichever is closer.
			-- Use if you want more granular movements
			-- Make it even more gradual by adding multiple queries and regex.
			goto_next = {
				["]d"] = "@conditional.outer",
			},
			goto_previous = {
				["[d"] = "@conditional.outer",
			},
		},
		lsp_interop = {
			enable = true,
			border = "none",
			floating_preview_opts = {},
			peek_definition_code = {
				["<leader>pf"] = {
					query = { "@comment.outer", "@function.outer" },
				},
				["<leader>pc"] = "@class.outer",
				["<leader>pm"] = {
					query = { "@comment.outer", "@function.outer" },
				},
			},
		},
	},
	keymaps = {
		mappings = {},
		groups = {
			["<leader>s"] = {
				name = "swap",
				["p"] = {
					name = "parameter",
					["n"] = { "with next" },
					["p"] = { "with previous" },
				},
				["f"] = {
					name = "function",
					["n"] = { "with next" },
					["p"] = { "with previous" },
				},
			},
			["<leader>p"] = {
				name = "peek",
				["f"] = { "function" },
				["m"] = { "method" },
				["c"] = { "class" },
			},
		},
	},
	main = "textobjects",
	on_setup_start = nil,
	---@param self nvim-treesitter-textobjects
	setup_ext = function(self)
		ts_util.hook_extension_options(self)
		local wk = require("which-key")
		wk.register(self.keymaps.groups)
	end,
	on_setup_done = nil,
	url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
}

nvim_treesitter_textobjects.__index = nvim_treesitter_textobjects

return nvim_treesitter_textobjects
