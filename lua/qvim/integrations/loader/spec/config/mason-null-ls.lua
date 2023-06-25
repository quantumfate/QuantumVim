local mason_null_ls = {
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"null-ls",
	},
	lazy = true,
}

return mason_null_ls
