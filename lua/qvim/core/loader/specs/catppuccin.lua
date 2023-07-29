return {
	name = "catppuccin",
	priority = 1000,
	event = "VimEnter",
	init = function()
		-- compile on startup because configuration is not cached properly
		vim.cmd("CatppuccinCompile")
	end,
}
