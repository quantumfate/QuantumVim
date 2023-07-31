local actions =
	require("qvim.utils.modules").require_on_exported_call("telescope.actions")
local builtin =
	require("qvim.utils.modules").require_on_exported_call("telescope.builtin")

---@class telescope : core_meta_parent
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field theme string the theme to use for the telescope preview
---@field extensions_to_load table<string>
---@field extensions table<string> a list of extension url's
---@field conf_extensions table<string, AbstractExtension> instances of configured extensions
---@field options table|nil options used in the setup call of a neovim plugin
---@field keymaps keymaps|nil keymaps parsed to yikes.nvim
---@field main string the string to use when the neovim plugin is required
---@field on_setup_start fun(self: telescope, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: telescope)|nil overwrite the setup function in core_meta_parent
---@field on_setup_done fun(self: telescope, instance: table)|nil hook setup logic at the end of the setup call
---@field url string neovim plugin url
local telescope = {
	enabled = true,
	name = nil,
	theme = "dropdown",
	extensions = {
		"tsakirist/telescope-lazy.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		"nvim-telescope/telescope-dap.nvim",
		"nvim-telescope/telescope-project.nvim",
		"nvim-telescope/telescope-fzf-native.nvim",
	},
	conf_extensions = {},
	options = {
		defaults = {
			prompt_prefix = qvim.icons.ui.Telescope .. " ",
			selection_caret = qvim.icons.ui.Forward .. " ",
			entry_prefix = "  ",
			initial_mode = "insert",
			selection_strategy = "reset",
			sorting_strategy = nil,
			layout_strategy = nil,
			layout_config = {},
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--hidden",
				"--glob=!.git/",
			},
			---@usage Mappings are fully customizable. Many familiar mapping patterns are setup as defaults.
			mappings = {
				i = {
					["<TAB>"] = function() end,
					["<C-n>"] = actions.move_selection_next,
					["<C-t>"] = actions.move_selection_previous,
					["<C-c>"] = actions.close,
					["<C-j>"] = actions.cycle_history_next,
					["<C-k>"] = actions.cycle_history_prev,
					["<C-q>"] = function(...)
						actions.smart_send_to_qflist(...)
						actions.open_qflist(...)
					end,
					["<CR>"] = actions.select_default,
				},
				n = {
					["<C-n>"] = actions.move_selection_next,
					["<C-t>"] = actions.move_selection_previous,
					["<C-q>"] = function(...)
						actions.smart_send_to_qflist(...)
						actions.open_qflist(...)
					end,
				},
			},
			file_ignore_patterns = {},
			path_display = { "smart" },
			winblend = 0,
			border = {},
			borderchars = nil,
			color_devicons = true,
			set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		},
		pickers = {
			find_files = {
				hidden = true,
			},
			live_grep = {
				--@usage don't include the filename in the search results
				only_sort_text = true,
			},
			grep_string = {
				only_sort_text = true,
			},
			buffers = {
				initial_mode = "normal",
				mappings = {
					i = {
						["<C-d>"] = actions.delete_buffer,
					},
					n = {
						["dd"] = actions.delete_buffer,
					},
				},
			},
			planets = {
				show_pluto = true,
				show_moon = true,
			},
			git_files = {
				hidden = true,
				show_untracked = true,
			},
			colorscheme = {
				enable_preview = true,
			},
		},
		extensions = {
			-- hooked from respective extension file
		},
	},
	extensions_to_load = {},
	keymaps = {
		mappings = {
			f = {
				name = "Find",
				g = {
					name = "git",
					f = {
						name = "file",
						["c"] = {
							"<cmd>Telescope git_bcommits<cr>",
							"Show commits",
						},
						["r"] = {
							"<cmd>Telescope git_bcommits_range<cr>",
							"Show commits in range",
							mode = "v",
						},
					},
					["b"] = {
						"<cmd>Telescope git_branches<cr>",
						"Checkout branch",
					},
					["i"] = {
						"<cmd>Telescope git_status<cr>",
						"Git status",
					},
					["s"] = {
						"<cmd>Telescope git_stash<cr>",
						"Show shash",
					},
				},
				h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
				M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
				r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
				R = { "<cmd>Telescope registers<cr>", "Registers" },
				k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
				C = { "<cmd>Telescope commands<cr>", "Commands" },
				f = { builtin.find_files, "Fuzzy find files" },
				l = { builtin.live_grep, "Live grep" },
				b = { builtin.buffers, "Show buffers" },
				d = {
					name = "DAP",
					["c"] = {
						"<cmd>lua require'telescope'.extensions.dap.commands{}<cr>",
						"Show commands",
					},
					["s"] = {
						"<cmd>lua require'telescope'.extensions.dap.configurations{}<cr>",
						"Show setups",
					},
					["v"] = {
						"<cmd>lua require'telescope'.extensions.dap.variables{}<cr>",
						"Show variables",
					},
					["f"] = {
						"<cmd>lua require'telescope'.extensions.dap.frames{}<cr>",
						"Show frames",
					},
					["b"] = {
						"<cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<cr>",
						"Show breakpoints",
					},
				},
			},
		},
	},
	main = "telescope",
	---@param self telescope
	on_setup_start = function(self, _)
		local previewers = require("telescope.previewers")
		local sorters = require("telescope.sorters")

		self.options = vim.tbl_extend("keep", {
			file_previewer = previewers.vim_buffer_cat.new,
			grep_previewer = previewers.vim_buffer_vimgrep.new,
			qflist_previewer = previewers.vim_buffer_qflist.new,
			file_sorter = sorters.get_fuzzy_file,
			generic_sorter = sorters.get_generic_fuzzy_sorter,
		}, self.options)

		local theme = require("telescope.themes")["get_" .. (self.theme or "")]
		if theme and type(theme) == "function" then
			self.options.defaults = theme(self.options.defaults)
		end
	end,
	setup = nil,
	---@param self telescope
	---@param telescope table
	on_setup_done = function(self, telescope)
		for _, extension in pairs(self.extensions_to_load) do
			telescope.load_extension(extension)
		end
		require("qvim.core.util").register_keymaps(self)
	end,
	url = "https://github.com/nvim-telescope/telescope.nvim",
}

telescope.__index = telescope

return telescope
