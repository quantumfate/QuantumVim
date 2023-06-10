local mason_null_ls = {
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim",
        "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
        require("qvim.lsp.null-ls").setup() -- require your null-ls config here (example below)
    end,
}

return mason_null_ls
