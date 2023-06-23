local cmp = {
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp",     lazy = true },
        { "saadparwaiz1/cmp_luasnip", lazy = true },
        { "hrsh7th/cmp-buffer",       lazy = true },
        { "hrsh7th/cmp-path",         lazy = true },
        { "hrsh7th/cmp-cmdline",      lazy = true },
    },
    lazy = true
}

return cmp
