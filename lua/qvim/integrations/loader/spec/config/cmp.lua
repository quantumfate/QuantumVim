local cmp = {
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "cmp-nvim-lsp",
        "cmp_luasnip",
        "cmp-buffer",
        "cmp-path",
        "cmp-cmdline",
    },

}

return cmp
