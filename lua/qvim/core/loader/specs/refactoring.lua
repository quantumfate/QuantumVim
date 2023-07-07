local refactoring = {
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-treesitter/nvim-treesitter" },
	},
	lazy = true,
	ft = function()
		return require("qvim.lang.null-ls.sources.refactoring").extra_filetypes
	end,
}

return refactoring
