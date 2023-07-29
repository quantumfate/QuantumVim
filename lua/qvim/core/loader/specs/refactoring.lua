return {
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-treesitter/nvim-treesitter" },
	},
	ft = function()
		return require("qvim.lang.null-ls.sources.refactoring").extra_filetypes
	end,
}
