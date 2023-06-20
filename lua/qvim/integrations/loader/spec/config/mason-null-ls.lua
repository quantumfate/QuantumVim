local mason_null_ls = {
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "jose-elias-alvarez/null-ls.nvim",
    },
}

return mason_null_ls
