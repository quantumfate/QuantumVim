---@class nvim-tree : core_meta_plugin
---@field enabled boolean|fun():boolean|nil
---@field name string|nil the human readable name
---@field options table|nil
---@field keymaps table|nil
---@field main string
---@field on_setup_start fun(self: nvim-tree, instance: table)|nil hook setup logic at the beginning of the setup call
---@field setup fun(self: nvim-tree)|nil overwrite the setup function in core_base
---@field on_setup_done fun(self: nvim-tree, instance: table)|nil hook setup logic at the end of the setup call
---@field url string
local nvim_tree = {
	enabled = true,
	name = nil,
	options = {
		auto_reload_on_write = false,
		disable_netrw = false,
		hijack_cursor = false,
		hijack_netrw = true,
		hijack_unnamed_buffer_when_opening = false,
		sort_by = "name",
		root_dirs = {},
		prefer_startup_root = false,
		sync_root_with_cwd = true,
		reload_on_bufenter = false,
		respect_buf_cwd = false,
		on_attach = function(bufnr)
			local api = require("nvim-tree.api")

			local function telescope_find_files(_)
				require("qvim.integrations.nvim-tree").start_telescope(
					"find_files"
				)
			end

			local function telescope_live_grep(_)
				require("qvim.integrations.nvim-tree").start_telescope(
					"live_grep"
				)
			end

			api.config.mappings.default_on_attach(bufnr)

			local useful_keys = {
				["l"] = { callback = api.node.open.edit, "Open" },
				["o"] = { api.node.open.edit, "Open" },
				["<CR>"] = { api.node.open.edit, "Open" },
				["v"] = { api.node.open.vertical, "Open: Vertical Split" },
				["h"] = { api.node.navigate.parent_close, "Close Directory" },
				["C"] = { api.tree.change_root_to_node, "CD" },
				["tg"] = { telescope_live_grep, "Telescope Live Grep" },
				["tf"] = { telescope_find_files, "Telescope Find File" },
			}
			require("which-key").register(useful_keys, { buffer = bufnr })
		end,
		remove_keymaps = false,
		select_prompts = false,
		view = {
			adaptive_size = false,
			centralize_selection = true,
			width = 40,
			hide_root_folder = false,
			side = "left",
			preserve_window_proportions = false,
			number = false,
			relativenumber = false,
			signcolumn = "yes",
			float = {
				enable = false,
				quit_on_focus_loss = true,
				open_win_config = {
					relative = "editor",
					border = "rounded",
					width = 30,
					height = 30,
					row = 1,
					col = 1,
				},
			},
		},
		renderer = {
			add_trailing = false,
			group_empty = false,
			highlight_git = true,
			full_name = false,
			highlight_opened_files = "none",
			root_folder_label = ":t",
			indent_width = 2,
			indent_markers = {
				enable = false,
				inline_arrows = true,
				icons = {
					corner = "└",
					edge = "│",
					item = "│",
					none = " ",
				},
			},
			icons = {
				webdev_colors = qvim.config.use_icons,
				git_placement = "before",
				padding = " ",
				symlink_arrow = " ➛ ",
				show = {
					file = qvim.config.use_icons,
					folder = qvim.config.use_icons,
					folder_arrow = qvim.config.use_icons,
					git = qvim.config.use_icons,
				},
				glyphs = {
					default = qvim.icons.ui.Text,
					symlink = qvim.icons.ui.FileSymlink,
					bookmark = qvim.icons.ui.BookMark,
					folder = {
						arrow_closed = qvim.icons.ui.TriangleShortArrowRight,
						arrow_open = qvim.icons.ui.TriangleShortArrowDown,
						default = qvim.icons.ui.Folder,
						open = qvim.icons.ui.FolderOpen,
						empty = qvim.icons.ui.EmptyFolder,
						empty_open = qvim.icons.ui.EmptyFolderOpen,
						symlink = qvim.icons.ui.FolderSymlink,
						symlink_open = qvim.icons.ui.FolderOpen,
					},
					git = {
						unstaged = qvim.icons.git.FileUnstaged,
						staged = qvim.icons.git.FileStaged,
						unmerged = qvim.icons.git.FileUnmerged,
						renamed = qvim.icons.git.FileRenamed,
						untracked = qvim.icons.git.FileUntracked,
						deleted = qvim.icons.git.FileDeleted,
						ignored = qvim.icons.git.FileIgnored,
					},
				},
			},
			special_files = {
				"Cargo.toml",
				"Makefile",
				"README.md",
				"readme.md",
			},
			symlink_destination = true,
		},
		hijack_directories = {
			enable = false,
			auto_open = true,
		},
		update_focused_file = {
			enable = true,
			debounce_delay = 15,
			update_root = true,
			ignore_list = {},
		},
		diagnostics = {
			enable = qvim.config.use_icons,
			show_on_dirs = false,
			show_on_open_dirs = true,
			debounce_delay = 50,
			severity = {
				min = vim.diagnostic.severity.HINT,
				max = vim.diagnostic.severity.ERROR,
			},
			icons = {
				hint = qvim.icons.diagnostics.BoldHint,
				info = qvim.icons.diagnostics.BoldInformation,
				warning = qvim.icons.diagnostics.BoldWarning,
				error = qvim.icons.diagnostics.BoldError,
			},
		},
		filters = {
			dotfiles = false,
			git_clean = false,
			no_buffer = false,
			custom = { "node_modules", "\\.cache" },
			exclude = {},
		},
		filesystem_watchers = {
			enable = true,
			debounce_delay = 50,
			ignore_dirs = {},
		},
		git = {
			enable = true,
			ignore = false,
			show_on_dirs = true,
			show_on_open_dirs = true,
			timeout = 200,
		},
		actions = {
			use_system_clipboard = true,
			change_dir = {
				enable = true,
				global = false,
				restrict_above_cwd = false,
			},
			expand_all = {
				max_folder_discovery = 300,
				exclude = {},
			},
			file_popup = {
				open_win_config = {
					col = 1,
					row = 1,
					relative = "cursor",
					border = "shadow",
					style = "minimal",
				},
			},
			open_file = {
				quit_on_open = false,
				resize_window = false,
				window_picker = {
					enable = true,
					picker = function()
						return require("window-picker").pick_window(
							qvim.plugins.nvim_window_picker.options
						)
					end,
					chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
					exclude = {
						filetype = {
							"NvimTree",
							"neotree",
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
						buftype = { "nofile", "terminal", "help" },
					},
				},
			},
			remove_file = {
				close_window = true,
			},
		},
		trash = {
			cmd = "trash",
			require_confirm = true,
		},
		live_filter = {
			prefix = "[FILTER]: ",
			always_show_folders = true,
		},
		tab = {
			sync = {
				open = false,
				close = false,
				ignore = {},
			},
		},
		notify = {
			threshold = vim.log.levels.INFO,
		},
		log = {
			enable = false,
			truncate = false,
			types = {
				all = false,
				config = false,
				copy_paste = false,
				dev = false,
				diagnostics = false,
				git = false,
				profile = false,
				watcher = false,
			},
		},
		system_open = {
			cmd = nil,
			args = {},
		},
	},
	keymaps = {
		mappings = {
			["<leader>e"] = {
				function()
					require("nvim-tree.api").tree.toggle()
				end,
				"Toggle nvim file tree",
			},
		},
	},
	main = "nvim-tree",
	---@param self nvim-tree
	---@param _ table
	on_setup_start = function(self, _)
		if qvim.plugins.project and qvim.plugins.project.enabled then
			self.options.respect_buf_cwd = true
			self.options.update_cwd = true
			self.options.update_focused_file.enable = true
			self.options.update_focused_file.update_cwd = true
		end
	end,
	setup = nil,
	on_setup_done = nil,
	url = "https://github.com/nvim-tree/nvim-tree.lua",
}

nvim_tree.__index = nvim_tree

return nvim_tree
