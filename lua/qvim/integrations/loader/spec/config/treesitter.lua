local treesitter = {
	cmd = {
		"TSInstall",
		"TSUninstall",
		"TSUpdate",
		"TSUpdateSync",
		"TSInstallInfo",
		"TSInstallSync",
		"TSInstallFromGrammar",
	},
	event = "User FileOpened",
	dependencies = { "nvim-dap-repl-highlights" },
	lazy = true,
}

return treesitter
