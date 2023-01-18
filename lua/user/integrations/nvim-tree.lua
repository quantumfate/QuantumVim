-- following options are the default
-- each of these are documented in `:help nvim-tree.option_name`
local utils = require("user.utils.util")
local nvim_tree = utils:require_module("nvim-tree")
local nvim_tree_config = utils:require_module("nvim-tree.config")

local tree_cb = nvim_tree_config.nvim_tree_callback

nvim_tree.icons = {
	glyphs = {
		default = "",
		symlink = "",
		git = {
			unstaged = "",
			staged = "s",
			unmerged = "",
			renamed = "➜",
			deleted = "",
			untracked = "u",
			ignored = "◌",
		},
		folder = {
			default = "",
			open = "",
			empty = "",
			empty_open = "",
			symlink = "",
		},
	},
}
nvim_tree.setup({

	disable_netrw = true,
	hijack_netrw = true,
	open_on_setup = false,
	ignore_ft_on_setup = {
		"startify",
		"dashboard",
		"alpha",
	},
	-- auto_close = true,
	open_on_tab = false,
	hijack_cursor = false,
	update_cwd = true,
	diagnostics = {
		enable = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	update_focused_file = {
		enable = true,
		update_cwd = true,
		ignore_list = {},
	},
	system_open = {
		cmd = nil,
		args = {},
	},
	filters = {
		dotfiles = false,
		custom = {},
	},
	git = {
		enable = true,
		ignore = true,
		timeout = 500,
	},
	view = {
		width = 30,
		side = "left",
		mappings = {
			custom_only = false,
			list = {
				{ key = { "l", "<cr>", "o" }, cb = tree_cb("edit") },
				{ key = "h", cb = tree_cb("close_node") },
				{ key = "v", cb = tree_cb("vsplit") },
			},
		},
		number = false,
		relativenumber = false,
	},
	trash = {
		cmd = "trash",
		require_confirm = true,
	},
})
