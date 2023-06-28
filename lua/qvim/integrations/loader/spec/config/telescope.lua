local telescope = {
	dependencies = {
		"tsakirist/telescope-lazy.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		"nvim-telescope/telescope-dap.nvim",
		"nvim-telescope/telescope-project.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
		"nvim-lua/plenary.nvim",
	},
	lazy = true,
	cmd = "Telescope",
}

return telescope
